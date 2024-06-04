class AirQualityData {
  final DateTime dateTime;
  final double aqi;
  final double co;
  final double no2;
  final double o3;
  final double pm10;
  final double pm25;
  final double so2;

  AirQualityData({
    required this.dateTime,
    required this.aqi,
    required this.co,
    required this.no2,
    required this.o3,
    required this.pm10,
    required this.pm25,
    required this.so2,
  });

  factory AirQualityData.fromJson(Map<dynamic, dynamic> json) {
    return AirQualityData(
      dateTime: DateTime.parse(json['DateTime']),
      aqi: json['AQI'].toDouble(),
      co: json['CO'].toDouble(),
      no2: json['NO2'].toDouble(),
      o3: json['O3'].toDouble(),
      pm10: json['PM10'].toDouble(),
      pm25: json['PM25'].toDouble(),
      so2: json['SO2'].toDouble(),
    );
  }
}

