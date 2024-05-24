class AirQualityData {
  double aqi;
  int aqiCategory;
  double co;
  DateTime dateTime;
  int windDirection;
  double latitude;
  double longitude;
  double no2;
  double o3;
  double pm10;
  double pm25;
  double so2;
  double windSpeed;

  AirQualityData({
    required this.aqi,
    required this.aqiCategory,
    required this.co,
    required this.dateTime,
    required this.windDirection,
    required this.latitude,
    required this.longitude,
    required this.no2,
    required this.o3,
    required this.pm10,
    required this.pm25,
    required this.so2,
    required this.windSpeed,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      aqi: json['AQI'],
      aqiCategory: json['AQI Category'],
      co: json['CO'],
      dateTime: DateTime.parse(json['DateTime']),
      windDirection: json['Direction vent'],
      latitude: json['Latitude'],
      longitude: json['Longitude'],
      no2: json['NO2'],
      o3: json['O3'],
      pm10: json['PM10'],
      pm25: json['PM25'],
      so2: json['SO2'],
      windSpeed: json['Vitesse vent'],
    );
  }
}
