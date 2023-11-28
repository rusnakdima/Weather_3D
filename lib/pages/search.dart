import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_3d/shared/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController nameController = TextEditingController();

  late String searchValue = '';

  late List<ElevatedButton> cities = [];

  Future<void> saveStringToLocalStorage(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void getData() async {
    if (searchValue.isNotEmpty) {
      var url =
          Uri.parse('https://world-weather.info/search.php?term=$searchValue');
      final response = await http.get(url, headers: {
        HttpHeaders.acceptHeader: 'application/json, text/javascript, */*',
        HttpHeaders.refererHeader: 'https://world-weather.info/'
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
              Navigator.pop(context);
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
                  Flex(direction: Axis.horizontal, children: [
                    ElevatedButton(
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                            Color.fromRGBO(255, 255, 255, 1),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: AppTheme.bg,
                          size: 30,
                        ))
                  ]),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelStyle: TextStyle(color: Colors.grey),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      border: OutlineInputBorder(),
                      labelText: 'Enter name city',
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
