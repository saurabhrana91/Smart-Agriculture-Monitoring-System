import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherDay {
  final DateTime date;
  final double min;
  final double max;
  final int humidity;
  final String condition;
  final String icon;

  WeatherDay({
    required this.date,
    required this.min,
    required this.max,
    required this.humidity,
    required this.condition,
    required this.icon,
  });

  factory WeatherDay.fromJson(Map<String, dynamic> j) {
    final day = j['day'];
    final condition = day['condition'];
    return WeatherDay(
      date: DateTime.parse(j['date']),
      min: (day['mintemp_c'] as num).toDouble(),
      max: (day['maxtemp_c'] as num).toDouble(),
      humidity: (day['avghumidity'] as num).toInt(),
      condition: condition['text'] as String,
      icon: "https:${condition['icon']}",
    );
  }
}

class WeatherService {
  final String apiKey;
  WeatherService({required this.apiKey});

  Future<List<WeatherDay>> fetch7DayWeather({
    double lat = 28.6692,
    double lon = 77.4538,
  }) async {
    final url =
        "https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$lat,$lon&days=7&aqi=no&alerts=no";
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('Weather API failed: ${res.statusCode} ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final forecastDays = data['forecast']['forecastday'] as List;
    return forecastDays.map((d) => WeatherDay.fromJson(d)).toList();
  }
}
