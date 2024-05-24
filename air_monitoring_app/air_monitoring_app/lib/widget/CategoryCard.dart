import 'package:flutter/material.dart';
Widget CategoryCard(String dayOfWeek,String title, Color color) {
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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