import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:air_monitoring_app/widget/BuildSimplePollutantCard.dart';
import 'package:air_monitoring_app/widget/AqiCard.dart';
import 'package:air_monitoring_app/widget/CategoryCard.dart';
import 'package:air_monitoring_app/widget/LegendWidget.dart';
import 'package:air_monitoring_app/widget/AirQualityCardAdvice.dart';


class MapScreen extends StatelessWidget {
  final MapController _mapController = MapController();
    final LatLng _initialPosition = LatLng(36.62027757967697,3.1799796552455386);
      final List<Marker> _markers = []; 
     final TextEditingController _searchController = TextEditingController();

 void initState() {
    _markers.add(
      Marker(
        width: 80.0,
        height: 80.0,
        point: _initialPosition,
        builder: (ctx) => Container(
          child: IconButton(
            icon: Icon(Icons.location_on),
            color: Colors.red,
            iconSize: 45.0,
            onPressed: () {
              showDialog(
                context: ctx,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Détails de la position'),
                    content: Text('Latitude: 37.7749\nLongitude: -122.4194'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Fermer'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: LatLng(36.75, 3.06), // Centre d'Alger
              zoom: 8.0,
            ),
             children: [
              TileLayer(
               urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
               userAgentPackageName: 'dev.fleatleft.flutter_map.example',
                ),
          MarkerLayer(
  markers: [
    Marker(
      point: LatLng(36.62027757967697, 3.1799796552455386),
      width: 60,
      height: 60,
      builder: (BuildContext context) {
        return GestureDetector(
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
        );
      },
    ),
  ],
)

         ] ),
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
          offset: Offset(0, 2), // changes position of shadow
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            // Ajoutez ici votre logique de recherche
          },
        ),
      ],
    ),
  ),
),
Positioned(
  top: 350, // Ajustez cette valeur selon votre mise en page
  right: 10,
  child: Column(
    children: [
      FloatingActionButton(
        onPressed: () {
          _mapController.move(_initialPosition, _mapController.zoom + 1);
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
          _mapController.move(_initialPosition, _mapController.zoom - 1);
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
            bottom: 16,
            left: 16,
            child: LegendWidget(),
          ),
        ],
      ),
    );
  }
}
