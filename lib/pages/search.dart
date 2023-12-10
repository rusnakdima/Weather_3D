import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_3d/shared/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Search extends StatefulWidget {
  final Function(int) onChangePage;
  const Search({Key? key, required this.onChangePage}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController nameController = TextEditingController();

  late String lang = 'en';
  late String domen = 'world-weather.info';

  late String searchValue = '';

  final Map<String, String> dict = {
    "text_en": "Enter name city",
    "text_ru": "Введите название города"
  };

  late List<ElevatedButton> cities = [];

  @override
  void initState() {
    super.initState();
    getLang();
  }

  Future<String> getStringFromLocalStorage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  Future<void> saveStringToLocalStorage(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void getLang() async {
    String tempLang = await getStringFromLocalStorage('lang');
    setState(() {
      if (tempLang != '') {
        lang = tempLang;
      }
    });
  }

  void getData() async {
    String tempDomen = await getStringFromLocalStorage('domen');

    setState(() {
      if (tempDomen != '') {
        domen = tempDomen;
      }
    });

    if (searchValue.isNotEmpty && domen.isNotEmpty) {
      late String searchValue1 = searchValue;
      if (lang == 'ru') {
        searchValue1 = Uri.encodeFull(searchValue);
      }
      var url = Uri.parse('https://$domen/search.php?term=$searchValue1');
      final response = await http.get(url, headers: {
        HttpHeaders.acceptHeader: 'application/json, text/javascript, */*',
        HttpHeaders.refererHeader: 'https://$domen/'
      });
      if (response.statusCode == 200) {
        List arrObj = jsonDecode(response.body);
        addCity(arrObj);
      } else {
        throw Exception();
      }
    }
  }

  void addCity(data) {
    cities = [];
    for (var obj in data) {
      if (obj['region'] != 'Region' &&
          obj['region'] != '' &&
          obj['country'] != 'Country') {
        cities.add(ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(AppTheme.bg),
              side: MaterialStatePropertyAll<BorderSide>(
                BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
            onPressed: () {
              var chpu = obj["chpu"].split("/");
              setState(() {
                saveStringToLocalStorage('city', chpu[1]);
                saveStringToLocalStorage('country', chpu[0]);
              });
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const Home()));
              widget.onChangePage(0);
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Flex(direction: Axis.vertical, children: [
                Text(
                  obj['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  obj['country'] + ", " + obj['region'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ]),
            )));
      }
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
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      border: const OutlineInputBorder(),
                      labelText: dict['text_$lang'].toString(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchValue = value;
                      });
                      getData();
                    },
                  ),
                  if (cities.isNotEmpty)
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      padding: const EdgeInsets.all(10),
                      child: Column(children: cities),
                    )
                ],
              ),
            ),
          )),
    );
  }
}
