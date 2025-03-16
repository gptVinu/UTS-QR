import 'dart:async';
import 'dart:math';

class VoiceRecognitionHelper {
  // This would typically use platform-specific speech recognition
  // For now, we're simulating it with random responses

  static final List<String> _sampleStations = [
    'Churchgate',
    'Mumbai Central',
    'Dadar',
    'Bandra',
    'Andheri',
    'Borivali',
    'CSMT',
    'Thane',
    'Kurla',
    'Vashi',
  ];

  static Future<String> recognizeSpeech() async {
    // Simulate listening and processing time
    final random = Random();
    await Future.delayed(Duration(milliseconds: 2000 + random.nextInt(1000)));

    // Return random station from the sample list
    return _sampleStations[random.nextInt(_sampleStations.length)];
  }
}
