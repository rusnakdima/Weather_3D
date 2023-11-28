import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:weather_3d/shared/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_icons/weather_icons.dart';

class Forecast extends StatefulWidget {
  const Forecast({super.key});

  @override
  State<Forecast> createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  Timer? timer;

  late String city = '';
  late String country = '';
  late String dateShow = '';

  late List<ElevatedButton> daysWeather = [];

  late Column infoDayWeather = const Column(
    children: [Row(), Row()],
  );

  @override
  void initState() {
    super.initState();
    getData();
    timer = Timer.periodic(const Duration(seconds: 600), (Timer t) {
      getData();
    });
  }

  Future<String> getStringFromLocalStorage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  getIcon(String name, double sizeVal) {
    late Map<String, Icon> icons = {
      "clear_sky": Icon(
        WeatherIcons.day_sunny,
        size: sizeVal,
        color: Colors.white,
      ),
      "light_intensity_shower_rain": Icon(
        WeatherIcons.day_showers,
        size: sizeVal,
        color: Colors.white,
      ),
      "few_clouds": Icon(
        WeatherIcons.cloud,
        size: sizeVal,
        color: Colors.white,
      ),
      "partly_cloudy": Icon(
        WeatherIcons.day_cloudy,
        size: sizeVal,
        color: Colors.white,
      ),
      "broken_clouds": Icon(
        WeatherIcons.day_cloudy,
        size: sizeVal,
        color: Colors.white,
      ),
      "overcast_clouds": Icon(
        WeatherIcons.cloudy,
        size: sizeVal,
        color: Colors.white,
      ),
      "drizzle": Icon(
        WeatherIcons.rain_mix,
        size: sizeVal,
        color: Colors.white,
      ),
      "light_rain": Icon(
        WeatherIcons.day_rain,
        size: sizeVal,
        color: Colors.white,
      ),
      "moderate_rain": Icon(
        WeatherIcons.rain_wind,
        size: sizeVal,
        color: Colors.white,
      ),
      "heavy_intensity_rain": Icon(
        WeatherIcons.rain,
        size: sizeVal,
        color: Colors.white,
      ),
      "heavy_intensity_drizzle": Icon(
        WeatherIcons.showers,
        size: sizeVal,
        color: Colors.white,
      ),
    };
    final icon = icons[name];
    return icon;
  }

  void getData() async {
    city = await getStringFromLocalStorage('city');
    country = await getStringFromLocalStorage('country');

    if (city.isNotEmpty && country.isNotEmpty) {
      var url = Uri.parse(
          'https://world-weather.info/forecast/$country/$city/14days/');
      final response = await http.Client()
          .get(url, headers: {HttpHeaders.cookieHeader: 'celsius=1'});
      if (response.statusCode == 200) {
        var document = parse(response.body);
        var div = document.body!.querySelectorAll(".weather-short");
        getDaylyData(div);
      } else {
        throw Exception();
      }
    }
  }

