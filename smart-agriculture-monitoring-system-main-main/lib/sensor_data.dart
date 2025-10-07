class SensorData {
  final DateTime timestamp;
  final double soilMoisture;
  final double temperature;
  final double humidity;

  SensorData({
    required this.timestamp,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
  });

  static List<SensorData> generateDummyData() {
    final now = DateTime.now();
    return List.generate(50, (index) {
      final time = now.subtract(Duration(hours: index));
      return SensorData(
        timestamp: time,
        soilMoisture: 40 + index % 10,
        temperature: 24 + index % 5,
        humidity: 55 + index % 10,
      );
    });
  }
}