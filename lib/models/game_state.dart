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

  List<Player> players; // List of all players in the game
  int currentRevealIndex; // Index of the current player whose role is being revealed
  String? mainWord; // The main word for civilians
  String? undercoverWord; // The word for the undercover player
  int mrWhites;
  int undercovers;
  Winner winner; // Winner of current game
  GamePhase phase;

  GameState({
    required this.players,
    this.currentRevealIndex = 0,
    this.mainWord,
    this.undercoverWord,
    this.mrWhites = 1,
    this.undercovers = 1,
    this.winner = Winner.none,
    this.phase = GamePhase.waitingForPlayers,
  });


  void reset() {

    this.currentRevealIndex = 0;
    this.winner = Winner.none;

    // Reset all players
    // Currently players are re-initialized anyways?
    for (final player in this.players) {
      player.resetPlayer();
    }

    // Optional
    this.mainWord = null;
    this.undercoverWord = null;

  }

  // Converts names into Player objects, then assigns words and roles
  void startGame(List<String> playerNames, int mrWhites, int undercovers) {
    
    // Don't need to re-initialize the same players after restarting??
    // But what if we add/remove players
    this.players = playerNames.map((name) => Player(name: name)).toList();
    
    this.winner = Winner.none; // redundant?
    // Number of whites and undercovers
    this.mrWhites = mrWhites;
    this.undercovers = undercovers;
    
  }

  void assignWords(String? main, String? undercover) {
    this.mainWord = main;
    this.undercoverWord = undercover;
  }

  /// Randomly assigns roles to players:
  void assignRoles() {
    
    final random = Random();

    // Track indices of players who are special characters
    var mrWhiteIndices = <int>{};
    var undercoverIndices = <int>{};

    // Randomly choose Mr. White indices
    while (mrWhiteIndices.length < this.mrWhites) { // set ensures uniqe indices
      int mrWhiteIndex = random.nextInt(this.players.length);
      mrWhiteIndices.add(mrWhiteIndex);
    }

    // Randomly choose Undercover, different indices than Mr. White
    while (undercoverIndices.length < this.undercovers) {
      int undercoverIndex = random.nextInt(this.players.length);
      // Ensure no overlap with Mr. White
      if (!mrWhiteIndices.contains(undercoverIndex)) {
        undercoverIndices.add(undercoverIndex);
      }
    }

    // Assign roles and words to each player
    for (int i = 0; i < this.players.length; i++) {
      if (mrWhiteIndices.contains(i)) {
        this.players[i].setRole(Role.mrWhite, null); // Mr. White gets no word
      } else if (undercoverIndices.contains(i)) {
        this.players[i].setRole(Role.undercover, this.undercoverWord);
      } else {
        this.players[i].setRole(Role.civilian, this.mainWord);
      }
    }
  }

}