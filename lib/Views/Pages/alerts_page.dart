import 'package:flutter/material.dart';
import 'package:hello_flutter/constants/incident_categories.dart';
import 'package:hello_flutter/models/incident.dart';
import 'package:hello_flutter/services/sentinel_api.dart';
import 'package:hello_flutter/theme/sentinel_colors.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final SentinelApi _api = SentinelApi();
  List<Incident> _alerts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final all = await _api.fetchNearbyIncidents(hours: 48);
      if (!mounted) return;
      setState(() {
        _alerts = all
            .where((i) => i.status == 'verified' || i.status == 'pending')
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sentinelBackground,
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: sentinelSurface,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: sentinelAccent),
            )
          : _alerts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 48,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No alerts in the last 48 hours',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: sentinelAccent,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _alerts.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    itemBuilder: (context, index) {
                      final item = _alerts[index];
                      final config = categoryForId(item.category);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: config.color.withValues(alpha: 0.15),
                          child: Icon(config.icon, color: config.color, size: 22),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(color: sentinelText),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${config.label} · ${timeAgo(item.createdAt)} · ${item.status}',
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: Colors.green.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.confirmationCount}',
                              style: TextStyle(
                                color: Colors.green.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
