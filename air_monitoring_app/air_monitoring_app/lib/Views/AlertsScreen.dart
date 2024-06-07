import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Alerts extends StatefulWidget {
  @override
  _AlertsPageState createState() => _AlertsPageState();
}

class _AlertsPageState extends State<Alerts> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  List<Map<String, String>> alerts = [];

  @override
  void initState() {
    super.initState();

    // Initialiser les notifications pour Android uniquement
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initSettings = InitializationSettings(android: androidSettings);
    flutterLocalNotificationsPlugin.initialize(initSettings);

    // Simuler une alerte
    Future.delayed(Duration(seconds: 2), () {
      _showNotification();
      _addAlert("AQI Alert", "Air Quality Index is 5 or higher");
    });
  }

  Future<void> _showNotification() async {
    var androidDetails = AndroidNotificationDetails(
      'channelId',
      'channelName',
      channelDescription: 'channelDescription',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    var generalNotificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'AQI Alert',
      'Air Quality Index is 5 or higher',
      generalNotificationDetails,
    );
  }

  void _addAlert(String title, String message) {
    setState(() {
      alerts.add({
        'title': title,
        'message': message,
        'date': DateTime.now().toString(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alerts"),
      ),
      body: ListView.builder(
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(alerts[index]['title']!),
              subtitle: Text(alerts[index]['message']!),
              trailing: Text(alerts[index]['date']!),
            ),
          );
        },
      ),
    );
  }
}
