import 'package:flutter/material.dart';
import '../view_models/game_view_model.dart';

/// SummaryView displays the Winner, player names/roles/words, and provides the option to restart.
class SummaryView extends StatelessWidget {
  // The game logic and state for this game session
  final GameViewModel gameViewModel;

  const SummaryView({super.key, required this.gameViewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text("Game Summary"),
        automaticallyImplyLeading: false,
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Winner message
            Text(
              gameViewModel.winnerMessage,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // List of player names, roles, and words
            Expanded(
              child: ListView(
                children: gameViewModel.players.map((player) {
                  return ListTile(
                    title: Text(player.name),
                    subtitle: Text(
                        "Role: ${player.role.name} | Word: ${player.word ?? "None"}"),
                  );
                }).toList(),
              ),
            ),

            // Reset game
            ElevatedButton(
              onPressed: () {
                gameViewModel.reset();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Back to Setup"),
            )

          ],
        ),
      ),

    );
  }
}