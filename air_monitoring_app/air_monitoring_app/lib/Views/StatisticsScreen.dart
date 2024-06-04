import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:firebase_database/firebase_database.dart';
import 'package:AirNow/Models/air_quality_data.dart';

class AirQualityChart extends StatefulWidget {
  @override
  _AirQualityChartState createState() => _AirQualityChartState();
}

class _AirQualityChartState extends State<AirQualityChart> {
  late List<AirQualityData> data = [];
  String selectedPollutant = 'AQI';
  String selectedInterval = '1 Month';
  final DatabaseReference databaseReference =
      FirebaseDatabase.instance.reference().child('Region');

  @override
  void initState() {
    super.initState();
    fetchData();
  }

void fetchData() {
    databaseReference.once().then((DatabaseEvent event) {
      List<AirQualityData> fetchedData = [];
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

      print('Fetched values: $values');

      values.forEach((key, value) {
        AirQualityData dataPoint = AirQualityData.fromJson(value);
        fetchedData.add(dataPoint);
      });

      print('Fetched data points: $fetchedData');

      setState(() {
        data = fetchedData;
      });
    }).catchError((error) {
      print('Error fetching data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final chartWidth = screenWidth * 1.5;

    List<charts.Series<AirQualityData, DateTime>> series = [
      charts.Series(
        id: selectedPollutant,
        data: filterDataByInterval(),
        domainFn: (AirQualityData series, _) => series.dateTime,
        measureFn: (AirQualityData series, _) {
          switch (selectedPollutant) {
            case 'CO':
              return series.co;
            case 'NO2':
              return series.no2;
            case 'O3':
              return series.o3;
            case 'PM10':
              return series.pm10;
            case 'PM25':
              return series.pm25;
            case 'SO2':
              return series.so2;
            default:
              return series.aqi;
          }
        },
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      )
    ];

    return Scaffold(
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedPollutant,
                  items: <String>[
                    'AQI', 'CO', 'NO2', 'O3', 'PM10', 'PM25', 'SO2'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPollutant = newValue!;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: selectedInterval,
                  items: <String>['24 Hours', '7 Days', '1 Month']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedInterval = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                 width: chartWidth, // Replace with desired width
                height: 300, // Replace with desired height
                child: charts.TimeSeriesChart(
                  series,
                  animate: true,
                  dateTimeFactory: const charts.LocalDateTimeFactory(),
                  defaultRenderer: charts.LineRendererConfig<DateTime>(),
                  behaviors: [
                    charts.SeriesLegend(),
                    charts.PanAndZoomBehavior(),
                  ],
                  domainAxis: const charts.DateTimeAxisSpec(
                    tickProviderSpec: charts.DayTickProviderSpec(increments: [1]),
                    tickFormatterSpec:
                        charts.AutoDateTimeTickFormatterSpec(
                      day: charts.TimeFormatterSpec(
                        format: 'MMM d',
                        transitionFormat: 'MMM d',
                      ),
                    ),
                  ),
                  primaryMeasureAxis: const charts.NumericAxisSpec(
                    tickProviderSpec: charts.BasicNumericTickProviderSpec(
                        desiredTickCount: 6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<AirQualityData> filterDataByInterval() {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (selectedInterval) {
      case '24 Hours':
        startDate = now.subtract(const Duration(hours: 24));
        break;
      case '7 Days':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case '1 Month':
        startDate = now.subtract(const Duration(days: 30));
        break;
      default:
        startDate = now.subtract(const Duration(days: 30));
        break;
    }

    return data
        .where((dataPoint) => dataPoint.dateTime.isAfter(startDate))
        .toList();
  }
}
