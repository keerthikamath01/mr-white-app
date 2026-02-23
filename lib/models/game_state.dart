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


  /// Randomly assigns roles to players (depends on words already assigned)
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

  /// Returns the current player whose role is being revealed
  Player getCurrentPlayer() => players[currentRevealIndex];

  /// Advances to the next player in the reveal sequence
  void nextReveal() {
    if (currentRevealIndex < players.length - 1) currentRevealIndex++;
  }

  /// Marks a player as eliminated
  void eliminatePlayer(Player player) => player.eliminate();

  /// Determine if game is over
  bool checkGameOver() {
    if (winner != Winner.none) return true; // If a winner is already assigned, end game

    // Otherwise, evaluate if any team has won based on remaining players

    // Non-eliminated players
    final activePlayers = players.where((p) => !p.isEliminated).toList(); // sets instead of lists?

    // Total non Mr. White (Undercovers + Civilians)
    // Can possibly just do total players - mr white count
    final nonMrWhite = players.where((p) => p.role != Role.mrWhite).toList();

    // Non-eliminated non Mr. White (Undercovers + Civilians)
    final activeNonMrWhite =
        activePlayers.where((p) => p.role != Role.mrWhite).length;

    // Eliminated Civilians + Undercovers
    final eliminatedNonMrWhite = nonMrWhite.length - activeNonMrWhite;

    // Is Mr. White Alive?
    final mrWhiteAlive = activePlayers.any((p) => p.role == Role.mrWhite);

    // Civilians win condition
    if (!mrWhiteAlive) { // If White is dead
      winner = Winner.civilians;
      return true;
    }

    // Mr. White win condition
    if (eliminatedNonMrWhite >= 2) { // 2 wrong eliminations
      winner = Winner.mrWhite;
      return true;
    }

    // Else, no winner yet and game continues
    return false;
  }

  /// Assign Mr. White as winner if correct word is guessed
  void resolveMrWhiteGuess(String guess) {
    if (guess.toLowerCase() == mainWord?.toLowerCase()) {
      winner = Winner.mrWhite;
    }
  }

  /// Role management functions below
  ///
  /// Check if this role can be added to the game based on existing roles/players
  bool canAddRole({
    required int totalPlayers,
    required int currentWhites,
    required int currentUndercovers,
    required String role,
  }) {

    // Determine max special characters (White + Undercover) allowed based on total players
    int totalSpecialsMax = getTotalSpecialsMax(totalPlayers);

    // Determine max allowed per role
    int perRoleMax = getPerRoleMax(totalPlayers);

    // Current special characters
    int currentTotalSpecials = currentWhites + currentUndercovers;

    // Check both conditions
    bool underPerRoleMax =
        (role == "white" ? currentWhites < perRoleMax : currentUndercovers < perRoleMax);
    bool underTotalMax = currentTotalSpecials < totalSpecialsMax;

    return underPerRoleMax && underTotalMax;
  }

  /// Determine if this role can be removed from the game
  bool canRemoveRole({
    required int currentWhites,
    required int currentUndercovers,
    required String role,
  }) {

    // There must be at least one special character
    bool roleNonzero = (role == "white" ? currentWhites > 0 : currentUndercovers > 0);
    return roleNonzero && (currentWhites + currentUndercovers > 1);
  }

  /// If players are deleted, re-evaluate number of special characters accordingly
  int specialsToReduce({
    required int totalPlayers,
    required int currentWhites,
    required int currentUndercovers,
  }) {

    // Evaluate total special characters allowed
    final totalSpecialsMax = getTotalSpecialsMax(totalPlayers);
    final currentTotalSpecials = currentWhites + currentUndercovers;
    final excessTotal = currentTotalSpecials - totalSpecialsMax;

    // Allowed per role
    final perRoleMax = getPerRoleMax(totalPlayers);
    final excessRole = max(currentWhites, currentUndercovers) - perRoleMax;

    // Excess characters - need to remove
    final excess = max(excessTotal, excessRole);
    return excess;
  }

  /// Max of each special character allowed
  int getPerRoleMax(int totalPlayers) { 
    return totalPlayers <= 5 ? 1 : 2; // 5 or 6? 
  }

  /// Maximum total specials allowed based on number of players
  int getTotalSpecialsMax(int totalPlayers) { 
    if (totalPlayers <= 6) return 2; // 2 specials total 
    if (totalPlayers == 7) return 3; // 3 specials total 
    return 4; // 8+ players 
  }

}



