import 'dart:ui';

import 'package:AirNow/constants/dev_flags.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

// les getters

Future<double?> getAQIFromFirebase(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    double? closestAQI;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] as double?;
      double? longitude = region['Longitude'] as double?;
      double? AQI = region['AQI'] as double?;
      if (latitude != null && longitude != null && AQI != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          return AQI;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestAQI = AQI;
        }
      }
    }

    if (closestAQI != null) {
      if (enableDebugLogs) print('Returning AQI for closest position $closestPosition.');
      return closestAQI;
    } else {
      if (enableDebugLogs) print('No AQI data found.');
    }
  } else {
    if (enableDebugLogs) print('No data found.');
  }
  return null;
}

Future<double?> getWindSpeedForPosition(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    double? closestSpeed;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] is int ? (region['Latitude'] as int).toDouble() : region['Latitude'] as double?;
      double? longitude = region['Longitude'] is int ? (region['Longitude'] as int).toDouble() : region['Longitude'] as double?;
      double? speed = region['Vitesse vent'] is int ? (region['Vitesse vent'] as int).toDouble() : region['Vitesse vent'] as double?;
      if (latitude != null && longitude != null && speed != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          if (enableDebugLogs) print('Windspeed for position $position: $speed');
          return speed;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestSpeed = speed;
        }
      }
    }

    if (closestSpeed != null) {
      if (enableDebugLogs) print('Returning wind speed for closest position $closestPosition.' + '=> $closestSpeed');

      return closestSpeed;
    } else {
      if (enableDebugLogs) print('No wind speed data found.');
      return 5; // Default value if no data is found
    }
  } else {
    if (enableDebugLogs) print('No data found.');
    return 5; // Default value if no data is found
  }
}

Future<double?> getWindDirectionForPosition(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    double? closestDirection;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] is int ? (region['Latitude'] as int).toDouble() : region['Latitude'] as double?;
      double? longitude = region['Longitude'] is int ? (region['Longitude'] as int).toDouble() : region['Longitude'] as double?;
      double? direction = region['Direction vent'] is int ? (region['Direction vent'] as int).toDouble() : region['Direction vent'] as double?;
      if (latitude != null && longitude != null && direction != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          return direction;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestDirection = direction;
        }
      }
    }

    if (closestDirection != null) {
      if (enableDebugLogs) print('Returning wind direction for closest position $closestPosition.');
      return closestDirection;
    } else {
      if (enableDebugLogs) print('No wind direction data found.');
    }
  } else {
    if (enableDebugLogs) print('No data found.');
  }
  return null;
}

Future<T?> _getAttributeFromFirebase<T>(LatLng position, String attribute, T defaultValue) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    T? closestValue;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] is int ? (region['Latitude'] as int).toDouble() : region['Latitude'] as double?;
      double? longitude = region['Longitude'] is int ? (region['Longitude'] as int).toDouble() : region['Longitude'] as double?;
      if (latitude != null && longitude != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          return region[attribute] as T?;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestValue = region[attribute] as T?;
        }
      }
    }

    if (closestValue != null) {
      if (enableDebugLogs) print('Returning $attribute for closest position $closestPosition.');
      return closestValue;
    }
  }

  if (enableDebugLogs) print('No data found for $attribute. Returning default value.');
  return defaultValue;
}

Future<double?> getTemperatureFromFirebase(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    double? closestDirection;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] is int ? (region['Latitude'] as int).toDouble() : region['Latitude'] as double?;
      double? longitude = region['Longitude'] is int ? (region['Longitude'] as int).toDouble() : region['Longitude'] as double?;
      double? temp = region['Température'] is int ? (region['Température'] as int).toDouble() : region['Température'] as double?;
      if (latitude != null && longitude != null && temp != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          return temp;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestDirection = temp;
        }
      }
    }

    if (closestDirection != null) {
      if (enableDebugLogs) print('Returning wind direction for closest position $closestPosition.');
      return closestDirection;
    } else {
      if (enableDebugLogs) print('No wind direction data found.');
    }
  } else {
    if (enableDebugLogs) print('No data found.');
  }
  return null;
}

Future<double?> getAQICategoryFromFirebase(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    double? closestDirection;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] is int ? (region['Latitude'] as int).toDouble() : region['Latitude'] as double?;
      double? longitude = region['Longitude'] is int ? (region['Longitude'] as int).toDouble() : region['Longitude'] as double?;
      double? aqicat = region['AQI Category'] is int ? (region['AQI Category'] as int).toDouble() : region['AQI Category'] as double?;

      if (latitude != null && longitude != null && aqicat != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          return aqicat;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestDirection = aqicat;
        }
      }
    }

    if (closestDirection != null) {
      if (enableDebugLogs) print('Returning wind direction for closest position $closestPosition.');
      return closestDirection;
    } else {
      if (enableDebugLogs) print('No wind direction data found.');
    }
  } else {
    if (enableDebugLogs) print('No data found.');
  }
  return null;
}

