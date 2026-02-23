import 'package:flutter/material.dart';
import '../view_models/game_view_model.dart';
import 'voting_view.dart';
import '../widgets/exit_game_button.dart';
import 'package:provider/provider.dart';

/// RoleRevealView shows each player their role and word (or Mr. White status) one at a time.
class RoleRevealView extends StatefulWidget {

  const RoleRevealView({super.key});

  @override
  State<RoleRevealView> createState() => _RoleRevealViewState();
}


/// Update view state
class _RoleRevealViewState extends State<RoleRevealView> {
  // Tracks whether the current player's role/word has been revealed
  bool revealed = false;

  @override
  Widget build(BuildContext context) {
    final gameViewModel = context.watch<GameViewModel>();

    // Get the current player based on GameViewModel's index
    final player = gameViewModel.getCurrentPlayer();

    return Scaffold(
      
      // Top bar with title
      appBar: AppBar(
        title: const Text("Reveal Role"),
        automaticallyImplyLeading: false,
        actions: [
          ExitGameButton(gameViewModel: gameViewModel),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            // Player name always visible
            Text(
              player.name,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),

            // Conditionally show word OR reveal button
            revealed // this can be moved to the player model
              ? Column( // Show column with word + next button
                  children: [
                    
                    // Reveal word (or Mr. White if no word given)
                    Text(
                      player.word ?? "You are Mr White!",
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 20),

                    // Next button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          revealed = false;
                        });

                        // All players have roles, move to Voting View
                        if (gameViewModel.gameState.currentRevealIndex ==
                            gameViewModel.gameState.players.length - 1) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VotingView(),
                            ),
                          );

                        } else {
                          gameViewModel.nextPlayerReveal(); // Else reveal next player
                        }
                      },
                      child: const Text("Next"),
                    )
                  ],
                )

              // Else, show Reveal button 
              : ElevatedButton(
                  onPressed: () {
                    setState(() {
                      revealed = true; // Revealed is true after pressing
                    });
                  },
                  child: const Text("Reveal"),
                ),
          ],
        ),
      ),
    );
  }
}