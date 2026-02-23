// Roles enum
enum Role { civilian, undercover, mrWhite }

/// Player object
class Player {
  
  final String name; // name
  Role role = Role.civilian; // role
  String? word; // word
  bool isEliminated = false; // active status

  Player({required this.name});

  void reset() {
    isEliminated = false; // set to alive
    role = Role.civilian; // temporary no role
    word = null;          // clear word
  }

  void setRole(Role role, String? word) {
    this.role = role;
    this.word = word;
  }
}