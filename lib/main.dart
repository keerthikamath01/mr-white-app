import 'package:flutter/material.dart';
import 'views/setup_view.dart';
import 'view_models/game_view_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // wait for flutter
  await dotenv.load(fileName: "assets/.env"); // load env
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameViewModel(), // provide the view model
      child: const MrWhiteApp(),
    ),
  ); // run app
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