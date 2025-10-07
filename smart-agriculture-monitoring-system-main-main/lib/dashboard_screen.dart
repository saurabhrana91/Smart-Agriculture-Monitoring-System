import 'package:flutter/material.dart';
import 'sensor_card.dart';
import 'details_screen.dart';
import 'mqtt_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final mqtt = MQTTService();
  bool connected = false;

  double temp = 0, hum = 0;
  int soil = 0;
  int threshold = 30;

  bool pumpOn = false; // ✅ Pump status

  @override
  void initState() {
    super.initState();

    mqtt.onConnectionChanged = (c) {
      setState(() => connected = c);
    };

    mqtt.onData = (data) {
      setState(() {
        temp = (data["temp"] ?? 0).toDouble();
        hum = (data["hum"] ?? 0).toDouble();
        soil = (data["soil"] ?? 0).toInt();
        pumpOn = (data["pump"] ?? 0) == 1; // ✅ MQTT से pump status
      });
    };

    mqtt.connect();
  }

  @override
  void dispose() {
    mqtt.disconnect();
    super.dispose();
  }

  void togglePump() {
    setState(() => pumpOn = !pumpOn);
    mqtt.publishPump(pumpOn ? "ON" : "OFF"); // ✅ Pump control
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Text(
                            "Soil Sensor Dashboard",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "AI farm monitoring",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Connection banner
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: connected
                              ? [Colors.green, Colors.teal]
                              : [Colors.red, Colors.deepOrange],
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(connected ? Icons.wifi : Icons.wifi_off,
                              color: Colors.white, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  connected ? "Connected" : "Connection Error",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "broker.hivemq.com",
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              connected ? "ONLINE" : "OFFLINE",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Sensor cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          SensorCard(
                            title: "Soil Moisture",
                            value: soil.toString(),
                            unit: "%",
                            icon: Icons.water_drop,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 18),
                          SensorCard(
                            title: "Temperature",
                            value: temp.toStringAsFixed(1),
                            unit: "°C",
                            icon: Icons.thermostat,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 18),
                          SensorCard(
                            title: "Humidity",
                            value: hum.toStringAsFixed(1),
                            unit: "%",
                            icon: Icons.grain,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 18),

                          // ✅ Pump ON/OFF card
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: pumpOn ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.power_settings_new,
                                    size: 40, color: Colors.white),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    pumpOn ? "Pump is ON" : "Pump is OFF",
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: togglePump,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black87,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    pumpOn ? "Turn OFF" : "Turn ON",
                                    style:
                                        const TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Threshold slider
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Irrigation Threshold",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: threshold.toDouble(),
                                  min: 0,
                                  max: 100,
                                  divisions: 100,
                                  label: "$threshold%",
                                  onChanged: (v) =>
                                      setState(() => threshold = v.round()),
                                  onChangeEnd: (v) =>
                                      mqtt.publishThreshold(v.round()),
                                ),
                              ),
                              Text("$threshold%",
                                  style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Button at the bottom
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DetailsScreen()));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "View All Measurements",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
