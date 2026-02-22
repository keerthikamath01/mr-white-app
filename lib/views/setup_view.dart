import 'package:flutter/material.dart';
import '../view_models/game_view_model.dart';
import 'role_reveal_view.dart';

/// The SetupView allows players to enter their names before starting the game.
class SetupView extends StatefulWidget {
  const SetupView({super.key});

  @override
  State<SetupView> createState() => _SetupViewState();
}

/// Update view state
class _SetupViewState extends State<SetupView> {
  // The GameViewModel manages all game logic, roles, and words
  final GameViewModel gameViewModel = GameViewModel();

  // Controller for the TextField where the user types a player name
  final TextEditingController controller = TextEditingController();

  // List to store the names of players added to the game
  final List<String> playerNames = [];

  // Special counts
  int mrWhiteCount = 1;       // default 1
  int undercoverCount = 1;    // default 1

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // Clean up UI later
      // Top app bar with title
      appBar: AppBar(title: const Text("Mr. White Setup")),
      
      body: Padding(
        padding: const EdgeInsets.all(16),

        // Main column contains all sections
        child: Column(
          children: [
            
            /// Section 1: Player Names
            // TextField for entering a new player's name
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "Enter player name"),
            ),
            const SizedBox(height: 10),

            // Button to add the typed name to the player list
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                final text = value.text;

                return ElevatedButton( // button
                  onPressed: text.isEmpty || playerNames.contains(text) // can only add new names
                      ? null
                      : () {
                          setState(() {
                            playerNames.add(text);
                            controller.clear();
                          });
                        },
                  child: const Text("Add Player"), // button text
                );
              },
            ),
            const SizedBox(height: 20),


            // Display the list of players added so far
            Expanded(
              child: ListView.builder(
                
                itemCount: playerNames.length, // number of players
                itemBuilder: (context, index) {

                  final playerName = playerNames[index];
                  
                  // Show each player's name as a ListTile
                  return ListTile(
                    
                    title: Text(playerName), // Show player name
                    
                    // Add buttons for reordering and removing players
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // Up arrow - move this player up
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          onPressed: index == 0
                            ? null // disables the button and greys it out
                            : () {
                              setState(() {
                                String temp = playerNames[index];
                                playerNames[index] = playerNames[index - 1]; 
                                playerNames[index - 1] = temp;
                              });
                          }
                        ),

                        // Down arrow - move this player down
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          onPressed: index == playerNames.length - 1
                            ? null // disables the button and greys it out
                            : () {
                              setState(() {
                                String temp = playerNames[index];
                                playerNames[index] = playerNames[index + 1]; 
                                playerNames[index + 1] = temp;
                              });
                          }
                        ),

                        // Delete name
                        IconButton(   
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              // Remove the selected player from the list
                              playerNames.removeAt(index);
                              
                              // Reduce special characters according to new player count
                              int specialsToReduce = gameViewModel.specialsToReduce(
                                totalPlayers: playerNames.length, 
                                currentWhites: mrWhiteCount, 
                                currentUndercovers: undercoverCount);
                              
                              // Delete Mr. Whites over limit then Undercovers over limit
                              while ( specialsToReduce > 0 ) {
                                mrWhiteCount > 1 ? mrWhiteCount-- : undercoverCount--;
                                specialsToReduce--;
                              }

                            });
                          },
                        ),

                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),


            /// Section 2: Roles (Modular sub-section)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Roles title
                    const Text(
                      "Roles",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    // Display total players (clean this up)
                    Text(
                      "Total Players: ${playerNames.length}", // dynamic total
                      style: const TextStyle(fontSize: 16),
                    ),
                    
                    // Mr. White selector row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Mr. White"),
                        Row(
                          children: [

                            // Decrement Mr. White button - 
                            IconButton(
                              icon: const Icon(Icons.remove),
                              // Check if Mr. White can be removed
                              onPressed: gameViewModel.canRemoveRole( 
                                currentWhites: mrWhiteCount, 
                                currentUndercovers: undercoverCount, 
                                role: "white")
                              ? () {
                                  setState(() {
                                    mrWhiteCount--; // Reduce Mr. White count
                                  });
                                } : null,
                            ),
                            Text("$mrWhiteCount"),
                            
                            // Increment Mr. White button +
                            IconButton(
                              icon: const Icon(Icons.add),
                              // Check if Mr. White can be added
                              onPressed: gameViewModel.canAddRole(
                                totalPlayers: playerNames.length,
                                currentWhites: mrWhiteCount,
                                currentUndercovers: undercoverCount,
                                role: "white")
                                ? () { 
                                  setState(() { 
                                    mrWhiteCount++; // Increase Mr. White count
                                  }); 
                                } : null,
                                
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Undercover selector row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Undercover"),
                        Row(
                          children: [

                            // Decrement Undercovers button -
                            IconButton(
                              icon: const Icon(Icons.remove),
                              // Check if Undercover can be removed
                              onPressed: gameViewModel.canRemoveRole(
                                currentWhites: mrWhiteCount, 
                                currentUndercovers: undercoverCount, 
                                role: "undercover")
                              ? () {
                                  setState(() {
                                    undercoverCount--; // Reduce Undercover count
                                  });
                                } : null,
                            ),
                            Text("$undercoverCount"),

                            // Increment Undercovers button +
                            IconButton(
                              icon: const Icon(Icons.add),
                              // Check if Undercover can be added
                              onPressed: gameViewModel.canAddRole(
                                totalPlayers: playerNames.length,
                                currentWhites: mrWhiteCount,
                                currentUndercovers: undercoverCount,
                                role: "undercover")
                                ? () { 
                                  setState(() { 
                                    undercoverCount++; // Increase Undercover count
                                  }); 
                                } : null, // greyed out if limit reached
                            ),
                          ],
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),


            // Start Game button - disabled until at least 4 players are added
            ElevatedButton(
              onPressed: playerNames.length < 4
                  ? null // Disable if not enough players
                  : () {
                      // Set up the game in the GameViewModel with the entered names
                      gameViewModel.setupGame(playerNames, mrWhiteCount, undercoverCount);

                      // Navigate to the RoleRevealView to start revealing roles
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RoleRevealView(gameViewModel: gameViewModel),
                        ),
                      );
                    },
              child: const Text("Start Game"),
            ),

          ],
        ),
      ),
    );
  }


}