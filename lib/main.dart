import 'package:flutter/material.dart';
import 'views/setup_view.dart';
import 'view_models/game_view_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:hive_ce_flutter/hive_flutter.dart'; // community edition
import 'data/local/word_cache_manager.dart';
import 'data/repository/word_repository.dart';
import 'data/services/gemini_service_test.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // wait for flutter
  await Hive.initFlutter(); // Initialize local cache
  await dotenv.load(fileName: "assets/.env"); // load env

  // 1. Initialize dependencies
  //final geminiService = GeminiService();
  //final cacheManager = WordCacheManager();
  //final repository = WordRepository(geminiService, cacheManager);

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