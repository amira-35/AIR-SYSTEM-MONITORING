// import bib
import 'package:AirNow/Controllers/my_functions.dart';
import 'package:AirNow/Controllers/recherche.dart';
import 'package:AirNow/constants/dev_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
//import widgets
import 'package:AirNow/widget/AirQualityCardAdvice.dart';
import 'package:AirNow/widget/AqiCard.dart';
import 'package:AirNow/widget/BuildSimplePollutantCard.dart';
import 'package:AirNow/widget/LegendWidget.dart';
import 'package:AirNow/widget/CategoryCard.dart';

const double radiusInKm = 2.0;
const double distanceInKm = 7.0;
const double updateIntervalInSeconds = 0.1; // Intervalle de mise à jour en secondes

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _cityCoordinates;
  List<Polygon> _polygons = [];
  LatLng? initialTracePos;
  LatLng? latestTracePos;
  LatLng _currentPosition = const LatLng(36.75, 3.06); // Example initial position
  List<Bearing> bearings = [];
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
                    points: [initialTracePos ?? const LatLng(0, 0), latestTracePos ?? const LatLng(0, 0)],
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
                      onTap: () async {
                        // Récupération des
                        //données de Firebase en parallèle
                        List<double?> results = await Future.wait([
                          getPM25FromFirebase(_currentPosition),
                          getPM10FromFirebase(_currentPosition),
                          getO3FromFirebase(_currentPosition),
                          getNO2FromFirebase(_currentPosition),
                          getSO2FromFirebase(_currentPosition),
                          getCOFromFirebase(_currentPosition),
                          getWindDirectionForPosition(_currentPosition),
                          getWindSpeedForPosition(_currentPosition),
                          getHumiditeFromFirebase(_currentPosition),
                          getTemperatureFromFirebase(_currentPosition),
                          getAQICategoryFromFirebase(_currentPosition),
                          getAQIFromFirebase(_currentPosition),
                        ]);

                        // Attribution des résultats
                        double? pm25 = results[0];
                        double? pm10 = results[1];
                        double? o3 = results[2];
                        double? no2 = results[3];
                        double? so2 = results[4];
                        double? co = results[5];
                        double? windDirection = results[6];
                        double? windSpeed = results[7];
                        double? humidity = results[8];
                        double? temperature = results[9];
                        double? aqivaluecat = results[10];
                        double? aqivalue = results[11];
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
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: AqiCard(aqivalue!),
                                          ),
                                          const SizedBox(height: 20),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Information about gases',
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
                                                    BuildSimplePollutantCard('PM2.5', '$pm25 ug/m³', Colors.white),
                                                    BuildSimplePollutantCard('PM10', '$pm10 ug/m³', Colors.white),
                                                    BuildSimplePollutantCard('O3', '$o3 ug/m³', Colors.white),
                                                    BuildSimplePollutantCard('NO2', '$no2 ug/m³', Colors.white),
                                                    BuildSimplePollutantCard('SO2', '$so2 ug/m³', Colors.white),
                                                    BuildSimplePollutantCard('CO', '$co ug/m³', Colors.white),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              const Text(
                                                'Meteorological information',
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
                                                    BuildSimplePollutantCard('Wind Direction', '$windDirection°', Colors.white),
                                                    BuildSimplePollutantCard('Wind Speed', '$windSpeed km/h', Colors.white),
                                                    BuildSimplePollutantCard('Humidity', '$humidity%', Colors.white),
                                                    BuildSimplePollutantCard('Temperature', '$temperature°C', Colors.white),
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
                                                    CategoryCard('Today', 'Excellent', Colors.green),
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
                                                getAdviceForAQICategory(aqivaluecat.toString()),
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
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                      ),
                      onSubmitted: _searchSubmitted,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _searchButtonPressed,
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
              ],
            ),
          ),
          Positioned(
            bottom: 90,
            left: 16,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  isMoving = !isMoving;
                  if (isMoving) {
                    _startMovement();
                  } else {
                    _stopMovement();
                  }
                });
              },
              child: Icon(isMoving ? Icons.pause : Icons.play_arrow),
            ),
          ),
          Positioned(
            bottom: 155,
            left: 16,
            child: FloatingActionButton(
              onPressed: () {
                _getCurrentPosition();
              },
              child: Icon(Icons.gps_fixed),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: LegendWidget(),
          ),
        ],
      ),
    );
  }

  void _requestPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      await Permission.locationWhenInUse.request();
    }
    if (await Permission.locationWhenInUse.isGranted) {
      _getCurrentPosition();
    }
  }

  void _centerMapOnCurrentPosition() {
    _mapController.move(_currentPosition, 13.0);
  }

  void _startMovement() {
    _timer = Timer.periodic(Duration(seconds: updateIntervalInSeconds.toInt()), (timer) {
      setState(() {
        _updateZonePosition();
      });
    });
  }

  void _stopMovement() {
    _timer?.cancel(); // Annuler le timer
    setState(() {
      isMoving = false; // Mettre à jour l'état pour arrêter le mouvement
      _getCurrentPosition(); // Récupérer la position actuelle
      initialTracePos = null; // Réinitialiser les positions de trace
      latestTracePos = null; // Réinitialiser les positions de trace
    });
  }

  void _getCurrentPosition() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _centerMapOnCurrentPosition();
        _initializePolygonsForSurroundingPositions();
      });
    }
  }

  Future<void> _updateZonePosition() async {
    if (initialTracePos == null) {
      initialTracePos = _currentPosition;
    } else {
      latestTracePos = bearings.firstOrNull?.position ?? _currentPosition;
    }

    await _updatePolygonsForSurroundingPositions();
  }

  void _addPolygon(LatLng center, double aqi) {
    List<LatLng> points = createCircle(center, radiusInKm);

    Polygon polygon = Polygon(
      points: points,
      color: getColorForAQI(aqi).withOpacity(0.4), // Utilisation de la couleur en fonction de l'AQI
      borderStrokeWidth: 2,
      borderColor: Colors.transparent,
      isFilled: true,
    );

    // Vérifiez si le widget est monté avant d'appeler setState
    if (mounted) {
      setState(() {
        _polygons.add(polygon);
      });
    }
  }

  Future<void> _updatePolygonsForSurroundingPositions() async {
    _polygons.clear();

    List<Bearing> newBearingPositions = [];

    for (Bearing bearing in bearings) {
      final newPosition = calculateNewPosition(bearing.position, bearing.windSpeed / 3600, bearing.windDirection);
      newBearingPositions.add(bearing.copyWithPosition(newPosition));
    }

    bearings = newBearingPositions;

    for (Bearing bearing in bearings) {
      _polygons.add(bearing.toPolygon());
    }
  }

  Future<void> _initializePolygonsForSurroundingPositions() async {
    _polygons.clear();
    bearings.clear();

    const List<double> bearingAngles = [0, 45, 90, 135, 180, 225, 270, 315];

    // Obtenez l'AQI pour la position actuelle
    double? currentAqi = await getAQIFromFirebase(_currentPosition);
    if (currentAqi != null) {
      final centerBearing = Bearing(
        position: _currentPosition,
        windDirection: await getWindDirectionForPosition(_currentPosition) ?? 0,
        windSpeed: await getWindSpeedForPosition(_currentPosition) ?? 0,
        airQuality: currentAqi,
      );

      _polygons.add(centerBearing.toPolygon());
      bearings.add(centerBearing);
    } else {
      if (enableDebugLogs) print('No AQI data found for current position.');
      return;
    }

    for (double bearingAngle in bearingAngles) {
      LatLng newPosition = calculateNewPosition(_currentPosition, distanceInKm, bearingAngle);
      double? aqi = await getAQIFromFirebase(newPosition);
      if (aqi == null) {
        if (enableDebugLogs) print('No AQI data found for position $newPosition.');
        continue;
      }
      double? newWindSpeed = await getWindSpeedForPosition(newPosition); // Exemple d'obtention de la vitesse du vent
      if (newWindSpeed == null) {
        if (enableDebugLogs) print('No WindSpeed data found for position $newPosition.');
        continue;
      }
      double? newWindDirection = await getWindDirectionForPosition(newPosition); // Exemple d'obtention de la direction du vent
      if (newWindDirection == null) {
        if (enableDebugLogs) print('No WindSpeed data found for position $newPosition.');
        continue;
      }

      final bearingModel = Bearing(
        angle: bearingAngle,
        position: newPosition,
        windDirection: newWindDirection,
        windSpeed: newWindSpeed,
        airQuality: aqi,
      );

      bearings.add(bearingModel);
      _polygons.add(bearingModel.toPolygon());
    }
  }

  void _searchSubmitted(String value) async {
    _cityCoordinates = await getCoordinatesFromCity(value);
    _currentPosition = LatLng(
      _cityCoordinates!['lat'],
      _cityCoordinates!['lon'],
    );
    double? aqivalue = await getAQIFromFirebase(_currentPosition);
    if (_cityCoordinates != null) {
      setState(() {
        _mapController.move(_currentPosition, 10.0);
        _addPolygon(_currentPosition, aqivalue!);
        _initializePolygonsForSurroundingPositions();
      });
    }
  }

  void _searchButtonPressed() async {
    _cityCoordinates = await getCoordinatesFromCity(_searchController.text);
    _currentPosition = LatLng(
      _cityCoordinates!['lat'],
      _cityCoordinates!['lon'],
    );

    double? aqivalue2 = await getAQIFromFirebase(_currentPosition);
    if (_cityCoordinates != null) {
      setState(() {
        if (enableDebugLogs) print('aqi de la position rechercher = $aqivalue2');
        _mapController.move(_currentPosition, 10.0);
        _addPolygon(_currentPosition, aqivalue2!);
      });
    }
  }
}

class Bearing {
  final double? angle; // Null for center one
  final LatLng position;
  final double windDirection;
  final double windSpeed;
  final double airQuality;

  Bearing({
    this.angle,
    required this.position,
    required this.windDirection,
    required this.windSpeed,
    required this.airQuality,
  });

  Bearing copyWithPosition(LatLng position) {
    return Bearing(
      angle: angle,
      position: position,
      windDirection: windDirection,
      windSpeed: windSpeed,
      airQuality: airQuality,
    );
  }

  Polygon toPolygon() {
    return Polygon(
      points: createCircle(position, radiusInKm),
      color: getColorForAQI(airQuality).withOpacity(0.3),
      borderStrokeWidth: 2,
      borderColor: Colors.transparent,
      isFilled: true,
    );
  }
}
