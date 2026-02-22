import 'package:flutter/material.dart';
import '../view_models/game_view_model.dart';

/// Exit game widget, reusable
/// At top of multiple views
class ExitGameButton extends StatelessWidget {
  final GameViewModel gameViewModel;

  const ExitGameButton({
    super.key,
    required this.gameViewModel,
  });

  // Function to confirm exit in alert dialog
  Future<bool> _confirmExit(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Exit Game"),
        content: const Text("Are you sure you want to exit?"),
        actions: [

          // Cancel
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(false),
            child: const Text("Cancel"),
          ),

          // Confirm exit
          TextButton(
            onPressed: () {
                gameViewModel.reset(); // reset game
                Navigator.of(dialogContext).pop(true);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text("Exit"),
          ),
        ],
      ),
    ) ??
    false;
  }

  // Exit button
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final shouldExit = await _confirmExit(context); // alert dialog pops up

        if (!context.mounted) return;

        if (shouldExit) {
          gameViewModel.reset();
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
      child: const Text(
        "Exit",
        style: TextStyle(color: Colors.red),
      ),
    );
  }
  
}