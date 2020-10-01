import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'models.dart';
import 'constants.dart' as Constants;
import 'song.dart';

class MQTTClientWrapper {
  MqttClient client;

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  final VoidCallback onConnectedCallback;
  final Function(Song) onSongReceivedCallback;

  MQTTClientWrapper(this.onConnectedCallback, this.onSongReceivedCallback);

  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
    _subscribeToTopic(Constants.topicName);
  }

  void _setupMqttClient() {
    client =
        MqttServerClient.withPort(Constants.serverUri, '#', Constants.port);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  Future<void> _connectClient() async {
    try {
      print('MQTTClientWrapper::Client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      await client.connect();
    } on Exception catch (e) {
      print('MQTTClientWrapper::client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }

    if (client.connectionStatus.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print('MQTTClientWrapper::Client connected');
    } else {
      print(
          'MQTTClientWrapper::ERROR Client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  void _subscribeToTopic(String topicName) {
    print('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);

    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      if (c.isNotEmpty) {
        final MqttPublishMessage recMess = c[0].payload;
        final String payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        print("MQTTClientWrapper::New message $payload");

        if (payload.contains('|||')) {
          var newSong = payload.split('|||');
          Song s = new Song(newSong[0], newSong[1]);

          if (newSong != null) {
            onSongReceivedCallback(s);
          }
        }
      }
    });
  }

  void publishVote(bool liked, int uid) {
    var now = new DateTime.now();
    String message = uid.toString() +
        '|' +
        now.hour.toString() +
        ':' +
        now.minute.toString() +
        ':' +
        now.second.toString() +
        '|';
    if (liked) {
      message += 't';
    } else {
      message += 'f';
    }
    _publishMessage(message);
  }

  void _publishMessage(String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    print(
        'MQTTClientWrapper::Publishing message $message to topic ${Constants.topicName}');

    client.publishMessage(
        Constants.outTopic, MqttQos.atMostOnce, builder.payload);
  }

  void _onSubscribed(String topic) {
    print('MQTTClientWrapper::Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void _onDisconnected() {
    print(
        'MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    onConnectedCallback();
  }
}
