
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<int>> fetchPredictions(List<List<double>> features) async {
    final url = 'http://192.168.1.96:5000/predict'; // Remplacez par l'URL de votre API Flask
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'features': features});

    final response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return List<int>.from(responseData['predictions']);
    } else {
      throw Exception('Failed to load predictions');
    }
  }

  Future<List<int>> getPredictions(double co, double o3, double pm25, double pm10, double so2, double no2) async {
  try {
    // Préparer les caractéristiques pour 24 heures
    List<List<double>> features = [
      [co, o3, pm25, pm10, so2, no2]
      // Répétez cette ligne 24 fois ou remplissez avec des valeurs réelles
    ];

    List<int> predictions = await fetchPredictions(features);
    return predictions;
  } catch (error) {
    // Propagez l'erreur vers le code appelant
    throw Exception('Error fetching predictions: $error');
  }
}
