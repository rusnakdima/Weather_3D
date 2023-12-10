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

  late String lang = 'en';
  late String domen = 'world-weather.info';

  late String city = 'new_york';
  late String country = 'usa';

  late String date = 'Null';
  late String time = 'Null';
  late String showCity = 'Null';
  late String weather = 'Null';

  late String temperature = 'Null';
  late String weatherIcon = 'd100';

  late String precipitation = 'Null';
  late String windSpeed = 'Null';
  late String humidity = 'Null';

  final Map<String, String> dict = {
    "precip_en": "Precipitation",
    "precip_ru": "Осадки",
    "wind_en": "Wind Speed",
    "wind_ru": "Скорость ветра",
    "humidity_en": "Humidity",
    "humidity_ru": "Влажность",
    "next_en": "Next 24 hours",
    "next_ru": "Следующие 24 часа",
  };

  late List<ElevatedButton> hoursWeather = [];

  @override
  void initState() {
    super.initState();
    refresh();
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
    String tempLang = await getStringFromLocalStorage('lang');
    String tempDomen = await getStringFromLocalStorage('domen');
    String tempCity = await getStringFromLocalStorage('city');
    String tempCountry = await getStringFromLocalStorage('country');
    setState(() {
      if (tempLang != '') {
        lang = tempLang;
      }
      if (tempDomen != '') {
        domen = tempDomen;
      }
      if (tempCity != '') {
        city = tempCity;
      }
      if (tempCountry != '') {
        country = tempCountry;
      }
    });

    if (domen.isNotEmpty && city.isNotEmpty && country.isNotEmpty) {
      try {
        if (lang == 'en') {
          domen += '/forecast';
        }
        if (lang == 'ru') {
          domen += '/pogoda';
        }
        var url = Uri.parse('https://$domen/$country/$city/24hours/');
        final response = await http.Client()
            .get(url, headers: {HttpHeaders.cookieHeader: 'celsius=1'});
            print(response.statusCode);
            print(url);
        if (response.statusCode == 200) {
          var document = parse(response.body);
          var breadCrumbs = document.body!.querySelector("ul#bread-crumbs");
          setState(() {
            if (lang == 'en') {
              showCity = breadCrumbs!
                  .querySelectorAll("li")
                  .last
                  .querySelector("a")!
                  .innerHtml
                  .toString();
            } else if (lang == 'ru') {
              showCity = breadCrumbs!
                  .querySelectorAll("li")
                  .last
                  .querySelector("a")!
                  .innerHtml
                  .toString();
            }
          });
          var table = document.body!.querySelectorAll(".weather-today")[1];
          late List<Map<String, dynamic>> data = [];
          table.querySelectorAll("tr").forEach((element) {
            data.add({
              'date': document.body!.querySelector(".dates.red")!.text,
              'element': element
            });
          });
          if (data.length < 24) {
            var table1 = document.body!.querySelectorAll(".weather-today")[2];
            String date = document.body!.querySelectorAll(".dates")[1].text;
            table1
                .querySelectorAll("tr")
                .getRange(0, 24 - data.length)
                .forEach((element) {
              data.add({'date': date, 'element': element});
            });
          }
          getHourlyData(data);
        } else {
          throw Exception();
        }
      } catch (e) {
        print('Error: $e');
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
      hour = item['element'].querySelectorAll("td")[0].innerHtml;
      temp = item['element']
          .querySelectorAll("td")[1]
          .querySelector("span")
          .innerHtml;
      icon = item['element']
          .querySelectorAll("td")[1]
          .querySelector("div")!
          .className
          .toString()
          .split(" ")[1];
      setState(() {
        hoursWeather.add(
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(AppTheme.bg),
              padding: MaterialStatePropertyAll(EdgeInsets.all(0)),
            ),
            onPressed: () {
              getInfoHour(item);
            },
            child: Container(
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
                  Text(
                    temp,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(0),
                    child: Image.asset('assets/images/$icon.png',
                        width: 100, height: 100),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hour,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    });
    getInfoHour(data[0]);
  }

  void getInfoHour(data) {
    setState(() {
      date = data['date'];
      time = data['element'].querySelectorAll("td")[0].text;
      weather = data['element']
          .querySelectorAll("td")[1]
          .querySelector("div")!
          .attributes["title"]
          .toString();
      temperature = data['element']
          .querySelectorAll("td")[1]
          .querySelector("span")!
          .innerHtml
          .toString();

      weatherIcon = data['element']
          .querySelectorAll("td")[1]
          .querySelector("div")!
          .className
          .toString()
          .split(" ")[1];

      precipitation = data['element'].querySelectorAll("td")[3].innerHtml;
      windSpeed = data['element']
          .querySelectorAll("td")[5]
          .querySelectorAll("span")[1]
          .attributes["title"]
          .toString();
      humidity = data['element'].querySelectorAll("td")[6].innerHtml;
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
                        Text(
                          showCity,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(0),
                          child: Flex(
                            direction: Axis.horizontal,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(date,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.none,
                                    letterSpacing: -1.0,
                                  )),
                              const SizedBox(width: 10),
                              Text(time,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.none,
                                    letterSpacing: -1.0,
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(0),
                          child: Image.asset('assets/images/$weatherIcon.png',
                              width: 200, height: 200),
                        ),
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
                                  child: const Icon(Icons.umbrella, size: 30),
                                  // Image.asset("assets/images/icon.png",
                                  // width: 50, height: 50)
                                ),
                                const SizedBox(height: 10),
                                Text(precipitation,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w400,
                                    )),
                                const SizedBox(height: 10),
                                Text(dict['precip_$lang'].toString(),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w400,
                                    ))
                              ]),
                              Flex(direction: Axis.vertical, children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  child:
                                      const Icon(WeatherIcons.wind, size: 30),
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
                                Text(dict['wind_$lang'].toString(),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 18,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.w400,
                                    )),
                              ]),
                              Flex(direction: Axis.vertical, children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  child: const Icon(Icons.water_drop, size: 30),
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
                                Text(dict['humidity_$lang'].toString(),
                                    style: const TextStyle(
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              dict['next_$lang'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
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
