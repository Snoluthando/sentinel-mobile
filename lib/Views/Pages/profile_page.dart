import 'package:flutter/material.dart';
import 'package:hello_flutter/theme/sentinel_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _displayName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _suburb = TextEditingController();
  final _emergencyContact1 = TextEditingController();
  final _emergencyContact2 = TextEditingController();
  bool _anonymousMode = true;

  @override
  void dispose() {
    _displayName.dispose();
    _phone.dispose();
    _email.dispose();
    _suburb.dispose();
    _emergencyContact1.dispose();
    _emergencyContact2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sentinelBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: sentinelSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: sentinelAccent.withValues(alpha: 0.2),
              child: const Icon(Icons.person, size: 40, color: sentinelAccent),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Account'),
          _field(_displayName, 'Display name', 'How you appear to the community'),
          _field(_phone, 'Phone number', '+27...'),
          _field(_email, 'Email (optional)', 'you@example.com'),
          _field(_suburb, 'Home suburb', 'e.g. Sandton'),
          const SizedBox(height: 16),
          _sectionTitle('Privacy'),
          SwitchListTile(
            value: _anonymousMode,
            onChanged: (v) => setState(() => _anonymousMode = v),
            title: const Text(
              'Anonymous reporting',
              style: TextStyle(color: sentinelText),
            ),
            subtitle: const Text(
              'Hide your identity on new incident reports',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            activeThumbColor: sentinelBlue,
          ),
          const SizedBox(height: 16),
          _sectionTitle('Emergency contacts'),
          _field(_emergencyContact1, 'Primary contact', 'Name and phone'),
          _field(_emergencyContact2, 'Secondary contact', 'Name and phone'),
          const SizedBox(height: 16),
          _sectionTitle('Community trust'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.verified_user, color: Colors.green.shade400),
            title: const Text(
              'Trust score',
              style: TextStyle(color: sentinelText),
            ),
            subtitle: const Text(
              'Increases when your reports are verified',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
            trailing: const Text(
              '--',
              style: TextStyle(
                color: sentinelText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile saved locally')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: sentinelBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Save profile'),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: sentinelText),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white54),
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
        ),
      ),
    );
  }
}
