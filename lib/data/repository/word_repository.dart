/// Middleman between gemini service and cache manager
/// game_view_model only talks to word repository, not API directly
/// first check cache manager for words
/// otherwise asks Gemini for new words
/// saves new words to cache manager
/// give view model pair of words