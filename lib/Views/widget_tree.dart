import 'package:flutter/material.dart';
import 'package:hello_flutter/Data/notifiers.dart';
import 'package:hello_flutter/Views/Pages/alerts_page.dart';
import 'package:hello_flutter/Views/Pages/home_page.dart';
import 'package:hello_flutter/Views/Pages/panic_page.dart';
import 'package:hello_flutter/Views/Pages/profile_page.dart';
import 'package:hello_flutter/Views/Pages/report_page.dart';
import 'package:hello_flutter/Views/Pages/settings.dart';
import 'package:hello_flutter/Views/Pages/welcome_page.dart';
import 'package:hello_flutter/theme/sentinel_colors.dart';

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});

  void _openPanic(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: sentinelBackground,
          appBar: AppBar(
            title: const Text('Emergency'),
            backgroundColor: sentinelSurface,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: const SafeArea(child: PanicPage()),
        ),
      ),
    );
  }

  void _openDrawerPage(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sentinelBackground,
      appBar: AppBar(
        title: const Text('Sentinel'),
        backgroundColor: sentinelSurface,
        actions: [
          IconButton(
            onPressed: () {
              darkmodeNotifier.value = !darkmodeNotifier.value;
            },
            icon: ValueListenableBuilder(
              valueListenable: darkmodeNotifier,
              builder: (context, darkMode, child) {
                return Icon(darkMode ? Icons.light_mode : Icons.dark_mode);
              },
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(title: 'Settings'),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: sentinelSurface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF000205)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Sentinel',
                    style: TextStyle(
                      color: sentinelAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Community Intelligence',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () => _openDrawerPage(context, const ProfilePage()),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Alerts'),
              onTap: () => _openDrawerPage(context, const AlertsPage()),
            ),
            ListTile(
              leading: const Icon(Icons.report_outlined),
              title: const Text('Report'),
              onTap: () => _openDrawerPage(context, const ReportPage()),
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomePage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: const HomePage(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openPanic(context),
        backgroundColor: sentinelAccent,
        elevation: 6,
        child: const Icon(Icons.emergency, color: Colors.white, size: 32),
      ),
    );
  }
}
