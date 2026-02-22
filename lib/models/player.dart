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
}