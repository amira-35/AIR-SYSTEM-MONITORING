import 'package:flutter/material.dart';
import 'LengendItem.dart';
class LegendWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      color: Colors.white.withOpacity(0.9),
      child: Column (
        children: [
          Row(  children: [
            LegendItem(color: Colors.green, label: 'Good'),
            LegendItem(color: Colors.yellow, label: 'Moderate'),
            LegendItem(color: Colors.orange, label: 'Poor'),
    
          ], 
            
          ),
          Row(
             children: [
            LegendItem(color: Colors.red, label: 'Unhealthy'),
            LegendItem(color: Colors.purple, label: 'Very Unhealthy'),
            LegendItem(color: Colors.brown, label: 'Dangerous'),
          ], 

          ),
        ]
           
      ),
      
      
    );
  }
}