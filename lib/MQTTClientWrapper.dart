import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'models.dart';
import 'constants.dart' as Constants;
import 'song.dart';
import 'vote.dart';

/// A class used for sending and receiving MQTT messages
class MQTTClientWrapper {
  // Client
  MqttClient client;

  // States
  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  // Callbacks
  final VoidCallback onConnectedCallback;
  final Function(Song) onSongReceivedCallback;

  /// Constructor
  MQTTClientWrapper(this.onConnectedCallback, this.onSongReceivedCallback);

  /// Initializes the MQT client
  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
    _subscribeToTopic(Constants.topicName);
  }

  /// Sets all variables for the MQTT connection
  void _setupMqttClient() {
    client =
        MqttServerClient.withPort(Constants.serverUri, '#', Constants.port);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;
  }

  /// Attempts to connect the client to the broker
  Future<void> _connectClient() async {
    try {
      debugPrint('MQTTClientWrapper::Client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      await client.connect();
    } on Exception catch (e) {
      debugPrint('MQTTClientWrapper::client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }

    if (client.connectionStatus.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      debugPrint('MQTTClientWrapper::Client connected');
    } else {
      debugPrint(
          'MQTTClientWrapper::ERROR Client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  /// Subscribes to the necessary topics
  void _subscribeToTopic(String topicName) {
    debugPrint('MQTTClientWrapper::Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atMostOnce);

    // Set up a listener
    client.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      if (c.isNotEmpty) {
        final MqttPublishMessage recMess = c[0].payload;
        final String payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        debugPrint("MQTTClientWrapper::New message $payload");

        Song s = Song.fromJson(jsonDecode(payload));
        onSongReceivedCallback(s);
      }
    });
  }

  /// Publishes the vote of the user
  void publishVote(Vote v) {
    _publishMessage(jsonEncode(v), Constants.outTopic);
  }

  /// Publishes a [message] to [topic]
  void _publishMessage(String message, String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    debugPrint(
        'MQTTClientWrapper::Publishing message $message to topic $topic');

    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload);
  }

  /// Runs when a subscripion is done
  void _onSubscribed(String topic) {
    debugPrint('MQTTClientWrapper::Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  /// Runs when the client is disconnected
  void _onDisconnected() {
    debugPrint(
        'MQTTClientWrapper::OnDisconnected client callback - Client disconnection');
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  /// Runs when the client connects
  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    debugPrint(
        'MQTTClientWrapper::OnConnected client callback - Client connection was sucessful');
    onConnectedCallback();
  }
}
