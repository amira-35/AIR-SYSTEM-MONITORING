import 'dart:convert';
import 'package:http/http.dart' as http;


Future<Map<String, double>?> getCoordinatesFromCity(String cityName) async {
  final response = await http.get(
    Uri.parse('https://nominatim.openstreetmap.org/search?q=$cityName&format=json&limit=1'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    if (data.isNotEmpty) {
      final Map<String, dynamic> location = data[0];
      return {
        'lat': double.tryParse(location['lat']) ?? 0.0,
        'lon': double.tryParse(location['lon']) ?? 0.0,
      };
    }
  }
  return null;
}
