import 'package:flutter/material.dart';
import 'LengendItem.dart';
class LegendWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.0),
      color: Colors.white.withOpacity(0.5),
      child: Column (
        children: [
          Row(  children: [
            LegendItem(color: Colors.green, label: 'Excellent'),
            LegendItem(color: Colors.lightGreen, label: 'Fair'),
            LegendItem(color: Colors.yellow, label: 'Poor'),
    
          ], 
            
          ),
          Row(
             children: [
            LegendItem(color: Colors.orange, label: 'Unhealthy'),
            LegendItem(color: Colors.red, label: 'Very Unhealthy'),
            LegendItem(color: Colors.purple, label: 'Dangerous'),
          ], 

          ),
        ]
           
      ),
      
      
    );
  }
}