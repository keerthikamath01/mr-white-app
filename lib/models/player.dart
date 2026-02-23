// Roles enum
enum Role { civilian, undercover, mrWhite }

/// Player object
class Player {
  
  final String name; // name
  Role role; // role
  String? word; // word
  bool isEliminated; // active status

  Player({
    required this.name,
    this.role = Role.civilian,
    this.word,
    this.isEliminated = false,
  });

  void resetPlayer() {
    this.isEliminated = false; // set to alive
    this.role = Role.civilian; // temporary no role
    this.word = null;          // clear word
  }

  void setRole(Role role, String? word) {
    this.role = role;
    this.word = word;
  }
}