Future<double?> getCOFromFirebase(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    double? closestDirection;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] is int ? (region['Latitude'] as int).toDouble() : region['Latitude'] as double?;
      double? longitude = region['Longitude'] is int ? (region['Longitude'] as int).toDouble() : region['Longitude'] as double?;
      double? co = region['CO'] is int ? (region['CO'] as int).toDouble() : region['CO'] as double?;

      if (latitude != null && longitude != null && co != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          return co;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestDirection = co;
        }
      }
    }

    if (closestDirection != null) {
      if (enableDebugLogs) print('Returning wind direction for closest position $closestPosition.');
      return closestDirection;
    } else {
      if (enableDebugLogs) print('No wind direction data found.');
    }
  } else {
    if (enableDebugLogs) print('No data found.');
  }
  return null;
}

Future<double?> getHumiditeFromFirebase(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    double? closestDirection;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] is int ? (region['Latitude'] as int).toDouble() : region['Latitude'] as double?;
      double? longitude = region['Longitude'] is int ? (region['Longitude'] as int).toDouble() : region['Longitude'] as double?;
      double? Humidity = region['Humidité'] is int ? (region['Humidité'] as int).toDouble() : region['Humidité'] as double?;

      if (latitude != null && longitude != null && Humidity != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          return Humidity;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestDirection = Humidity;
        }
      }
    }

    if (closestDirection != null) {
      if (enableDebugLogs) print('Returning wind direction for closest position $closestPosition.');
      return closestDirection;
    } else {
      if (enableDebugLogs) print('No wind direction data found.');
    }
  } else {
    if (enableDebugLogs) print('No data found.');
  }
  return null;
}

Future<double?> getNO2FromFirebase(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    double? closestDirection;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] is int ? (region['Latitude'] as int).toDouble() : region['Latitude'] as double?;
      double? longitude = region['Longitude'] is int ? (region['Longitude'] as int).toDouble() : region['Longitude'] as double?;
      double? NO2 = region['NO2'] is int ? (region['NO2'] as int).toDouble() : region['NO2'] as double?;

      if (latitude != null && longitude != null && NO2 != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          return NO2;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestDirection = NO2;
        }
      }
    }

    if (closestDirection != null) {
      if (enableDebugLogs) print('Returning wind direction for closest position $closestPosition.');
      return closestDirection;
    } else {
      if (enableDebugLogs) print('No wind direction data found.');
    }
  } else {
    if (enableDebugLogs) print('No data found.');
  }
  return null;
}

Future<double?> getO3FromFirebase(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    double? closestDirection;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] is int ? (region['Latitude'] as int).toDouble() : region['Latitude'] as double?;
      double? longitude = region['Longitude'] is int ? (region['Longitude'] as int).toDouble() : region['Longitude'] as double?;
      double? O3 = region['O3'] is int ? (region['O3'] as int).toDouble() : region['O3'] as double?;

      if (latitude != null && longitude != null && O3 != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          return O3;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestDirection = O3;
        }
      }
    }

    if (closestDirection != null) {
      if (enableDebugLogs) print('Returning wind direction for closest position $closestPosition.');
      return closestDirection;
    } else {
      if (enableDebugLogs) print('No wind direction data found.');
    }
  } else {
    if (enableDebugLogs) print('No data found.');
  }
  return null;
}

Future<double?> getPM10FromFirebase(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    double? closestDirection;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] is int ? (region['Latitude'] as int).toDouble() : region['Latitude'] as double?;
      double? longitude = region['Longitude'] is int ? (region['Longitude'] as int).toDouble() : region['Longitude'] as double?;
      double? PM10 = region['PM10'] is int ? (region['PM10'] as int).toDouble() : region['PM10'] as double?;

      if (latitude != null && longitude != null && PM10 != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          return PM10;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestDirection = PM10;
        }
      }
    }

    if (closestDirection != null) {
      if (enableDebugLogs) print('Returning wind direction for closest position $closestPosition.');
      return closestDirection;
    } else {
      if (enableDebugLogs) print('No wind direction data found.');
    }
  } else {
    if (enableDebugLogs) print('No data found.');
  }
  return null;
}

Future<double?> getPM25FromFirebase(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    double? closestDirection;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] is int ? (region['Latitude'] as int).toDouble() : region['Latitude'] as double?;
      double? longitude = region['Longitude'] is int ? (region['Longitude'] as int).toDouble() : region['Longitude'] as double?;
      double? PM25 = region['PM25'] is int ? (region['PM25'] as int).toDouble() : region['PM25'] as double?;

      if (latitude != null && longitude != null && PM25 != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          return PM25;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestDirection = PM25;
        }
      }
    }

    if (closestDirection != null) {
      if (enableDebugLogs) print('Returning wind direction for closest position $closestPosition.');
      return closestDirection;
    } else {
      if (enableDebugLogs) print('No wind direction data found.');
    }
  } else {
    if (enableDebugLogs) print('No data found.');
  }
  return null;
}

