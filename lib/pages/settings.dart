import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_3d/shared/app_theme.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late double fontSize = 1.0;

  late String lang = 'en';

  final Map<String, String> dict = {
    "lang_text_en": "Select the program language",
    "lang_text_ru": "Выберите язык программы",
    "font_size_en": "Select the text size in the program",
    "font_size_ru": "Выберите размер текста в программе"
  };

  Future<String> getStringFromLocalStorage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  Future<void> saveStringToLocalStorage(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  List<Map<String, String>> langs = [
    {'value': 'en', 'label': 'English'},
    {'value': 'ru', 'label': 'Russian'},
  ];

  void getData() async {
    String tempFontSize = await getStringFromLocalStorage('font_size');
    String tempLang = await getStringFromLocalStorage('lang');
    setState(() {
      if (tempFontSize != '') {
        fontSize = double.parse(tempFontSize);
        if (fontSize < 0.7 || fontSize > 2.5) {
          fontSize = 1.0;
        }
      }
      if (tempLang != '') {
        lang = tempLang;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Container(
        margin: const EdgeInsets.fromLTRB(25, 35, 25, 25),
        padding: const EdgeInsets.all(0),
        child: Flex(
          direction: Axis.vertical,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              dict['lang_text_$lang'].toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 25 * fontSize,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
            ),
            DropdownButtonFormField(
              value: lang,
              dropdownColor: Colors.grey.shade800,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40))),
              style: TextStyle(
                fontSize: 20 * fontSize,
                height: 1,
              ),
              items: langs.map((Map<String, String> item) {
                return DropdownMenuItem(
                  value: item['value'],
                  child: Text(
                    item['label'].toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20 * fontSize,
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value.toString() == 'en') {
                  saveStringToLocalStorage('domen', 'world-weather.info');
                  saveStringToLocalStorage('lang', 'en');
                } else if (value.toString() == 'ru') {
                  saveStringToLocalStorage('domen', 'world-weather.ru');
                  saveStringToLocalStorage('lang', 'ru');
                } else {
                  saveStringToLocalStorage('domen', 'world-weather.info');
                  saveStringToLocalStorage('lang', 'en');
                }
                getData();
              },
            ),
            const SizedBox(height: 10),
            Text(
              dict['font_size_$lang'].toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 25 * fontSize,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.none,
              ),
            ),
            Slider(
                value: fontSize,
                min: 0.7,
                max: 2.5,
                divisions: 10,
                label: fontSize.toDouble().toString(),
                onChanged: (double value) {
                  setState(() {
                    saveStringToLocalStorage('font_size', value.toString());
                    getData();
                  });
                })
          ],
        ),
      ),
    );
  }
}
