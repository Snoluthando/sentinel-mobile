import 'package:flutter/material.dart';
import 'package:hello_flutter/Data/notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedpageNotifier,
      builder: (context, selectedpage, child) {
        return NavigationBar(
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home),
              label: 'Sentinel', 
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'Profile', 
            ),
          ],
        
        onDestinationSelected: (int value) {
          selectedpageNotifier.value = value;
        },
        selectedIndex: selectedpage,
        );
      },
    );
  }
}