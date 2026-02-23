import 'dart:math'; 
import '../models/player.dart';
import '../models/game_state.dart';

// things to add
// set max players to 10
// add toggle to make undercovers a separate team from civilians and add game logic

// Fix start game / reset game logic for handling players

// add a view before setup_view with "Play" and "Instructions" buttons 
// main should route here
// edit navigator accordingly, currently all exit/reset buttons navigate to route.isFirst


/// GameViewModel contains all the logic for the Mr. White game.
/// Handles players, roles, words, reveals, eliminations, and determining the winner.
class GameViewModel {
  
  // Hold all game state
  GameState _gameState = GameState(players: []);

  // Getter for state
  GameState get gameState => _gameState;

  // Predefined word pairs for testing
  // Replace with AI API
  final List<Map<String, String>> wordPairs = [
    {"main": "Cat", "undercover": "Tiger"},
    {"main": "Beach", "undercover": "Desert"},
    {"main": "Pizza", "undercover": "Burger"},
  ];


  // Reset game
  void reset() {
    _gameState.currentRevealIndex = 0;
    _gameState.winner = Winner.none;

    // Reset all players
    // Currently players are re-initialized anyways?
    for (final player in _gameState.players) {
      player.isEliminated = false; // set to alive
      player.role = Role.civilian; // temporary no role
      player.word = null;          // clear word
    }

    // Optional
    _gameState.mainWord = null;
    _gameState.undercoverWord = null;
  }

  /// Sets up the game with a list of player names
  /// Converts names into Player objects, then assigns words and roles
  void setupGame(List<String> playerNames, int mrWhites, int undercovers) {
    
    _gameState.winner = Winner.none; // redundant?
    
    // Don't need to re-initialize the same players after restarting??
    // But what if we add/remove players
    _gameState.players = playerNames.map((name) => Player(name: name)).toList();
    
    // Number of whites and undercovers
    _gameState.mrWhites = mrWhites;
    _gameState.undercovers = undercovers;
    
    // Assign words and roles
    _assignWords();
    _assignRoles();
  }

  /// Randomly selects a word pair for the game
  void _assignWords() {
    final random = Random(); // Better way to randomize?
    final pair = wordPairs[random.nextInt(wordPairs.length)];
    _gameState.mainWord = pair["main"]; // Need to replace this logic later for AI API
    _gameState.undercoverWord = pair["undercover"];
  }


  /// Randomly assigns roles to players:
  void _assignRoles() {
    
    final random = Random();

    // Track indices of players who are special characters
    var mrWhiteIndices = <int>{};
    var undercoverIndices = <int>{};

    // Randomly choose Mr. White indices
    while (mrWhiteIndices.length < _gameState.mrWhites) { // set ensures uniqe indices
      int mrWhiteIndex = random.nextInt(_gameState.players.length);
      mrWhiteIndices.add(mrWhiteIndex);
    }

    // Randomly choose Undercover, different indices than Mr. White
    while (undercoverIndices.length < _gameState.undercovers) {
      int undercoverIndex = random.nextInt(_gameState.players.length);
      // Ensure no overlap with Mr. White
      if (!mrWhiteIndices.contains(undercoverIndex)) {
        undercoverIndices.add(undercoverIndex);
      }
    }

    // Assign roles and words to each player
    for (int i = 0; i < _gameState.players.length; i++) {
      if (mrWhiteIndices.contains(i)) {
        _gameState.players[i].role = Role.mrWhite;
        _gameState.players[i].word = null; // Mr. White gets no word
      } else if (undercoverIndices.contains(i)) {
        _gameState.players[i].role = Role.undercover;
        _gameState.players[i].word = _gameState.undercoverWord;
      } else {
        _gameState.players[i].role = Role.civilian;
        _gameState.players[i].word = _gameState.mainWord;
      }
    }
  }

  /// Returns the current player whose role is being revealed
  Player getCurrentPlayer() => _gameState.players[_gameState.currentRevealIndex];

  /// Advances to the next player in the reveal sequence
  void nextPlayerReveal() {
    if (_gameState.currentRevealIndex < _gameState.players.length - 1) {
      _gameState.currentRevealIndex++;
    }
  }

  /// Marks a player as eliminated
  void eliminatePlayer(Player player) {
    player.isEliminated = true;
  }

  /// Determine if game is over
  bool get isGameOver {
    if (_gameState.winner != Winner.none) return true; // If a winner is already assigned, end game
    _evaluateGameState(); // Evaluate/assign winner based on remaining players
    return _gameState.winner != Winner.none;
  }

  /// Assign Mr. White as winner if correct word is guessed
  void resolveMrWhiteGuess(String guess) {
    if (guess.toLowerCase() == _gameState.mainWord?.toLowerCase()) {
      _gameState.winner = Winner.mrWhite;
    } 
  }

  /// Evaluate if any team has won based on remaining players
  void _evaluateGameState() {
    // Non-eliminated players
    final activePlayers =
        _gameState.players.where((p) => !p.isEliminated).toList(); // sets instead of lists?

    // Total non Mr. White (Undercovers + Civilians)
    // Can possibly just do total players - mr white count
    final nonMrWhite =
        _gameState.players.where((p) => p.role != Role.mrWhite).toList();

    // Non-eliminated non Mr. White (Undercovers + Civilians)
    final activeNonMrWhite =
        activePlayers.where((p) => p.role != Role.mrWhite).length;

    // Eliminated Civilians + Undercovers
    final eliminatedNonMrWhite =
        nonMrWhite.length - activeNonMrWhite;

    // Is Mr. White alive?
    final mrWhiteAlive =
        activePlayers.any((p) => p.role == Role.mrWhite);

    // Civilians win condition
    if (!mrWhiteAlive) { // If White is dead
      _gameState.winner = Winner.civilians;
      return;
    }

    // Mr. White win condition
    if (eliminatedNonMrWhite >= 2) { // 2 wrong eliminations
      _gameState.winner = Winner.mrWhite;
      return;
    }

    // Else, no winner yet and game continues

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

  /// Check if this role can be added to the game based on existing roles/players
  bool canAddRole({
    required int totalPlayers,
    required int currentWhites,
    required int currentUndercovers,
    required String role, // "white" or "undercover"
  }) {
    // Determine max special characters (White + Undercover) allowed based on total players
    int totalSpecialsMax = getTotalSpecialsMax(totalPlayers);

    // Determine max allowed per role
    int perRoleMax = getPerRoleMax(totalPlayers); // 5 or 6?

    // Current special characters
    int currentTotalSpecials = currentWhites + currentUndercovers;

    // Check both conditions
    bool underPerRoleMax = (role == "white" ? currentWhites < perRoleMax
                                            : currentUndercovers < perRoleMax);

    bool underTotalMax = currentTotalSpecials < totalSpecialsMax;

    return underPerRoleMax && underTotalMax;
  }


  /// Determine if this role can be removed from the game
  bool canRemoveRole({
    required int currentWhites,
    required int currentUndercovers,
    required String role})  {
    
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
    //return excess > 0 ? excess : 0;
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