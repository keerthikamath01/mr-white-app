import 'dart:math'; 
import '../models/player.dart';
import '../models/game_state.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:flutter/material.dart';

// things to add
// set max players to 10
// add toggle to make undercovers a separate team from civilians and add game logic

// add a view before setup_view with "Play" and "Instructions" buttons 
// main should route here
// edit navigator accordingly, currently all exit/reset buttons navigate to route.isFirst


/// GameViewModel contains all the logic for the Mr. White game.
/// Handles players, roles, words, reveals, eliminations, and determining the winner.
class GameViewModel extends ChangeNotifier {
  
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


  // Reset game
  void reset() {
    _gameState.reset();
    notifyListeners();
  }

  /// Sets up the game with a list of player names
  void setupGame(List<String> playerNames, {int mrWhites = 1, int undercovers = 1}) {
    
    // pass required data to game state
    _gameState.setupGame(playerNames, mrWhites: mrWhites, undercovers: undercovers);

    // Generate words and pass to game state
    final pair = wordPairs[_random.nextInt(wordPairs.length)]; // later replace with AI API
    _gameState.assignWords(pair["main"]!, pair["undercover"]!);

    // Assign roles (words must already be assigned)
    _gameState.assignRoles();

    notifyListeners();
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

  /// Role management functions below
  /// 
  /// Check if this role can be added to the game based on existing roles/players
  bool canAddRole({
    required int totalPlayers,
    required int currentWhites,
    required int currentUndercovers,
    required String role, // "white" or "undercover"
  }) => _gameState.canAddRole(
        totalPlayers: totalPlayers,
        currentWhites: currentWhites,
        currentUndercovers: currentUndercovers,
        role: role,
      );

  /// Determine if this role can be removed from the game
  bool canRemoveRole({
    required int currentWhites,
    required int currentUndercovers,
    required String role,
  }) => _gameState.canRemoveRole(
        currentWhites: currentWhites,
        currentUndercovers: currentUndercovers,
        role: role,
      );

  /// If players are deleted, re-evaluate number of special characters accordingly
  int specialsToReduce({
    required int totalPlayers,
    required int currentWhites,
    required int currentUndercovers,
  }) => _gameState.specialsToReduce(
        totalPlayers: totalPlayers,
        currentWhites: currentWhites,
        currentUndercovers: currentUndercovers,
      );


}