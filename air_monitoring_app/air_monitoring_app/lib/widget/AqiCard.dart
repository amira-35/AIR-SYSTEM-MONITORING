import 'package:flutter/material.dart';
Widget AqiCard(double aqiValue) {
  Color cardColor;
  String aqiCategory;

  if (aqiValue <= 50) {
    cardColor = Colors.lightGreen;
    aqiCategory = 'Excellent';
  } else if (aqiValue <= 100) {
    cardColor = Colors.green;
    aqiCategory = 'Fair';
  } else if (aqiValue <= 150) {
    cardColor = Colors.yellow;
    aqiCategory = 'Poor';
  } else if (aqiValue <= 200) {
    cardColor = Colors.orange;
    aqiCategory = 'Unhealthy';
  } else if (aqiValue <= 300) {
    cardColor = Colors.red;
    aqiCategory = 'Very Unhealthy';
  }
  else {
    cardColor = Colors.purple;
    aqiCategory = 'Dangerous';
  }

  return SizedBox(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
       
        color: cardColor, // Set card color based on AQI
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child:Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
     const SizedBox(width: 10),
    const Icon(
      Icons.gas_meter_outlined,
      size: 50,  // Adjust icon size as needed
      color: Colors.white, // Keep cloud icon white
    ),  // Horizontal spacing after icon
const SizedBox(width: 65),
    // Use a Row with MainAxisSize.min to avoid unnecessary space
    Row(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    // ... icon and horizontal spacing
    Column(
      mainAxisSize: MainAxisSize.min,  // Restrict inner Column width
      crossAxisAlignment: CrossAxisAlignment.start,  // Align text to start
      children: [
          // Vertical spacing between AQI and value
        Text(
          '$aqiValue',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,  // Set AQI value color
          ),
        ),        
        const SizedBox(height: 4),
        const Text(
          '  AQI',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,  // Set AQI text color
          ),
        ),
      ],
    ),
  ],
),
 const SizedBox(width: 60), 
Text(
          '$aqiCategory',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,  // Set AQI value color
          ),
        ),
       const SizedBox(width: 10), 
  ],
),
    ),
  );
}

 