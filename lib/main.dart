import 'package:flutter/material.dart';
import 'views/setup_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // wait for flutter
  await dotenv.load(fileName: "assets/.env"); // load env
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