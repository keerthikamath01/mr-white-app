import 'package:hive_ce_flutter/hive_ce_flutter.dart';

/// "Local Data Source." 
/// Save/load words from the phone's memory (using Hive).
class WordCacheManager {
  static const String _boxName = 'word_cache'; // Name of box/database

  // Function to open the box (database)
  Future<Box> _getBox() async => await Hive.openBox(_boxName); // open Hive database

  // Save a list of JSON word pairs to cache
  // Call this save function when a new list of word pairs is generated from Gemini
  Future<void> saveWordPairs(List<Map<String, dynamic>> pairs) async {
    final box = await _getBox();
    // Store the words as a list of maps
    await box.put('cached_words', pairs);
  }

  // Get all cached pairs from database
  Future<List<Map<String, String>>> getCachedPairs() async {
    final box = await _getBox(); // database
    final data = box.get('cached_words'); // get cached words

    if (data == null) return [];

    // Cast outer object to a List
    final List listData = data as List;

    // Convert each item in list to a Map<String, String>
    return listData.map((item) {
      return Map<String, String>.from(item as Map);
    }).toList();
  }

  // Clear cache after we use them
  Future<void> clearCache() async {
    final box = await _getBox();
    await box.clear();
  }
}