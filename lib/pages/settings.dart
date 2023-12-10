import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_3d/shared/app_theme.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late String lang = 'en';

  final Map<String, String> dict = {
    "text_en": "Select the program language",
    "text_ru": "Выберите язык программы"
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
    getLang();
  }

  List<Map<String, String>> langs = [
    {'value': 'en', 'label': 'English'},
    {'value': 'ru', 'label': 'Russian'},
  ];

  void getLang() async {
    String tempLang = await getStringFromLocalStorage('lang');
    setState(() {
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
              dict['text_$lang'].toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 25,
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
              items: langs.map((Map<String, String> item) {
                return DropdownMenuItem(
                  value: item['value'],
                  child: Text(
                    item['label'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
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
                getLang();
              },
            ),
          ],
        ),
      ),
    );
  }
}
