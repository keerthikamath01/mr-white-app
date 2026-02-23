import 'player.dart';
import 'dart:math'; 

enum GamePhase {
  waitingForPlayers,
  showingWords,
  voting,
  gameOver
}
// other phases - assigningRoles, revealing?

// Winner enum
enum Winner {
    civilians,
    mrWhite,
    undercover,
    none,
}


class GameState {

  // default constructor used
  List<Player> players = []; // List of all players in the game
  int currentRevealIndex = 0; // Index of the current player whose role is being revealed
  String? mainWord; // The main word for civilians
  String? undercoverWord; // The word for the undercover player
  int mrWhites = 1;
  int undercovers = 1;
  Winner winner = Winner.none; // Winner of current game
  //GamePhase phase; // not used yet

  final Random _random = Random();



  void reset() {
    // Reset all players
    for (final player in players) {
      player.reset();
    }

    currentRevealIndex = 0;
    winner = Winner.none;
    // Optional
    mainWord = null;
    undercoverWord = null;

  }

  /// Initialize players list and reset state for a new game
  void setupGame(List<String> playerNames, {int mrWhites = 1, int undercovers = 1}) {
    
    // Map existing players by name to avoid recreating player objects
    final existingPlayers = {for (var p in players) p.name: p};

    // Build new list in order of playerNames
    players = playerNames.map((name) {
      // Reuse existing player if present, otherwise create new
      return existingPlayers[name] ?? Player(name: name);
    }).toList();

    winner = Winner.none; // redundant?
    // Number of whites and undercovers
    this.mrWhites = mrWhites;
    this.undercovers = undercovers;

    // Optional: reset words here
    mainWord = null;
    undercoverWord = null;

  }


  /// Assign words to the game
  void assignWords(String main, String undercover) {
    mainWord = main;
    undercoverWord = undercover;
  }


  /// Randonly assigns roles to players (depends on words already assigned)
  void assignRoles() {
    // Error message
    assert(mainWord != null && undercoverWord != null, "Words must be assigned first!");

    // Track indices of players who are special characters
    var mrWhiteIndices = <int>{};
    var undercoverIndices = <int>{};

    // Randomly choose Mr. White indices
    while (mrWhiteIndices.length < mrWhites) { // set ensures uniqe indices
      int mrWhiteIndex = _random.nextInt(players.length);
      mrWhiteIndices.add(mrWhiteIndex);
    }

    // Randomly choose Undercover, different indices than Mr. White
    while (undercoverIndices.length < undercovers) {
      int undercoverIndex = _random.nextInt(players.length);
      // Ensure no overlap with Mr. White
      if (!mrWhiteIndices.contains(undercoverIndex)) {
        undercoverIndices.add(undercoverIndex);
      }
    }

    // Assign roles and words to each player
    for (int i = 0; i < players.length; i++) {
      if (mrWhiteIndices.contains(i)) {
        players[i].setRole(Role.mrWhite, null); // Mr. White gets no word
      } else if (undercoverIndices.contains(i)) {
        players[i].setRole(Role.undercover, undercoverWord);
      } else {
        players[i].setRole(Role.civilian, mainWord);
      }
    }
  }
}



