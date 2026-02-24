import 'dart:math'; 
import '../models/player.dart';
import '../models/game_state.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:flutter/material.dart';
import '../data/repository/word_repository.dart';

// things to add
// set max players to 10
// add toggle to make undercovers a separate team from civilians and add game logic

// add a view before setup_view with "Play" and "Instructions" buttons 
// main should route here
// edit navigator accordingly, currently all exit/reset buttons navigate to route.isFirst


/// GameViewModel contains all the logic for the Mr. White game.
/// Handles players, roles, words, reveals, eliminations, and determining the winner.
class GameViewModel extends ChangeNotifier {
  
  final WordRepository _repository;

  // Hold all game state
  GameState _gameState = GameState();

  // Getter for state
  GameState get gameState => _gameState;

  // Predefined word pairs for testing
  // Replace with AI API
  final List<Map<String, String>> wordPairs = [
    {"main": "Cat", "undercover": "Tiger"},
    {"main": "Beach", "undercover": "Desert"},
    {"main": "Pizza", "undercover": "Burger"},
  ];

  final Random _random = Random();

  // Inputs that will be passed to set up the game state (after setup view)
  // List to store the names of players added to the game
  List<String> playerNames = [];
  int mrWhiteCount = 1;
  int undercoverCount = 1;

  GameViewModel(this._repository);


  // Reset game
  void reset() {
    _gameState.reset();
    notifyListeners();
  }

  /// Sets up the game with a list of player names
  Future<void> setupGame(List<String> playerNames) async {
    
    // pass required data to game state
    _gameState.setupGame(playerNames, mrWhites: mrWhiteCount, undercovers: undercoverCount);

    // Generate words and pass to game state
    //final pair = wordPairs[_random.nextInt(wordPairs.length)]; // later replace with AI API
    final pair = await _getWordPair();
    _gameState.assignWords(pair["main"]!, pair["undercover"]!);

    // Assign roles (words must already be assigned)
    _gameState.assignRoles();

    notifyListeners();
  }

  /*
  // Implement game phase
  GamePhase get phase => _gameState.phase;

  void nextPhase(GamePhase newPhase) {
    _gameState.phase = newPhase;
    notifyListeners(); // UI updates automatically
  }
  */

  Future<Map<String, String>> _getWordPair() async {
    // Talk to the repository (which handles Hive vs Gemini)
    final pair = await _repository.getNextWordPair();
    
    notifyListeners();
    // move to loading block in setup game function eventually

    return pair;
  }

  /// Returns the current player whose role is being revealed
  Player getCurrentPlayer() => _gameState.getCurrentPlayer();

  /// Advances to the next player in the reveal sequence
  void nextPlayerReveal() {
    _gameState.nextReveal();
    notifyListeners();
  }

  /// Marks a player as eliminated
  void eliminatePlayer(Player player) {
    _gameState.eliminatePlayer(player);
    
    // Check if game is over after elimination
    _gameState.checkGameOver(); // updates winner if needed
    notifyListeners(); // notify UI
  }

  /// Determine if game is over
  bool get isGameOver => _gameState.winner != Winner.none; // function for this?

  /// Assign Mr. White as winner if correct word is guessed
  void resolveMrWhiteGuess(String guess) {
    _gameState.resolveMrWhiteGuess(guess);
    _gameState.checkGameOver(); // in case guess ends the game
    notifyListeners(); // notify UI of winner change
  }

  /// Returns a string message declaring the winner
  String get winnerMessage {
    switch (_gameState.winner) {
      case Winner.mrWhite:
        return "Mr. White wins!";
      case Winner.civilians:
        return "Civilians win!";
      case Winner.undercover: // not implemented yet
        return "Undercover wins!";
      default:
        return "";
    }
  }


  /// Setup view management
  /// Manipulate variables that will be passed to game state on game setup
  /// Add player name to list
  void addPlayer(String name) {
    if (playerNames.contains(name) || name.isEmpty) return;
    playerNames.add(name);
    notifyListeners();
  }

  /// Remove player name at index and reduce special character count accordingly
  void removePlayerAt(int index) {
    playerNames.removeAt(index);

    // Reduce special characters if needed
    int extraSpecials = specialsToReduce();

    while (extraSpecials > 0) {
      if (mrWhiteCount > 1) {
        mrWhiteCount--;
      } else {
        undercoverCount--;
      }
      extraSpecials--;
    }

    notifyListeners();
  }

  /// Helper functions to modify white/undercover count
  void incrementMrWhite() {
    mrWhiteCount++;
    notifyListeners();
  }

  void decrementMrWhite() {
    mrWhiteCount--;
    notifyListeners();
  }

  void incrementUndercover() {
    undercoverCount++;
    notifyListeners();
  }

  void decrementUndercover() {
    undercoverCount--;
    notifyListeners();
  }

  /// Move player up in list
  void movePlayerUp(int index) {
    if (index <= 0) return;

    final temp = playerNames[index];
    playerNames[index] = playerNames[index - 1];
    playerNames[index - 1] = temp;

    notifyListeners();
  }

  /// Move player down in list
  void movePlayerDown(int index) {
    if (index >= playerNames.length - 1) return;

    final temp = playerNames[index];
    playerNames[index] = playerNames[index + 1];
    playerNames[index + 1] = temp;

    notifyListeners();
  }

  /// Role management helper functions below (call game state for logic)
  /// Pass current inputs defined in game view model
  /// Check if this role can be added to the game based on existing roles/players
  bool canAddRole({
    required String role, // "white" or "undercover"
  }) => _gameState.canAddRole(
        totalPlayers: playerNames.length,
        currentWhites: mrWhiteCount,
        currentUndercovers: undercoverCount,
        role: role,
      );

  /// Determine if this role can be removed from the game
  bool canRemoveRole({
    required String role,
  }) => _gameState.canRemoveRole(
        currentWhites: mrWhiteCount,
        currentUndercovers: undercoverCount,
        role: role,
      );

  /// If players are deleted, re-evaluate number of special characters accordingly
  int specialsToReduce() => _gameState.specialsToReduce(
        totalPlayers: playerNames.length,
        currentWhites: mrWhiteCount,
        currentUndercovers: undercoverCount,
      );


}