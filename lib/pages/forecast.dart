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

  late double fontSize = 1.0;

  late String lang = 'en';
  late String domen = 'world-weather.info';

  late String city = 'new_york';
  late String country = 'usa';
  late String dateShow = '';

  late String errorMessage = '';

  final Map<String, String> dict = {
    "feels_en": "Feels like",
    "feels_ru": "Ощущается как",
    "precip_en": "Precipitation",
    "precip_ru": "Осадки",
    "wind_en": "Wind Speed",
    "wind_ru": "Скорость ветра",
    "humidity_en": "Humidity",
    "humidity_ru": "Влажность",
    "next_en": "Next 14 days",
    "next_ru": "Следующие 14 дней",
    "day_en": "Day",
    "day_ru": "День",
    "night_en": "Night",
    "night_ru": "Ночь",
    "Monday": "Mon",
    "Tuesday": "Tue",
    "Wednesday": "Wed",
    "Thursday": "Thu",
    "Friday": "Fri",
    "Saturday": "Sat",
    "Sunday": "Sun",
    "Понедельник": "ПН",
    "Вторник": "ВТ",
    "Среда": "СР",
    "Четверг": "ЧТ",
    "Пятница": "ПТ",
    "Суббота": "СБ",
    "Воскресенье": "ВС",
  };

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

  void getData() async {
    String tempFontSize = await getStringFromLocalStorage('font_size');
    String tempLang = await getStringFromLocalStorage('lang');
    String tempDomen = await getStringFromLocalStorage('domen');
    String tempCity = await getStringFromLocalStorage('city');
    String tempCountry = await getStringFromLocalStorage('country');
    setState(() {
      if (tempFontSize != '') {
        fontSize = double.parse(tempFontSize);
      }
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

    if (city.isNotEmpty && country.isNotEmpty) {
      try {
        if (lang == 'en') {
          domen += '/forecast';
        }
        if (lang == 'ru') {
          domen += '/pogoda';
        }
        var url = Uri.parse('https://$domen/$country/$city/14days/');
        final response = await http.Client().get(url, headers: {
          HttpHeaders.acceptHeader: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
          HttpHeaders.cookieHeader: 'celsius=1',
        });
        if (response.statusCode == 200) {
          var document = parse(response.body);
          var div = document.body!.querySelectorAll(".weather-short");
          getDaylyData(div);
        } else {
          throw Exception();
        }
      } catch (e) {
        print('Error: $e');
        errorMessage += '\n';
        errorMessage += e.toString();
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

    try {
      data.forEach((item) {
        week = item
            .querySelector("div")
            .querySelector("span")
            .innerHtml
            .toString();
        day = item.querySelector("div")!.nodes[1].toString().substring(3, 5);
        icon = item
            .querySelector("table")!
            .querySelectorAll("tr")[1]
            .querySelectorAll("td")[1]
            .querySelector("div")!
            .className
            .toString()
            .split(" ")[2];
        setState(() {
          daysWeather.add(
            ElevatedButton(
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
                      margin: const EdgeInsets.all(0),
                      child: Image.asset('assets/images/$icon.png',
                          width: 100, height: 100),
                    ),
                    const SizedBox(height: 5),
                    Text(day,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30 * fontSize,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w900,
                        )),
                    const SizedBox(height: 5),
                    Text(dict[week].toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18 * fontSize,
                          decoration: TextDecoration.none,
                        ))
                  ],
                ),
              ),
            ),
          );
        });
      });
    } catch (e) {
      print("Error: $e");
      errorMessage += '\n';
      errorMessage += e.toString();
    }
    getInfoDay(data[0]);
  }

  void getInfoDay(data) {
    try {
      var table = data.querySelector("table");
      var trDay = table.querySelectorAll("tr")[1];
      var trNight = table.querySelectorAll("tr")[0];
      String weatherIconDay = trDay
          .querySelectorAll("td")[1]
          .querySelector("div")!
          .className
          .toString()
          .split(" ")[2];
      String precipitationDay = trDay.querySelectorAll("td")[3].text;
      String windSpeedDay = trDay
          .querySelectorAll("td")[5]
          .querySelectorAll("span")[1]
          .attributes["title"]
          .toString();
      String humidityDay = trDay.querySelectorAll("td")[6].text;
      String weatherDay = trDay
          .querySelectorAll("td")[1]
          .querySelector("div")!
          .attributes["title"]
          .toString();
      String tempDay = trDay
          .querySelectorAll("td")[1]
          .querySelector("span")!
          .text
          .toString()
          .replaceAll("°", "");
      String tempFeelDay =
          trDay.querySelectorAll("td")[2]!.text.toString().replaceAll("°", "");
      String weatherIconNight = trNight
          .querySelectorAll("td")[1]
          .querySelector("div")!
          .className
          .toString()
          .split(" ")[2];
      String precipitationNight = trNight.querySelectorAll("td")[3].text;
      String windSpeedNight = trNight
          .querySelectorAll("td")[5]
          .querySelectorAll("span")[1]
          .attributes["title"]
          .toString();
      String humidityNight = trNight.querySelectorAll("td")[6].text;
      String weatherNight = trNight
          .querySelectorAll("td")[1]
          .querySelector("div")!
          .attributes["title"]
          .toString();
      String tempNight = trNight
          .querySelectorAll("td")[1]
          .querySelector("span")!
          .text
          .toString()
          .replaceAll("°", "");
      String tempFeelNight = trNight
          .querySelectorAll("td")[2]!
          .text
          .toString()
          .replaceAll("°", "");
      if (weatherIconDay == '') weatherIconDay = 'NULL';
      if (precipitationDay == '') precipitationDay = 'NULL';
      if (windSpeedDay == '') windSpeedDay = 'NULL';
      if (humidityDay == '') humidityDay = 'NULL';
      if (weatherDay == '') weatherDay = 'NULL';
      if (tempDay == '') tempDay = 'NULL';
      if (tempFeelDay == '') tempFeelDay = 'NULL';
      if (weatherIconNight == '') weatherIconNight = 'NULL';
      if (precipitationNight == '') precipitationNight = 'NULL';
      if (windSpeedNight == '') windSpeedNight = 'NULL';
      if (humidityNight == '') humidityNight = 'NULL';
      if (weatherNight == '') weatherNight = 'NULL';
      if (tempNight == '') tempNight = 'NULL';
      if (tempFeelNight == '') tempFeelNight = 'NULL';

      setState(() {
        dateShow = data.querySelector(".dates")!.text.toString();
        infoDayWeather = Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                  border: Border.all(color: Colors.grey),
                  color: Colors.white10),
              child: Flex(
                direction: Axis.vertical,
                children: [
                  Center(
                    child: Text(dateShow,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30 * fontSize,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                  createBlock(
                      dict['day_$lang'].toString(),
                      weatherIconDay,
                      weatherDay,
                      tempDay,
                      tempFeelDay,
                      precipitationDay,
                      windSpeedDay,
                      humidityDay),
                  const SizedBox(height: 20),
                  createBlock(
                      dict['night_$lang'].toString(),
                      weatherIconNight,
                      weatherNight,
                      tempNight,
                      tempFeelNight,
                      precipitationNight,
                      windSpeedNight,
                      humidityNight),
                ],
              ),
            )
          ],
        );
      });
    } catch (e) {
      print("Error: $e");
      errorMessage += '\n';
      errorMessage += e.toString();
    }
  }

  Flex createBlock(
      String time,
      String weatherIcon,
      String weather,
      String temp,
      String tempFeel,
      String precipitation,
      String windSpeed,
      String humidity) {
    return Flex(
      direction: Axis.vertical,
      children: [
        Center(
          child: Text(time,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30 * fontSize,
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
                  margin: const EdgeInsets.all(0),
                  child: Image.asset('assets/images/$weatherIcon.png',
                      width: 100 * fontSize, height: 100 * fontSize),
                ),
                SizedBox(
                  width: 150,
                  child: Text(weather,
                      textAlign: TextAlign.left,
                      softWrap: true,
                      maxLines: 5,
                      style: TextStyle(
                        overflow: TextOverflow.fade,
                        color: Colors.white,
                        fontSize: 20 * fontSize,
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
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 55 * fontSize,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w700,
                    )),
                Text("${dict['feels_$lang'].toString()} $tempFeel°",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20 * fontSize,
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
                child: const Icon(Icons.umbrella, size: 30),
                // Image.asset("assets/images/icon.png",
                //     width: 50, height: 50),
              ),
              const SizedBox(height: 10),
              Text(precipitation,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18 * fontSize,
                    decoration: TextDecoration.none,
                  )),
              const SizedBox(height: 10),
              Text(dict['precip_$lang'].toString(),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18 * fontSize,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                  ))
            ]),
            Flex(direction: Axis.vertical, children: [
              Container(
                padding: const EdgeInsets.all(18),
                child: const Icon(WeatherIcons.wind, size: 30),
                // Image.asset("assets/images/icon.png",
                //     width: 50, height: 50),
              ),
              const SizedBox(height: 10),
              Text(windSpeed,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18 * fontSize,
                    decoration: TextDecoration.none,
                  )),
              const SizedBox(height: 10),
              Text(dict['wind_$lang'].toString(),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18 * fontSize,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                  )),
            ]),
            Flex(direction: Axis.vertical, children: [
              Container(
                padding: const EdgeInsets.all(18),
                child: const Icon(Icons.water_drop, size: 30),
                // Image.asset("assets/images/icon.png",
                //     width: 50, height: 50),
              ),
              const SizedBox(height: 10),
              Text(humidity,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18 * fontSize,
                    decoration: TextDecoration.none,
                  )),
              const SizedBox(height: 10),
              Text(dict['humidity_$lang'].toString(),
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18 * fontSize,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                  ))
            ]),
          ],
        )
      ],
    );
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dict['next_$lang'].toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25 * fontSize,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(top: 30),
                    child: Wrap(spacing: 30, children: daysWeather)),
                Container(
                  child: infoDayWeather,
                ),
                if (errorMessage != '') const SizedBox(height: 25),
                if (errorMessage != '')
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 30 * fontSize,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
