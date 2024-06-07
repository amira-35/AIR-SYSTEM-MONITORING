
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> fetchPrediction(List<double> features) async {
  final response = await http.post(
    Uri.parse('http://127.0.0.1:5000/predict'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'features': features}),
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    print('Prediction: ${result['prediction']}');
  } else {
    throw Exception('Failed to load prediction');
  }
}
