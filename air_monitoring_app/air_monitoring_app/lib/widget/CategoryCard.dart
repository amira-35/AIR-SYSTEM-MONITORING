import 'package:flutter/material.dart';

Widget CategoryCard(String dayOfWeek, double aqiValue) {
  // Determine color and title based on AQI value

  String title;
  Color color;
//<>
  if ( aqiValue >= 1 && aqiValue < 2) {
    title = "Good";
    color = Colors.green;
  } else if (aqiValue >= 2 && aqiValue < 3) {
    title = "Moderate";
    color = Colors.yellow;
  } else if (aqiValue >= 3 && aqiValue < 4) {
    title = "Poor";
    color = Colors.orange;
  } else if (aqiValue >= 4 && aqiValue < 5) {
    title = "Unhealthy";
    color = Colors.red;
  } else if (aqiValue >= 5 && aqiValue < 6) {
    title = "Very Unhealthy";
    color = Colors.purple;
  } else if (aqiValue >= 6 && aqiValue < 7) {
    title = "Dangerous";
    color = Colors.brown;
  }else{
     title = "Dangerous";
    color = Colors.brown;
  }

  return Column(
    children: [
      Text(
        dayOfWeek,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w100),
      ),
      Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color.withOpacity(0.8),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: 50,
              height: 10,
              color: color,
            ),
          ],
        ),
      ),
    ],
  );
}
