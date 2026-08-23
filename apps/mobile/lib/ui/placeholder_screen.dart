import 'package:flutter/material.dart';

/// Stands in for a screen that hasn't been built yet. Every destination in
/// the navigation shell uses this until its real feature phase lands.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title — coming soon')),
    );
  }
}
