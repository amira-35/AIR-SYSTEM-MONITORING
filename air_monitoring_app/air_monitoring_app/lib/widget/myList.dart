import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Liste de données statiques
    final List<Map<String, dynamic>> staticDataList = [
      {
        'name': 'Static City 1',
        'temp': 25.0, // Celsius
        'description': 'Clear sky'
      },
      {
        'name': 'Static City 2',
        'temp': 30.0, // Celsius
        'description': 'Partly cloudy'
      },
      {
        'name': 'Static City 3',
        'temp': 22.0, // Celsius
        'description': 'Rain'
      },
    ];

    // Définir un style par défaut pour caption s'il est null
    final TextStyle defaultCaptionStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Colors.black45,
      fontFamily: 'flutterfonts',
    );

    return Container(
      height: 150,
      child: ListView.separated(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => VerticalDivider(
          color: Colors.transparent,
          width: 5,
        ),
        itemCount: staticDataList.length,
        itemBuilder: (context, index) {
          final data = staticDataList[index];
          final captionStyle = Theme.of(context).textTheme.bodySmall ?? defaultCaptionStyle;

          return Container(
            width: 140,
            height: 150,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      data['name'],
                      style: captionStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45,
                      ),
                    ),
                    Text(
                      '${data['temp'].round().toString()}\u2103',
                      style: captionStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45,
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: LottieBuilder.asset('assets/cloudyAnim.json'), // Assurez-vous que le chemin du fichier Lottie est correct
                    ),
                    Text(
                      data['description'],
                      style: captionStyle.copyWith(
                        color: Colors.black45,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
