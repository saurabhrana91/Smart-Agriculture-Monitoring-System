import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  final String broker;
  final int port;
  final String dataTopic;
  final String thresholdTopic;
  final String pumpTopic; // ✅ Pump topic

  late MqttServerClient _client;

  // callbacks
  void Function(bool connected)? onConnectionChanged;
  void Function(Map<String, dynamic> data)? onData;

  MQTTService({
    this.broker = "broker.hivemq.com",
    this.port = 1883,
    this.dataTopic = "agri/data",
    this.thresholdTopic = "agri/set_threshold",
    this.pumpTopic = "agri/pump_control", // ✅ Default pump topic
  });

  Future<void> connect() async {
    _client = MqttServerClient(
        broker, 'flutter_${DateTime.now().millisecondsSinceEpoch}');
    _client.port = port;
    _client.keepAlivePeriod = 30;
    _client.logging(on: false);
    _client.autoReconnect = true;
    _client.onConnected = () => onConnectionChanged?.call(true);
    _client.onDisconnected = () => onConnectionChanged?.call(false);

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier!)
        .startClean();
    _client.connectionMessage = connMess;

    try {
      await _client.connect();
    } catch (e) {
      onConnectionChanged?.call(false);
      _client.disconnect();
      return;
    }

    if (_client.connectionStatus?.state == MqttConnectionState.connected) {
      _client.subscribe(dataTopic, MqttQos.atMostOnce);
      _client.updates?.listen((events) {
        final rec = events.first;
        final MqttPublishMessage msg = rec.payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(msg.payload.message);
        try {
          final map = json.decode(pt) as Map<String, dynamic>;
          onData?.call(map);
        } catch (_) {
          // ignore non-JSON lines
        }
      });
    } else {
      onConnectionChanged?.call(false);
    }
  }

  void publishThreshold(int value) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(value.toString());
    _client.publishMessage(thresholdTopic, MqttQos.atMostOnce, builder.payload!);
  }

  // ✅ Pump control publish method
  void publishPump(String state) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(state); // "ON" or "OFF"
    _client.publishMessage(pumpTopic, MqttQos.atMostOnce, builder.payload!);
  }

  void disconnect() {
    _client.disconnect();
  }
}