  void getDaylyData(data) {
    setState(() {
      daysWeather = [];
    });

    late String day = '';
    late String week = '';
    late String icon = '';

    data.forEach((item) {
      week = item
          .querySelector("div")
          .querySelector("span")
          .innerHtml
          .toString()
          .substring(0, 3);
      day = item.querySelector("div")!.nodes[1].toString().substring(3, 5);
      icon = item
          .querySelector("table")!
          .querySelectorAll("tr")[1]!
          .querySelectorAll("td")[1]
          .querySelector("div")
          .attributes["title"]
          .toString()
          .toLowerCase()
          .replaceAll(" ", "_");
      // final int i = daysWeather.toList().length;
      setState(() {
        daysWeather.add(ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(AppTheme.bg),
              padding: MaterialStatePropertyAll(EdgeInsets.all(0)),
            ),
            onPressed: () {
              getInfoDay(item);
            },
            child: Container(
                alignment: Alignment.center,
                width: 120,
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
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 20),
                      child: getIcon(icon, 60),
                    ),
                    // Image.asset("assets/images/icon.png",
                    //     width: 50, height: 50),
                    const SizedBox(height: 5),
                    Text(day,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w900,
                        )),
                    const SizedBox(height: 5),
                    Text(week,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          decoration: TextDecoration.none,
                        ))
                  ],
                ))));
      });
    });
    getInfoDay(data[0]);
  }

  void getInfoDay(data) {
    var table = data.querySelector("table");
    var tr = table.querySelectorAll("tr")[1];
    String weatherIcon = tr
        .querySelectorAll("td")[1]
        .querySelector("div")!
        .attributes["title"]
        .toString()
        .toLowerCase()
        .replaceAll(" ", "_");
    String probability = tr.querySelectorAll("td")[3].text;
    String windSpeed = tr
        .querySelectorAll("td")[5]
        .querySelectorAll("span")[1]
        .attributes["title"]
        .toString();
    String humidity = tr.querySelectorAll("td")[6].text;
    String weather = tr
        .querySelectorAll("td")[1]
        .querySelector("div")!
        .attributes["title"]
        .toString();
    String temp = tr
        .querySelectorAll("td")[1]
        .querySelector("span")!
        .text
        .toString()
        .replaceAll("°", "");
    String tempFeel =
        tr.querySelectorAll("td")[2]!.text.toString().replaceAll("°", "");

    dateShow = data.querySelector(".dates")!.text.toString();

    if (weatherIcon == '' ||
        probability == '' ||
        windSpeed == '' ||
        humidity == '' ||
        weather == '' ||
        temp == '' ||
        tempFeel == '') {
      setState(() {
        infoDayWeather = const Column(
          children: [Row(), Row()],
        );
      });
    } else {
      setState(() {
        infoDayWeather = Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  border: Border.all(color: Colors.grey),
                  color: Colors.white10),
              child: Flex(direction: Axis.vertical, children: [
                Center(
                  child: Text(dateShow,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flex(
                      direction: Axis.vertical,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 50),
                          child: getIcon(weatherIcon, 100),
                        ),
                        // Image.asset("assets/images/icon.png",
                        //     width: 130, height: 130),
                        SizedBox(
                          width: 150,
                          child: Text(weather,
                              textAlign: TextAlign.left,
                              softWrap: true,
                              maxLines: 5,
                              style: const TextStyle(
                                overflow: TextOverflow.fade,
                                color: Colors.white,
                                fontSize: 20,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w700,
                              )),
                        )
                      ],
                    ),
                    Flex(
                      direction: Axis.vertical,
                      children: [
                        Text('$temp°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 55,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w700,
                            )),
                        Text('Feels like $tempFeel°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w400,
                            )),
                        const Icon(WeatherIcons.windy, size: 55),
                        // Image.asset("assets/images/icon.png",
                        //     width: 80, height: 80),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flex(direction: Axis.vertical, children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        child: const Icon(WeatherIcons.night_alt_rain_wind,
                            size: 25),
                        // Image.asset("assets/images/icon.png",
                        //     width: 50, height: 50),
                      ),
                      const SizedBox(height: 10),
                      Text(probability,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            decoration: TextDecoration.none,
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
                        child: const Icon(WeatherIcons.day_windy, size: 25),
                        // Image.asset("assets/images/icon.png",
                        //     width: 50, height: 50),
                      ),
                      const SizedBox(height: 10),
                      Text(windSpeed,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            decoration: TextDecoration.none,
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
                        child: const Icon(WeatherIcons.night_alt_cloudy_gusts,
                            size: 25),
                        // Image.asset("assets/images/icon.png",
                        //     width: 50, height: 50),
                      ),
                      const SizedBox(height: 10),
                      Text(humidity,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            decoration: TextDecoration.none,
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
                  ],
                )
              ]),
            )
          ],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Container(
          margin: const EdgeInsets.all(0),
          padding: const EdgeInsets.all(0),
          child: SingleChildScrollView(
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
                        ElevatedButton(
                            style: const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll<Color>(
                                AppTheme.bg,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 30,
                            )),
                        const Text("Next 14 days",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w600,
                            )),
                        const Icon(
                          Icons.more_vert_rounded,
                          size: 40,
                        ),
                      ],
                    ),
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(top: 30),
                        child: Wrap(spacing: 30, children: daysWeather)),
                    Container(
                      child: infoDayWeather,
                    )
                  ],
                ),
              ))),
    );
  }
}
