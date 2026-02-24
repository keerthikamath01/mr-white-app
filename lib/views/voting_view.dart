import 'package:flutter/material.dart';
import '../view_models/game_view_model.dart';
import '../models/player.dart';
import 'summary_view.dart';
import '../widgets/exit_game_button.dart';
import 'package:provider/provider.dart';

/// Voting View displays player names and allows group to vote out a player.
class VotingView extends StatefulWidget {

  const VotingView({super.key});

  @override
  State<VotingView> createState() => _VotingViewState();
}


/// Update view state
class _VotingViewState extends State<VotingView> {
  @override
  Widget build(BuildContext context) {
    final gameViewModel = context.watch<GameViewModel>(); // rebuilds when notifyListeners() is called
    
    // Get active (non-eliminated) players
    final activePlayers =
        gameViewModel.gameState.players.where((p) => !p.isEliminated).toList();

    return Scaffold(
      
      appBar: AppBar(
        title: const Text("Voting"),
        automaticallyImplyLeading: false,
        actions: [
          ExitGameButton(),
        ],
      ),
      
      // Player names list
      body: ListView.builder(
        itemCount: activePlayers.length, // number players alive
        itemBuilder: (context, index) {
          final player = activePlayers[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(player.name), // show each living player name as a ListTile
              onTap: () {
                _handleVote(player); // logic if voted out
              },
            ),
          );
        },
      ),
    );
  }

  /// Logic for when a player is voted out
  void _handleVote(Player player) {
    final gameViewModel = context.read<GameViewModel>();
    gameViewModel.eliminatePlayer(player); // Eliminate player

    if (player.role == Role.mrWhite) { // Mr. White voted out
      _showMrWhiteGuessPopup(context); // Mr. White guess popup
    } 

    else { // Civilian/Undercover voted out
      // Determine if game is over
      if (gameViewModel.isGameOver) { // If game over, go to Summary view
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SummaryView(),
          ),
        );
      } 
    }
  }

  /// Show popup for Mr. White to guess word when voted out
  void _showMrWhiteGuessPopup(BuildContext context) {

    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        
        return AlertDialog(
          
          // Title/text
          title: const Text("Mr. White Guess"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("You were chosen! Guess the word:"),
              const SizedBox(height: 10),
              TextField(controller: controller), // Entry box
            ],
          ),
          
          // Submit guess button
          actions: [
            ElevatedButton(
              onPressed: () {
                final guess = controller.text.trim(); // get guess

                final gameViewModel = context.read<GameViewModel>();
                // Check the guess in the GameViewModel
                gameViewModel.resolveMrWhiteGuess(guess);

                Navigator.pop(context); // close dialog

                // If game over, navigate to Summary view
                if (gameViewModel.isGameOver) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SummaryView(),
                    ),
                  );
                } 
                else { // Else, continue the voting UI
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Incorrect guess! Game continues."),
                    ),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
        
      },
    );
  }

}