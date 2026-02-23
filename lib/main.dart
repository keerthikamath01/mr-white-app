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
    
    // Implement phases
    //final gameViewModel = context.watch<GameViewModel>(); // rebuilds on notifyListeners

    /*
    // Choose which screen to display based on global game phase
    Widget currentView;
    switch (gameViewModel.phase) {
      case GamePhase.setup:
        currentView = const SetupView();
        break;
      case GamePhase.roleReveal:
        currentView = const RoleRevealView();
        break;
      case GamePhase.voting:
        currentView = const VotingView();
        break;
      case GamePhase.mrWhiteGuess:
        currentView = const MrWhiteGuessView();
        break;
      case GamePhase.summary:
        currentView = const SummaryView();
        break;
    }
    */

    return MaterialApp(
      title: 'Mr White',
      debugShowCheckedModeBanner: false,
      home: SetupView(), // First page = Setup view -> change to current view
    );
  }
}