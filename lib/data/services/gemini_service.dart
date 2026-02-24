import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// "Remote Data Source." Talks to the Google API and returns a list of words.
class GeminiService {
  // 1. Declare the model as a class property so fetchNewWordPairs can see it
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) throw Exception("API Key not found in .env");

    // 2. Define the Schema using named constructors
    final responseSchema = Schema.array(
      items: Schema.object(
        properties: {
          'main': Schema.string(description: 'The primary noun'),
          'undercover': Schema.string(description: 'A similar but distinct noun'),
        },
        requiredProperties: ['main', 'undercover'],
      ),
    );

    // 3. Initialize the model inside the constructor
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: responseSchema,
        temperature: 1.0,
        topP: 0.95,
      ),
      systemInstruction: Content.system(
        'You are a word game generator. Always return valid JSON arrays.'
      ),
    );
  }

  // 4. Moved the prompt here or keep it as a constant
  // change to 20
  static const _promptText = 
      'Generate 5 pairs of nouns that are somewhat similar but not too similar '
      'for a party game, level easy (e.g., London, Paris or puppy, kitten).';

  Future<List<Map<String, dynamic>>> fetchNewWordPairs() async {
    try {
      // Use the class property _model
      final response = await _model.generateContent([Content.text(_promptText)]);
      
      if (response.text == null) return [];

      // 5. Safely parse the JSON
      final List<dynamic> decoded = jsonDecode(response.text!);
      return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      
    } catch (e) {
      print("Error fetching word pairs: $e");
      return [];
    }
  }
}