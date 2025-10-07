class SensorReading {
  final DateTime ts;
  final int soil;
  final double temp;
  final double hum;

  SensorReading({
    required this.ts,
    required this.soil,
    required this.temp,
    required this.hum,
  });

  // Factory constructor अगर API/ThingSpeak JSON data से बनाना हो
  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      ts: DateTime.parse(json['ts'] ?? DateTime.now().toIso8601String()),
      soil: (json['soil'] as num?)?.toInt() ?? 0,
      temp: (json['temperature'] as num?)?.toDouble() ?? 0,
      hum: (json['humidity'] as num?)?.toDouble() ?? 0,
    );
  }
}
