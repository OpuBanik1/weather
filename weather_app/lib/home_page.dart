import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class Home_page extends StatefulWidget {
  const Home_page({super.key});

  @override
  State<Home_page> createState() => _Home_pageState();
}

class _Home_pageState extends State<Home_page> {
  Position? position;
  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  var latitude;
  var longitude;

  _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = position?.latitude;
      longitude = position?.longitude;
    });
    fetchWeather();
  }

  @override
  void initState() {
    _determinePosition();
    // TODO: implement initState
    super.initState();
  }

  fetchWeather() async {
    final weatherLink =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=metric&appid=f92bf340ade13c087f6334ed434f9761&fbclid=IwAR3V93r3HWY7pNri1unJEADry5YcuEQXqqVODgPx6IbY56Z1GFBmm3gfx-w';
    final forecastLink =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=metric&appid=f92bf340ade13c087f6334ed434f9761&fbclid=IwAR3V93r3HWY7pNri1unJEADry5YcuEQXqqVODgPx6IbY56Z1GFBmm3gfx-w';

    var weatherResponse = await http.get(Uri.parse(weatherLink));
    var forecastResponse = await http.get(Uri.parse(forecastLink));
    weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
    forecastMap = Map<String, dynamic>.from(jsonDecode(forecastResponse.body));
    setState(() {
      print(
          'pppppppppppppppppp latitude is ${latitude}longitude is $longitude');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Weather Forecast',
                style: TextStyle(fontSize: 20),
              ),
            ),
            body: forecastMap != null
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            children: [
                              Text(
                                Jiffy(DateTime.now()).format('MMM do h:mm a'),
                                style: myStyle(15),
                              ),
                              Text(weatherMap!['name'], style: myStyle(15))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Center(
                          child: Text(
                            '${weatherMap!['main']['temp']}°C',
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Column(
                            children: [
                              Text(
                                  'Feels like ${weatherMap!['main']["feels_like"]}'),
                              Text(
                                  '${weatherMap!["weather"][0]["description"]}')
                            ],
                          ),
                        ),
                        // SizedBox(
                        //   height: 30,
                        // ),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                  'Humidity ${weatherMap!['main']['humidity']}   pressure ${weatherMap!['main']['pressure']}'),
                              Text(
                                  'Sunrise ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunrise'] * 1000)).format('h:mm a')} sunset ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!['sys']['sunset'] * 1000)).format('h:mm a')}'),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: forecastMap!.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: EdgeInsets.only(right: 8),
                                  color: Colors.grey,
                                  width: 200,
                                  child: Column(
                                    children: [
                                      Text(
                                          '${Jiffy(forecastMap!['list'][index]["dt_txt"]).format('EEE h:mm')}'),
                                      Image.network(
                                          'http://openweathermap.org/img/wn/${forecastMap!['list'][index]['weather'][0]['icon']}@2x.png'),
                                      Text(
                                          '${forecastMap!['list'][index]['main']['temp_min']}/${forecastMap!['list'][index]['main']['temp_max']}'),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                          '${forecastMap!['list'][index]['weather'][0]['main']}')
                                    ],
                                  ),
                                );
                              }),
                        )
                      ],
                    ),
                  )
                : CircularProgressIndicator()));
  }
}

myStyle(double fs, [FontWeight? fw, Color? clr]) {
  return TextStyle(fontSize: fs, fontWeight: fw, color: clr);
}
