import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math' as math;

// import widgets
import 'package:AirNow/widget/AirQualityCardAdvice.dart';
import 'package:AirNow/widget/AqiCard.dart';
import 'package:AirNow/widget/BuildSimplePollutantCard.dart';
import 'package:AirNow/widget/LegendWidget.dart';
import 'package:AirNow/widget/CategoryCard.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Polygon> _polygons = [];
  final double radiusInKm = 2.0;
  List<LatLng> _trace = [];
  LatLng _currentPosition = const LatLng(36.75, 3.06); // Example initial position
  double windDirection = 45; // en degrés
  double windSpeed = 10; // en km/h
  final double distanceInKm = 7.0;
  double updateIntervalInSeconds = 1.0; // Intervalle de mise à jour en secondes
  Timer? _timer;
  bool isMoving = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color _getColorForAQI(double aqi) {
    if (aqi <= 50) {
      return Colors.green;
    } else if (aqi <= 100) {
      return Colors.yellow;
    } else if (aqi <= 150) {
      return Colors.orange;
    } else if (aqi <= 200) {
      return Colors.red;
    } else if (aqi <= 300) {
      return Colors.purple;
    } else {
      return Colors.brown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              center: LatLng(36.75, 3.06),
              zoom: 8.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleatleft.flutter_map.example',
              ),
              PolygonLayer(polygons: _polygons),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _trace,
                    strokeWidth: 4.0,
                    color: Colors.white,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Container(
                                width: 600,
                                child: SingleChildScrollView(
                                  child: Stack(
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            child: IconButton(
                                              icon: const Icon(Icons.close_rounded),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          AqiCard(200),
                                          const SizedBox(height: 20),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Informations sur les gaz',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w100,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  children: [
                                                    BuildSimplePollutantCard('PM2.5', '25 µg/m³', Colors.white),
                                                    BuildSimplePollutantCard('PM10', '50 µg/m³', Colors.white),
                                                    BuildSimplePollutantCard('O3', '0.05 ppm', Colors.white),
                                                    BuildSimplePollutantCard('NO2', '0.02 ppm', Colors.white),
                                                    BuildSimplePollutantCard('SO2', '0.01 ppm', Colors.white),
                                                    BuildSimplePollutantCard('CO', '1 ppm', Colors.white),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Informations métérologiques',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w100,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  children: [
                                                    BuildSimplePollutantCard('Wind Direction', '90.3', Colors.white),
                                                    BuildSimplePollutantCard('Wind Speed', '2.2', Colors.white),
                                                    BuildSimplePollutantCard('Humidity', '90.3', Colors.white),
                                                    BuildSimplePollutantCard('Temperature', '2.2', Colors.white),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Next Days',
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w100,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                  children: [
                                                    CategoryCard('Sunday', 'Excellent', Colors.green),
                                                    const SizedBox(width: 10),
                                                    CategoryCard('Monday', 'Fair', Colors.lightGreen),
                                                    const SizedBox(width: 10),
                                                    CategoryCard('Tuesday', 'Poor', Colors.yellow),
                                                    const SizedBox(width: 10),
                                                    CategoryCard('Wednesday', 'Fair', Colors.lightGreen),
                                                    const SizedBox(width: 10),
                                                    CategoryCard('Thursday', 'Fair', Colors.lightGreen),
                                                    const SizedBox(width: 10),
                                                    CategoryCard('Friday', 'Very Unhealthy', Colors.purple),
                                                    const SizedBox(width: 10),
                                                    CategoryCard('Saturday', 'Very Unhealthy', Colors.purple),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              AirQualityCardAdvice(
                                                "L'air a atteint un degré élevé de pollution et n'est pas sain pour les personnes sensibles. Réduisez le temps passé en extérieur si vous ressentez des symptômes, tels que des difficultés respiratoires ou des irritations de la gorge.",
                                                Icons.lightbulb_outline,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.centerLeft,
                        child: const Center(
                          child: Icon(
                            Icons.location_pin,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      // Add your search logic here
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _mapController.move(_mapController.center, _mapController.zoom + 1);
                  },
                  child: Icon(Icons.add),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey,
                  elevation: 4,
                  mini: true,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: () {
                    _mapController.move(_mapController.center, _mapController.zoom - 1);
                  },
                  child: Icon(Icons.remove),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey,
                  elevation: 4,
                  mini: true,
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _toggleMovement,
                  child: Icon(isMoving ? Icons.pause : Icons.play_arrow),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: LegendWidget(),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      print('Permission accordée');
    } else if (status.isDenied) {
      print('Permission refusée. Vous pouvez demander à nouveau la permission.');
    } else if (status.isPermanentlyDenied) {
      print('Permission refusée de façon permanente. Demandez à l\'utilisateur d\'activer manuellement.');
      await openAppSettings();
    }
  }

  void _toggleMovement() {
    setState(() {
      isMoving = !isMoving;
    });

    if (isMoving) {
      _startMovement();
    } else {
      _stopMovement();
    }
  }

  void _startMovement() {
    _timer = Timer.periodic(Duration(seconds: updateIntervalInSeconds.toInt()), (timer) {
      setState(() {
        _updateZonePosition();
      });
    });
  }

  void _stopMovement() {
    _timer?.cancel();
  }

  LatLng _calculateNewPosition(LatLng currentPosition, double distanceKm, double bearingDegrees) {
    double bearingRadians = bearingDegrees * math.pi / 180;
    double lat1 = currentPosition.latitude * math.pi / 180;
    double lon1 = currentPosition.longitude * math.pi / 180;

    double lat2 = math.asin(math.sin(lat1) * math.cos(distanceKm / 6371) +
        math.cos(lat1) * math.sin(distanceKm / 6371) * math.cos(bearingRadians));
    double lon2 = lon1 +
        math.atan2(math.sin(bearingRadians) * math.sin(distanceKm / 6371) * math.cos(lat1),
            math.cos(distanceKm / 6371) - math.sin(lat1) * math.sin(lat2));

    return LatLng(lat2 * 180 / math.pi, lon2 * 180 / math.pi);
  }

  void _updateZonePosition() {
    double distancePerSecond = windSpeed / 3600;
    _currentPosition = _calculateNewPosition(_currentPosition, distancePerSecond, windDirection);
    _trace.add(_currentPosition);
    _addPolygonsForSurroundingPositions();
  }

  void _addPolygon(LatLng center, double aqi) {
    List<LatLng> points = _createCircle(center, radiusInKm);

    Polygon polygon = Polygon(
      points: points,
      color: _getColorForAQI(aqi).withOpacity(0.4), // Utilisation de la couleur en fonction de l'AQI
      borderStrokeWidth: 2,
      borderColor: Colors.transparent,
      isFilled: true,
    );

    setState(() {
      _polygons.add(polygon);
    });
  }

  void _addPolygonsForSurroundingPositions() {
    const List<double> bearings = [0, 45, 90, 135, 180, 225, 270, 315];
    _polygons.clear();

    // Obtenez l'AQI pour la position actuelle
    double currentAQI = _getAQIForPosition(_currentPosition);
    _addPolygon(_currentPosition, currentAQI);

    for (double bearing in bearings) {
      LatLng newPosition = _calculateNewPosition(_currentPosition, distanceInKm, bearing);
      double newAQI = _getAQIForPosition(newPosition);
      double newWindSpeed = _getWindSpeedForPosition(newPosition); // Exemple d'obtention de la vitesse du vent
      double newWindDirection = _getWindDirectionForPosition(newPosition); // Exemple d'obtention de la direction du vent

      _polygons.add(
        Polygon(
          points: _createCircle(newPosition, radiusInKm),
          color: _getColorForAQI(newAQI).withOpacity(0.3),
          borderStrokeWidth: 2,
          borderColor: Colors.transparent,
          isFilled: true,
        ),
      );

      // Mettez à jour la position selon la direction et la vitesse du vent
      newPosition = _calculateNewPosition(newPosition, newWindSpeed / 3600, newWindDirection);
    }

    setState(() {});
  }

  List<LatLng> _createCircle(LatLng center, double radiusInKm) {
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

  double _getAQIForPosition(LatLng position) {
    // Remplacez cette logique par votre méthode réelle pour obtenir l'AQI pour une position donnée.
    return 200; // Valeur AQI fictive
  }

  double _getWindSpeedForPosition(LatLng position) {
    // Remplacez cette logique par votre méthode réelle pour obtenir la vitesse du vent pour une position donnée.
    return 10; // Valeur fictive de la vitesse du vent
  }

  double _getWindDirectionForPosition(LatLng position) {
    // Remplacez cette logique par votre méthode réelle pour obtenir la direction du vent pour une position donnée.
    return 45; // Valeur fictive de la direction du vent
  }
}
