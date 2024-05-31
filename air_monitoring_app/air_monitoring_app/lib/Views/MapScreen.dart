// import bib
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math' as math;
//import widgets 
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
  double updateIntervalInSeconds = 0.01; // Intervalle de mise à jour en secondes
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
      child : GestureDetector(
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
                                        CategoryCard('Sunday','Excellent', Colors.green),
                                        const SizedBox(width: 10),
                                        CategoryCard('Monday','Fair',Colors.lightGreen),
                                        const SizedBox(width: 10),
                                        CategoryCard('Tuesday','Poor',Colors.yellow),
                                        const SizedBox(width: 10),
                                        CategoryCard('Wednesday','Fair',Colors.lightGreen),
                                        const SizedBox(width: 10),
                                        CategoryCard('Thursday','Fair',Colors.lightGreen),
                                        const SizedBox(width: 10),
                                        CategoryCard('Friday','Very Unhealthy',Colors.purple),
                                        const SizedBox(width: 10),
                                        CategoryCard('Saturday','Very Unhealthy',Colors.purple),
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
            bottom: 16,
            left: 16,
            child: LegendWidget(),
          ),

        ],
      ),
    );
  }
  
  Future<void> _requestPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      _checkGPS();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      print('Location permission is denied.');
    }
  }

  Future<void> _checkGPS() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showGPSDialog();
      _getCurrentPosition();
     
    } else {
      _getCurrentPosition();
    }
  }
  void _showGPSDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("GPS désactivé"),
          content: Text("Veuillez activer le GPS pour utiliser cette fonctionnalité."),
          actions: [
            TextButton(
              child: Text("Paramètres"),
              onPressed: () {
                Geolocator.openLocationSettings();
                Navigator.of(context).pop();
                
              },
            ),
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  Future<void> _getCurrentPosition() async {
    
    await Geolocator.checkPermission();
  bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, do not continue
      // accessing the position and request users of the App to enable the location services.
      print('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print('Location permissions are permanently denied, we cannot request permissions.');
      return;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng currentPosition = LatLng(position.latitude, position.longitude);
    setState(() {
      _currentPosition = currentPosition;
      _mapController.move(_currentPosition, 15.0); // Move the map to the current position
      _addPolygon(_currentPosition); // Add the polygon at the current position // Add the polygon at the current position
    });
  }
    
  
  
  void _startMovement() {
    _timer = Timer.periodic(Duration(seconds: updateIntervalInSeconds.toInt()), (Timer t) {
      if (isMoving) {
        _updateZonePosition(windDirection, windSpeed);
      }
    });
  }
   Future<void> _stopMovement() async {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {    
    LatLng currentPosition = LatLng(position.latitude, position.longitude);// Réinitialise au point de départ
    _currentPosition = currentPosition;
      _trace.clear(); // Efface la trace
      _polygons.clear();
       _addPolygon(_currentPosition); // Efface les polygones
    });
  }
  void _updateZonePosition(double windDirection, double windSpeed) {
    double distanceInKm = (windSpeed / 3600) * updateIntervalInSeconds; // Distance parcourue en km pendant l'intervalle de temps
    double distanceInDegrees = distanceInKm / 110.574;

    double angleInRadians = windDirection * (math.pi / 180);
    double deltaX = distanceInDegrees * math.cos(angleInRadians);
    double deltaY = distanceInDegrees * math.sin(angleInRadians);

    LatLng newPosition = LatLng(
      _currentPosition.latitude + deltaY,
      _currentPosition.longitude + deltaX,
    );

    setState(() {
      _currentPosition = newPosition; // Met à jour la position actuelle
      _trace.add(newPosition); // Ajoute la nouvelle position à la trace
      _addPolygon(newPosition);
    });
  }
  void _addPolygon(LatLng center) {
    List<LatLng> points = _createCircle(center, radiusInKm);

    Polygon polygon = Polygon(
      points: points,
      color: Colors.red.withOpacity(0.4),
      borderStrokeWidth: 2,
      borderColor: Colors.transparent,
      isFilled: true,
    );

    setState(() {
      _polygons = [polygon];
    });
  }
   List<LatLng> _createCircle(LatLng center, double radiusInKm) {
    const int pointsCount = 36;
    final double radiusInDegrees = radiusInKm / 110.574;

    List<LatLng> points = [];
    for (int i = 0; i < pointsCount; i++) {
      double angle = (i * 2 * math.pi) / pointsCount;
      double dx = radiusInDegrees * math.cos(angle);
      double dy = radiusInDegrees * math.sin(angle);

      points.add(LatLng(center.latitude + dy, center.longitude + dx));
    }

    return points;
  }


}
