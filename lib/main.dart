import 'package:flutter/material.dart';
import 'views/setup_view.dart';

void main() {
  runApp(const MrWhiteApp()); // run app
}

/// Mr White App
class MrWhiteApp extends StatelessWidget {
  const MrWhiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr White',
      debugShowCheckedModeBanner: false,
      home: SetupView(), // First page = Setup view
    );
  }
}