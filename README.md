# Mr. White - Flutter Word Game

## Overview

**Mr. White** is a social deduction game built in Flutter. Players are assigned secret roles and words, including Civilians, Undercover, and Mr. White, and must use deduction and discussion to win.



This project is structured using **MVVM (Model-View-ViewModel)** to separate state, logic, and UI.

The project integrates an AI API for word generation with caching, and will eventually support multiplayer gameplay using room codes. It is a cross-platform Flutter application.



## Game Mechanics



### Roles \& Words

* **Civilians:** receive the "main word" (e.g., "Dog"). Win by identifying and eliminating Mr. White.
* **Undercover:** receives a similar but different word (e.g., "Cat). On the same team as Civilians, but unaware they are Undercover.
* **Mr. White:** receives no word. Wins if the civilians fail to vote him out, OR if he guesses the word correctly when eliminated.





### Gameplay

1. Players are assigned roles and words
2. Each player views their word
3. Players take turns describing their word with an associated word (e.g., if a player's word is "Dog", they might say "Fetch")
4. After 1-2 rounds, group votes to eliminate a player they suspect is Mr. White. Civilians are granted one incorrect guess.
5. If civilians eliminate Mr. White, he gets one chance to guess the main word to win. Otherwise, civilians win.
6. Game continues until a winning condition is met.










## Architecture: MVVM



### Model

* Represents the core data of the game
* Includes classes like **Player, Role, Winner**, and **GameState** which hold player info, game progress, and word assignments



### ViewModel

* **GameViewModel** contains game logic and acts as an observable state via ChangeNotifier
* Exposes game state to the views and notifies views when updates occur
* Handles actions such as assigning roles, resolving guesses, eliminating players, and evaluating winners



### View

* Flutter widgets (e.g., **SetupView, VotingView, RoleRevealView, SummaryView**) that observe the **GameViewModel** using context.watch()
* Views update automatically when the ViewModel notifies listeners







## Current Features



* Set up game with player names and configurable numbers of special roles (Mr. White, Undercover)
* Assign words and roles randomly to players
* Track eliminations and evaluate the winner
* Reactive UI via Provider and ChangeNotifier
* Dynamically generated word pairs using Gemini API integration (requires a .env file in assets/.env containing a free-tier Gemini API key)
* Hive databse for caching word pairs locally to avoid repeated API calls







## Future Plans



### AI-Powered Word Generation

* Negative history - exclude recently used words in AI prompt
* Provide local backup word pairs in case API call fails due to high traffic


### Multiplayer Support

* Implement online play with room codes to allow multiple devices to join the same game
* Will include real-time updates of player actions and voting



### Game Phases

* Track phases of the game (e.g., role reveal, discussion, voting, Mr. White guess).
* To simplify state management and make the UI flow more explicit



### Additional Screens

* Start Page with a "Play" button before SetupView
* Intermediate Player Turn Page before voting



### UI Cleanup








## Getting Started



1. **Clone the repository:** git clone https://github.com/keerthikamath01/mr-white-app.git
2. **cd main**
3. **Install dependencies:** flutter pub get
4. **Create a .env file in assets/** containing your Gemini API key: GEMINI\_API\_KEY=your\_free\_tier\_key\_here
5. **Run the app:** flutter run








## Project Structure



lib/

├─ models/          # Player, Role, Winner, GameState

├─ view\_models/     # GameViewModel (ChangeNotifier)

├─ views/           # Flutter UI (SetupView, VotingView, RoleRevealView, SummaryVIew)

├─ widgets/         # Reusable components (e.g., ExitGameButton)

├─ data/         # AI word generation and caching (WordCacheManager, WordRepository, GeminiService)



&nbsp;



