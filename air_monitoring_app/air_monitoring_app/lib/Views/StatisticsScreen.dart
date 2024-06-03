import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AirQualityData {
  final DateTime time;
  final double aqi;
  final double co;
  final double no2;
  final double o3;
  final double pm10;
  final double pm25;

  AirQualityData({
    required this.time,
    required this.aqi,
    required this.co,
    required this.no2,
    required this.o3,
    required this.pm10,
    required this.pm25,
  });
}

class AirQualityChart extends StatefulWidget {
  @override
  _AirQualityChartState createState() => _AirQualityChartState();
}

class _AirQualityChartState extends State<AirQualityChart> {
  late List<AirQualityData> data = [];
  String selectedPollutant = 'AQI';
  String selectedInterval = '1 Month';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() {
    setState(() {
      data = [
        AirQualityData(time: DateTime.now().subtract(Duration(days: 30)), aqi: 25, co: 5, no2: 10, o3: 15, pm10: 20, pm25: 18),
        AirQualityData(time: DateTime.now().subtract(Duration(days: 29)), aqi: 30, co: 6, no2: 11, o3: 16, pm10: 22, pm25: 19),
        AirQualityData(time: DateTime.now().subtract(Duration(days: 28)), aqi: 35, co: 7, no2: 12, o3: 17, pm10: 24, pm25: 20),
        // Ajoutez plus de données ici pour couvrir une période d'un mois
        AirQualityData(time: DateTime.now().subtract(Duration(days: 1)), aqi: 40, co: 8, no2: 13, o3: 18, pm10: 26, pm25: 21),
        AirQualityData(time: DateTime.now(), aqi: 45, co: 9, no2: 14, o3: 19, pm10: 28, pm25: 22),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    List<charts.Series<AirQualityData, DateTime>> series = [
      charts.Series(
        id: selectedPollutant,
        data: filterDataByInterval(),
        domainFn: (AirQualityData series, _) => series.time,
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
                  items: <String>['AQI', 'CO', 'NO2', 'O3', 'PM10', 'PM25']
                      .map((String value) {
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
            child: charts.TimeSeriesChart(
              series,
              animate: true,
              dateTimeFactory: const charts.LocalDateTimeFactory(),
              defaultRenderer: charts.LineRendererConfig<DateTime>(),
              behaviors: [charts.SeriesLegend()],
              domainAxis: const charts.DateTimeAxisSpec(
                tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
                  day: charts.TimeFormatterSpec(
                    format: 'MMM d', // Format for the x-axis
                    transitionFormat: 'MMM d',
                  ),
                ),
              ),
              primaryMeasureAxis: const charts.NumericAxisSpec(
                tickProviderSpec:
                    charts.BasicNumericTickProviderSpec(desiredTickCount: 6),
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
        startDate = now.subtract(Duration(hours: 24));
        break;
      case '7 Days':
        startDate = now.subtract(Duration(days: 7));
        break;
      case '1 Month':
        startDate = now.subtract(Duration(days: 30));
        break;
      default:
        startDate = now.subtract(Duration(days: 30));
        break;
    }

    return data.where((dataPoint) => dataPoint.time.isAfter(startDate)).toList();
  }
}

