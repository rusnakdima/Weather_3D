import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:weather_3d/shared/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_icons/weather_icons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Timer? timer;

  late String city = 'Null';
  late String country = 'Null';

  late String showCity = 'Null';
  late String weather = 'Null';

  late String temperature = 'Null';
  late String weatherIcon = 'd100';

  late String probability = 'Null';
  late String windSpeed = 'Null';
  late String humidity = 'Null';

  late List<Container> hoursWeather = [];

  @override
  void initState() {
    super.initState();
    refresh();
    getData();
    timer = Timer.periodic(const Duration(seconds: 600), (Timer t) {
      getData();
    });
  }

  Future<String> getStringFromLocalStorage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  Future<void> refresh() async {
    getData();
  }

  void getData() async {
    city = await getStringFromLocalStorage('city');
    country = await getStringFromLocalStorage('country');

    if (city == '') {
      city = 'state_new_york';
    }
    if (country == '') {
      city = 'usa';
    }

    if (city.isNotEmpty && country.isNotEmpty) {
      var url = Uri.parse(
          'https://world-weather.info/forecast/$country/$city/24hours/');
      final response = await http.Client()
          .get(url, headers: {HttpHeaders.cookieHeader: 'celsius=1'});
      if (response.statusCode == 200) {
        try {
          var document = parse(response.body);
          var breadCrumbs = document.body!.querySelector("ul#bread-crumbs");
          var table = document.body!.querySelectorAll("table.weather-today")[1];
          var tr = table.querySelectorAll("tr");
          setState(() {
            showCity = breadCrumbs!
                .querySelectorAll("li")
                .last
                .querySelector("a")!
                .innerHtml
                .toString()
                .replaceAll("Weather in ", "");
            weather = tr[0]
                .querySelectorAll("td")[1]
                .querySelector("div")!
                .attributes["title"]
                .toString();
            temperature = tr[0]
                .querySelectorAll("td")[1]
                .querySelector("span")!
                .innerHtml
                .toString();

            weatherIcon = tr[0]
                .querySelectorAll("td")[1]
                .querySelector("div")!
                .className
                .toString()
                .split(" ")[1];

            probability = tr[0].querySelectorAll("td")[3].innerHtml;
            windSpeed = tr[0]
                .querySelectorAll("td")[5]
                .querySelectorAll("span")[1]
                .attributes["title"]
                .toString();
            humidity = tr[0].querySelectorAll("td")[6].innerHtml;
          });
          getHourlyData(tr);
        } catch (e) {
          print('Error: $e');
        }
      } else {
        throw Exception();
      }
    }
  }

  void getHourlyData(data) {
    setState(() {
      hoursWeather = [];
    });

    late String hour = '';
    late String temp = '';
    late String icon = '';

    data.forEach((item) {
      hour = item.querySelectorAll("td")[0].innerHtml;
      temp = item.querySelectorAll("td")[1].querySelector("span").innerHtml;
      icon = item
          .querySelectorAll("td")[1]
          .querySelector("div")!
          .className
          .toString()
          .split(" ")[1];
      setState(() {
        hoursWeather.add(Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            margin: const EdgeInsets.all(0),
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                  bottom: Radius.circular(25),
                ),
                border: Border.all(
                    color: Colors.white54,
                    style: BorderStyle.solid,
                    width: 1.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(temp,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(0),
                  child: Image.asset('assets/images/$icon.png',
                      width: 100, height: 100),
                ),
                // Image.asset("assets/images/icon.png", width: 50, height: 50),
                const SizedBox(height: 10),
                Text(hour,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            )));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: RefreshIndicator(
          onRefresh: refresh,
          child: Container(
              margin: const EdgeInsets.all(0),
              padding: const EdgeInsets.all(0),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.fromLTRB(25, 35, 25, 25),
                  child: Flex(
                      direction: Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '  ',
                              style: TextStyle(decoration: TextDecoration.none),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 55),
                              child: Text(showCity,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                    decoration: TextDecoration.none,
                                  )),
                            ),
                            ElevatedButton(
                                style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll<Color>(
                                    AppTheme.bg,
                                  ),
                                  fixedSize: MaterialStatePropertyAll<Size>(
                                    Size.fromWidth(20),
                                  ),
                                  padding: MaterialStatePropertyAll(
                                      EdgeInsets.all(0)),
                                ),
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                      context, '/search');
                                  if (result == "reload") {
                                    getData();
                                  }
                                },
                                child: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.white,
                                ))
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(0),
                          child: Image.asset('assets/images/$weatherIcon.png',
                              width: 200, height: 200),
                        ),
                        const SizedBox(height: 10),
                        Text(temperature,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 80,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.none,
                              letterSpacing: -3.0,
                            )),
                        Text(weather,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -1.0,
                            )),
                        const SizedBox(height: 10),
                        Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flex(direction: Axis.vertical, children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  child: const Icon(
                                      WeatherIcons.night_alt_rain_wind,
                                      size: 30),
                                  // Image.asset("assets/images/icon.png",
                                  // width: 50, height: 50)
                                ),
                                const SizedBox(height: 10),
                                Text(probability,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w400,
                                    )),
                                const SizedBox(height: 10),
                                const Text("Probability",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w400,
                                    ))
                              ]),
                              Flex(direction: Axis.vertical, children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  child: const Icon(WeatherIcons.day_windy,
                                      size: 30),
                                  // Image.asset("assets/images/icon.png",
                                  //  width: 50, height: 50)
                                ),
                                const SizedBox(height: 10),
                                Text(windSpeed,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w400,
                                    )),
                                const SizedBox(height: 10),
                                const Text("Wind",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w400,
                                    )),
                              ]),
                              Flex(direction: Axis.vertical, children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  child: const Icon(
                                      WeatherIcons.night_alt_cloudy_gusts,
                                      size: 30),
                                  // Image.asset("assets/images/icon.png",
                                  // width: 50, height: 50)
                                ),
                                const SizedBox(height: 10),
                                Text(humidity,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w400,
                                    )),
                                const SizedBox(height: 10),
                                const Text("Humidity",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w400,
                                    ))
                              ]),
                            ]),
                        const SizedBox(height: 25),
                        Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Today",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.none,
                                  )),
                              ElevatedButton(
                                  style: const ButtonStyle(
                                    backgroundColor:
                                        MaterialStatePropertyAll<Color>(
                                      AppTheme.bg,
                                    ),
                                    padding: MaterialStatePropertyAll(
                                        EdgeInsets.all(0)),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/forecast');
                                  },
                                  child: const Flex(
                                      direction: Axis.horizontal,
                                      children: [
                                        Text("Next 14 days",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                            )),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      ]))
                            ]),
                        const SizedBox(height: 25),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(spacing: 20, children: hoursWeather),
                        )
                      ]),
                ),
              ))),
    );
  }
}
