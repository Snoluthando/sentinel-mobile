import 'package:flutter/material.dart';
import 'package:hello_flutter/constants/incident_categories.dart';
import 'package:hello_flutter/services/sentinel_api.dart';
import 'package:hello_flutter/theme/sentinel_colors.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key, this.onSuccess});

  final VoidCallback? onSuccess;

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final SentinelApi _api = SentinelApi();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _category;
  bool _anonymous = true;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_category == null) {
      _showMessage('Select a category', 'Please choose what type of incident to report.');
      return;
    }
    if (_titleController.text.trim().isEmpty) {
      _showMessage('Add a title', 'Please describe what happened briefly.');
      return;
    }

    setState(() => _loading = true);
    try {
      final pos = await _api.currentPosition();
      await _api.submitIncident(
        category: _category!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        lat: pos.latitude,
        lng: pos.longitude,
        anonymous: _anonymous,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reported'),
          content: const Text(
            'Your incident has been submitted. Thank you for keeping your community safe.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      _titleController.clear();
      _descriptionController.clear();
      setState(() => _category = null);
      widget.onSuccess?.call();
      if (widget.onSuccess == null) {
        if (!context.mounted) return;
        Navigator.pop(context);
      }
    } on SentinelApiException catch (e) {
      _showMessage('Error', e.message);
    } catch (_) {
      _showMessage(
        'Connection Error',
        'Could not reach the server. Please check your internet connection.',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String title, String body) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sentinelBackground,
      appBar: AppBar(
        title: const Text('Report'),
        backgroundColor: sentinelSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          const Text(
            'Report an Incident',
            style: TextStyle(
              color: sentinelText,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your location will be captured automatically',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 24),
          const Text(
            'WHAT HAPPENED?',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kIncidentCategories.map((cat) {
              final active = _category == cat.id;
              return SizedBox(
                width: (MediaQuery.sizeOf(context).width - 56) / 3,
                child: Material(
                  color: active
                      ? sentinelBlue.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _category = cat.id),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: active
                              ? sentinelBlue
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(cat.icon, color: active ? sentinelBlue : Colors.white38, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            cat.label,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: active ? sentinelBlue : Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'BRIEF DESCRIPTION',
            style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _titleController,
            maxLength: 100,
            style: const TextStyle(color: sentinelText),
            decoration: _inputDecoration('e.g. Armed robbery at parking lot'),
          ),
          const SizedBox(height: 16),
          const Text(
            'MORE DETAILS (OPTIONAL)',
            style: TextStyle(color: Colors.white60, fontSize: 12, letterSpacing: 1),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            maxLength: 500,
            maxLines: 4,
            style: const TextStyle(color: sentinelText),
            decoration: _inputDecoration(
              'Vehicle description, suspects, direction of travel...',
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => setState(() => _anonymous = !_anonymous),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _anonymous ? sentinelBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: _anonymous
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Submit anonymously',
                  style: TextStyle(color: Colors.white60),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _loading ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: sentinelAccent,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Submit Report',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
          ),
          const SizedBox(height: 16),
          const Text(
            'False reports undermine community safety. Only report real incidents.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white24, fontSize: 11, height: 1.5),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
    );
  }
}
