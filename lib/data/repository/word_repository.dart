import '../local/word_cache_manager.dart';
import '../services/gemini_service.dart';

/// Middleman between gemini service and cache manager
/// game_view_model only talks to word repository, not API directly
/// first check cache manager for words
/// otherwise asks Gemini for new words
/// saves new words to cache manager
/// give view model pair of words
class WordRepository {
  final GeminiService _geminiService;
  final WordCacheManager _cacheManager;

  WordRepository(this._geminiService, this._cacheManager);


  /// Get next word pair from cache,
  /// Or if cache empty, fetch new list of word pairs from Gemini
  /// And save the new list to cache
  Future<Map<String, String>> getNextWordPair() async {
    // 1. Check the local cache first
    List<Map<String, dynamic>> cached = await _cacheManager.getCachedPairs();

    // 2. If cache is empty, fetch from Gemini
    if (cached.isEmpty) {
      print("Cache empty! Fetching from Gemini...");
      final newPairs = await _geminiService.fetchNewWordPairs(); // fetch new word pairs
      
      // Save all AI-generated pairs to cache
      await _cacheManager.saveWordPairs(newPairs);
      cached = newPairs;
    }

    // 3. Take the first pair from the list and remove it from local cached List
    final nextPair = Map<String, String>.from(cached.removeAt(0));

    // 4. Update the cache with the remaining pairs in local cached list
    await _cacheManager.saveWordPairs(cached);

    return nextPair; // return the word pair
  }
}