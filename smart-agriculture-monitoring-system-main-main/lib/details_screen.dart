import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'weather_service.dart';
import 'config.dart';
import 'dart:math';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String selectedView = "Hour Wise";

  final Map<String, IconData> sensorIcons = const {
    "soil": Icons.water_drop,
    "temperature": Icons.thermostat,
    "humidity": Icons.grain,
    "rain": Icons.umbrella,
  };

  List<Map<String, dynamic>> hourWise = [];
  List<Map<String, dynamic>> dayWise = [];
  List<Map<String, dynamic>> next7Days = [];

  bool loadingHour = true;
  bool loadingDay = true;
  bool loadingNext = true;

  String? errorHour;
  String? errorDay;
  String? errorNext;

  late final WeatherService _weather;
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _weather = WeatherService(apiKey: kOpenWeatherKey);
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadHourWise(),
      _loadDayWise(),
      _loadNext7Days(),
    ]);
  }

  double _avg(Iterable<num> xs) {
    if (xs.isEmpty) return 0;
    final s = xs.fold<double>(0, (a, b) => a + b.toDouble());
    return s / xs.length;
  }

  String _fmtNum(num v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 1);

  Future<void> _loadHourWise() async {
    setState(() {
      loadingHour = true;
      errorHour = null;
    });
    try {
      final now = DateTime.now();
      final hours = List.generate(
        24,
        (i) => now.subtract(Duration(hours: 23 - i)),
      );

      final data = hours.map((h) {
        return {
          "time": DateFormat('HH:00').format(h),
          "sensors": [
            {
              "title": "Soil Moisture",
              "value": _rand.nextInt(50) + 30,
              "unit": "%",
              "iconKey": "soil",
              "color": Colors.blue,
            },
            {
              "title": "Temperature",
              "value": _rand.nextInt(10) + 20,
              "unit": "°C",
              "iconKey": "temperature",
              "color": Colors.orange,
            },
            {
              "title": "Humidity",
              "value": _rand.nextInt(30) + 50,
              "unit": "%",
              "iconKey": "humidity",
              "color": Colors.green,
            },
          ],
        };
      }).toList();

      setState(() {
        hourWise = data;
        loadingHour = false;
      });
    } catch (e) {
      setState(() {
        errorHour = e.toString();
        loadingHour = false;
      });
    }
  }

  Future<void> _loadDayWise() async {
    setState(() {
      loadingDay = true;
      errorDay = null;
    });
    try {
      final now = DateTime.now();
      final days = List.generate(
        7,
        (i) => now.subtract(Duration(days: 6 - i)),
      );

      final data = days.map((d) {
        return {
          "time": DateFormat('EEE, d MMM').format(d),
          "sensors": [
            {
              "title": "Soil Moisture",
              "value": _rand.nextInt(50) + 30,
              "unit": "%",
              "iconKey": "soil",
              "color": Colors.blue,
            },
            {
              "title": "Temperature",
              "value": _rand.nextInt(10) + 20,
              "unit": "°C",
              "iconKey": "temperature",
              "color": Colors.orange,
            },
            {
              "title": "Humidity",
              "value": _rand.nextInt(30) + 50,
              "unit": "%",
              "iconKey": "humidity",
              "color": Colors.green,
            },
          ],
        };
      }).toList();

      setState(() {
        dayWise = data;
        loadingDay = false;
      });
    } catch (e) {
      setState(() {
        errorDay = e.toString();
        loadingDay = false;
      });
    }
  }

  Future<void> _loadNext7Days() async {
    setState(() {
      loadingNext = true;
      errorNext = null;
    });
    try {
      final forecast = await _weather.fetch7DayWeather(
        lat: 28.6692, // Ghaziabad
        lon: 77.4538,
      );

      final data = forecast.map((w) {
        return {
          "time": DateFormat('EEE, d MMM').format(w.date),
          "sensors": [
            {
              "title": "Soil Moisture",
              "value": "-",
              "unit": "",
              "iconKey": "soil",
              "color": Colors.blue,
            },
            {
              "title": "Temperature",
              "value": "${w.max.toStringAsFixed(0)}/${w.min.toStringAsFixed(0)}",
              "unit": "°C",
              "iconKey": "temperature",
              "color": Colors.orange,
            },
            {
              "title": "Humidity",
              "value": w.humidity.toString(),
              "unit": "%",
              "iconKey": "humidity",
              "color": Colors.green,
            },
          ],
        };
      }).toList();

      setState(() {
        next7Days = data;
        loadingNext = false;
      });
    } catch (e) {
      setState(() {
        errorNext = e.toString();
        loadingNext = false;
      });
    }
  }

  List<Map<String, dynamic>> get currentData {
    if (selectedView == "Hour Wise") return hourWise;
    if (selectedView == "Day Wise") return dayWise;
    return next7Days;
  }

  bool get isLoading {
    if (selectedView == "Hour Wise") return loadingHour;
    if (selectedView == "Day Wise") return loadingDay;
    return loadingNext;
  }

  String? get currentError {
    if (selectedView == "Hour Wise") return errorHour;
    if (selectedView == "Day Wise") return errorDay;
    return errorNext;
  }

  Future<void> _refreshCurrent() async {
    if (selectedView == "Hour Wise") await _loadHourWise();
    else if (selectedView == "Day Wise") await _loadDayWise();
    else await _loadNext7Days();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("All Measurements"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(onPressed: _refreshCurrent, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Threshold",
              style: TextStyle(color: Colors.redAccent, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              "Current Sensor Readings",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButton<String>(
              dropdownColor: Colors.black,
              value: selectedView,
              items: const [
                DropdownMenuItem(value: "Hour Wise", child: Text("Hour Wise", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: "Day Wise", child: Text("Day Wise", style: TextStyle(color: Colors.white))),
                DropdownMenuItem(value: "Next 7 Days", child: Text("Next 7 Days", style: TextStyle(color: Colors.white))),
              ],
              onChanged: (v) => setState(() => selectedView = v!),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Builder(
              builder: (context) {
                if (isLoading) return const Center(child: CircularProgressIndicator());
                final err = currentError;
                if (err != null) return Center(child: Text(err, style: const TextStyle(color: Colors.redAccent)));
                if (currentData.isEmpty) return const Center(child: Text("No data available", style: TextStyle(color: Colors.white70)));

                return RefreshIndicator(
                  onRefresh: _refreshCurrent,
                  child: ListView.builder(
                    itemCount: currentData.length,
                    itemBuilder: (context, index) {
                      final data = currentData[index];
                      final sensors = (data["sensors"] as List<dynamic>? ?? []);
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data["time"] ?? "Unknown",
                                  style: const TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...sensors.map((sensor) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Icon(sensorIcons[sensor["iconKey"]] ?? Icons.sensors, color: sensor["color"] ?? Colors.white),
                                      const SizedBox(width: 8),
                                      Text("${sensor["title"]}: ${sensor["value"]}${sensor["unit"] ?? ""}",
                                          style: const TextStyle(color: Colors.white, fontSize: 16)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