Future<double?> getSO2FromFirebase(LatLng position) async {
  final databaseReference = FirebaseDatabase.instance.reference().child('Region');
  DatabaseEvent event = await databaseReference.once();
  DataSnapshot snapshot = event.snapshot;
  Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

  if (data != null) {
    LatLng? closestPosition;
    double? closestDirection;
    double closestDistance = double.infinity;

    for (var entry in data.values) {
      Map<String, dynamic> region = Map<String, dynamic>.from(entry);
      double? latitude = region['Latitude'] is int ? (region['Latitude'] as int).toDouble() : region['Latitude'] as double?;
      double? longitude = region['Longitude'] is int ? (region['Longitude'] as int).toDouble() : region['Longitude'] as double?;
      double? SO2 = region['SO2'] is int ? (region['SO2'] as int).toDouble() : region['SO2'] as double?;

      if (latitude != null && longitude != null && SO2 != null) {
        LatLng currentPos = LatLng(latitude, longitude);
        double distance = Distance().as(LengthUnit.Kilometer, position, currentPos);
        if (distance == 0) {
          // Exact match found
          return SO2;
        } else if (distance < closestDistance) {
          // Closer position found
          closestDistance = distance;
          closestPosition = currentPos;
          closestDirection = SO2;
        }
      }
    }

    if (closestDirection != null) {
      if (enableDebugLogs) print('Returning wind direction for closest position $closestPosition.');
      return closestDirection;
    } else {
      if (enableDebugLogs) print('No wind direction data found.');
    }
  } else {
    if (enableDebugLogs) print('No data found.');
  }
  return null;
}

// les fonctions de zonage
List<LatLng> createCircle(LatLng center, double radiusInKm) {
  const int pointsCount = 360;
  const double degreesPerPoint = 360.0 / pointsCount;
  const double earthRadius = 6371.0; // Rayon de la Terre en kilomètres

  double radiusInRadians = radiusInKm / earthRadius;
  double centerLatRadians = center.latitude * math.pi / 180;
  double centerLonRadians = center.longitude * math.pi / 180;

  List<LatLng> points = [];

  for (int i = 0; i < pointsCount; i++) {
    double angle = i * degreesPerPoint * math.pi / 180;
    double pointLatRadians =
        math.asin(math.sin(centerLatRadians) * math.cos(radiusInRadians) + math.cos(centerLatRadians) * math.sin(radiusInRadians) * math.cos(angle));
    double pointLonRadians = centerLonRadians +
        math.atan2(math.sin(angle) * math.sin(radiusInRadians) * math.cos(centerLatRadians),
            math.cos(radiusInRadians) - math.sin(centerLatRadians) * math.sin(pointLatRadians));

    double pointLat = pointLatRadians * 180 / math.pi;
    double pointLon = pointLonRadians * 180 / math.pi;

    points.add(LatLng(pointLat, pointLon));
  }

  return points;
}

LatLng calculateNewPosition(LatLng currentPosition, double distanceKm, double bearingDegrees) {
  double bearingRadians = bearingDegrees * math.pi / 180;
  double lat1 = currentPosition.latitude * math.pi / 180;
  double lon1 = currentPosition.longitude * math.pi / 180;

  double lat2 = math.asin(math.sin(lat1) * math.cos(distanceKm / 6371) + math.cos(lat1) * math.sin(distanceKm / 6371) * math.cos(bearingRadians));
  double lon2 =
      lon1 + math.atan2(math.sin(bearingRadians) * math.sin(distanceKm / 6371) * math.cos(lat1), math.cos(distanceKm / 6371) - math.sin(lat1) * math.sin(lat2));

  return LatLng(lat2 * 180 / math.pi, lon2 * 180 / math.pi);
}

Color getColorForAQI(double aqi) {
  if (aqi <= 50) {
    return Colors.lightGreen;
  } else if (aqi <= 100) {
    return Colors.green;
  } else if (aqi <= 150) {
    return Colors.yellow;
  } else if (aqi <= 200) {
    return Colors.orange;
  } else if (aqi <= 300) {
    return Colors.red;
  } else if (aqi > 300) {
    return Colors.purple;
  } else {
    return Colors.black;
  }
}

String getAdviceForAQICategory(String aqiCategory) {
  switch (aqiCategory) {
    case "1.0":
      return "The air quality is ideal for most individuals, enjoy your normal outdoor activities";
    case "2.0":
      return "The air quality is generally acceptable for most individuals. However, sensitive groups may experience minor to moderate symptoms from long-term exposure.";
    case "3.0":
      return "The air has reached a high level of pollution and is unhealthy for sensitive individuals. Reduce time spent outdoors if you experience symptoms such as breathing difficulties or throat irritation.";
    case "4.0":
      return "Health effects can be immediately felt by sensitive groups. Healthy individuals may experience difficulty breathing and throat irritation with prolonged exposure. Limit outdoor activity.";
    case "5.0":
      return "Health effects will be immediately felt by sensitive groups and should avoid outdoor activity. Healthy individuals are likely to experience difficulty breathing and throat irritation; consider staying indoors and rescheduling outdoor activities.";
    case "6.0":
      return "Any exposure to the air, even for a few minutes, can lead to serious health effects on everybody. Avoid outdoor activities.";
    default:
      return "";
  }
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
