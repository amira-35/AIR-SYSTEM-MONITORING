import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart';

Future<double?> getAQIFromFirebase(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] as double?;
      double? longitude = region['Longitude'] as double?;
      double? AQI = region['AQI'] as double?;
      if (latitude == position.latitude && longitude == position.longitude) {
        return AQI;
      }
    }
  } else {
    print('No data found.');
    return 50;
  }
  return null;
}

Future<int?> getWindSpeedForPosition(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.
  value as Map<dynamic, dynamic>?;

  if (data != null) {
    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] as double?;
      double? longitude = region['Longitude'] as double?;
      int? speed = region['Vitesse vent'] as int?;
      if (latitude == position.latitude && longitude == position.longitude) {
        return speed;
      }
    }
  } else {
    print('No data found.');
    return 5;
  }
  return null;
}

Future<int?> getWindDirectionForPosition(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.
  value as Map<dynamic, dynamic>?;

  if (data != null) {
    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] as double?;
      double? longitude = region['Longitude'] as double?;
      int? direction = region['Direction vent'] as int?;
      if (latitude == position.latitude && longitude == position.longitude) {
        return direction;
      }
    }
  } else {
    print('No data found.');
    return 110;
  }
  return null;
}


/*void _fetchDataFromFirebase() {
    final databaseReference = FirebaseDatabase.instance.reference().child('Region');
    databaseReference.onValue.listen((event) {
      Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        data.forEach((key, value) {
          Map<String, dynamic> entry = Map<String, dynamic>.from(value);
          double? latitude = entry['Latitude'] as double?;
          double? longitude = entry['Longitude'] as double?;
          double? AQI = entry['AQI'] as double?;
          if (latitude != null && longitude != null) {
           
          }
        });
      } else {
        print('No data found.');
      }
    });
  }*/

