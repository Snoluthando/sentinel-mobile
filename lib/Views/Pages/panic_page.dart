import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hello_flutter/services/sentinel_api.dart';
import 'package:hello_flutter/theme/sentinel_colors.dart';

enum _PanicPhase { idle, counting, active }

class PanicPage extends StatefulWidget {
  const PanicPage({super.key});

  @override
  State<PanicPage> createState() => _PanicPageState();
}

class _PanicPageState extends State<PanicPage> {
  final SentinelApi _api = SentinelApi();
  _PanicPhase _phase = _PanicPhase.idle;
  int _countdown = 5;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    HapticFeedback.heavyImpact();
    setState(() {
      _phase = _PanicPhase.counting;
      _countdown = 5;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        _triggerPanic();
      } else {
        HapticFeedback.lightImpact();
        setState(() => _countdown--);
      }
    });
  }

  void _cancel() {
    _timer?.cancel();
    setState(() {
      _phase = _PanicPhase.idle;
      _countdown = 5;
    });
  }

  Future<void> _triggerPanic() async {
    setState(() => _phase = _PanicPhase.active);
    await HapticFeedback.heavyImpact();
    await HapticFeedback.heavyImpact();

    try {
      final pos = await _api.currentPosition();
      debugPrint('Panic at ${pos.latitude}, ${pos.longitude}');
    } catch (e) {
      debugPrint('Panic location error: $e');
    }
  }

  void _deactivate() {
    _timer?.cancel();
    setState(() {
      _phase = _PanicPhase.idle;
      _countdown = 5;
    });
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Safe'),
        content: const Text('Panic alert deactivated. Stay safe.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _phase == _PanicPhase.active
          ? const Color(0xFF1A0000)
          : sentinelBackground,
      child: switch (_phase) {
        _PanicPhase.active => _ActiveView(onSafe: _deactivate),
        _PanicPhase.counting => _CountdownView(
            countdown: _countdown,
            onCancel: _cancel,
          ),
        _PanicPhase.idle => _IdleView(onPanic: _startCountdown),
      },
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({required this.onPanic});

  final VoidCallback onPanic;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Emergency Panic',
            style: TextStyle(
              color: sentinelText,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap the button to send an emergency alert to armed response and your emergency contacts',
            style: TextStyle(color: Colors.white38, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GestureDetector(
            onTap: onPanic,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sentinelAccent.withValues(alpha: 0.15),
                border: Border.all(color: sentinelAccent, width: 3),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emergency, color: sentinelAccent, size: 56),
                  SizedBox(height: 8),
                  Text(
                    'TAP FOR PANIC',
                    style: TextStyle(
                      color: sentinelAccent,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What happens when you panic:',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                SizedBox(height: 12),
                _InfoRow(icon: Icons.location_on_outlined, text: 'Your GPS location is captured'),
                _InfoRow(icon: Icons.local_police_outlined, text: 'Armed response is notified'),
                _InfoRow(icon: Icons.sms_outlined, text: 'Emergency contacts receive an SMS'),
                _InfoRow(icon: Icons.timer_outlined, text: '5 second countdown to cancel'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _CountdownView extends StatelessWidget {
  const _CountdownView({required this.countdown, required this.onCancel});

  final int countdown;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$countdown',
          style: const TextStyle(
            color: sentinelAccent,
            fontSize: 120,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Sending panic alert in...',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
        const SizedBox(height: 48),
        OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
            side: const BorderSide(color: Colors.white24),
          ),
          child: const Text(
            'CANCEL',
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 2),
          ),
        ),
      ],
    );
  }
}

class _ActiveView extends StatelessWidget {
  const _ActiveView({required this.onSafe});

  final VoidCallback onSafe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emergency, color: sentinelAccent, size: 72),
          const SizedBox(height: 24),
          const Text(
            'PANIC ALERT ACTIVE',
            style: TextStyle(
              color: sentinelAccent,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your location is being shared with emergency contacts and armed response',
            style: TextStyle(color: Colors.white54, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: onSafe,
            icon: const Icon(Icons.check),
            label: const Text(
              'I AM SAFE',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Color(0xFF10B981),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            ),
          ),
        ],
      ),
    );
  }
}
