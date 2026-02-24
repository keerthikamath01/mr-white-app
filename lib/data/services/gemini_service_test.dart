import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// "Remote Data Source." Talks to the Google API and returns a list of words.
Future<void> testGemini() async {
  final apiKey = dotenv.env['GEMINI_API_KEY'];

  // Step 1) Define the Schema for strict JSON output
  final responseSchema = Schema.array(
    items: Schema.object(
      properties: {
        'main': Schema.string(description: 'The primary noun'),
        'undercover': Schema.string(description: 'A similar but distinct noun'),
      },
      requiredProperties: ['main', 'undercover'],
    ),
  );

  // Step 2) Initialize the model (using Gemini 3 Flash for speed)
  final model = GenerativeModel(
    model: 'gemini-3-flash-preview', 
    apiKey: apiKey!,
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json', // Forces JSON format
      responseSchema: responseSchema,      // Forces specific structure

        // INCREASING DIVERSITY:
      temperature: 1.0, // Values between 0.7 and 1.2 good for variety
      topP: 0.95,       // Encourages model to look at more diverse word choices
      
      // OPTIONAL: Use a random seed to force a new "random path"
      //seed: Random().nextInt(1000000),
    ),
  );

  // Step 3) Simple prompt (schema does the work)
  final prompt = 'Generate 5 pairs of nouns that are somewhat similar but not too similar' 
                'for a party game, level easy (e.g., London, Paris or puppy, kitten).';

  // Track time for testing
  final stopwatch = Stopwatch()..start();
  
  try {
    final response = await model.generateContent([Content.text(prompt)]);
    stopwatch.stop();
    print("Response time: ${stopwatch.elapsedMilliseconds}ms");
    
    // With JSON mode, response.text is guaranteed to be parseable JSON
    print(response.text);
  } 

  catch (e) {
    print("Error during generation: $e");
  }

}