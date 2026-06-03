import 'package:flutter/material.dart';
import 'package:hello_flutter/Views/Pages/map_page.dart';

/// Home screen: live incident map/list is shown by default.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MapPage();
  }
}
