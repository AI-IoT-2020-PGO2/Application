// Flutter code sample for RaisedButton

// This sample shows how to render a disabled RaisedButton, an enabled RaisedButton
// and lastly a RaisedButton with gradient background.
//
// ![Three raised buttons, one enabled, another disabled, and the last one
// styled with a blue gradient background](https://flutter.github.io/assets-for-api-docs/assets/material/raised_button.png)
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'constants.dart' as Constants;
import 'MQTTClientWrapper.dart';
import 'song.dart';
import 'vote.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

int uid;
bool voted = false;
Song _song = new Song('Placeholder', 'Placeholder', 0);

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      home: Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: Center(child: TextFieldEx()),
      ),
    );
  }
}

class TextFieldEx extends StatefulWidget {
  @override
  _TextFieldExState createState() => _TextFieldExState();
}

class _TextFieldExState extends State<TextFieldEx> {
  MQTTClientWrapper mqttClientWrapper;
  Song currentSong;

  /// Initializes the app
  @override
  void initState() {
    super.initState();
    _getUid();
    mqttClientWrapper =
        MQTTClientWrapper(() => init(), (s) => _updateClient(s));
    mqttClientWrapper.prepareMqttClient();
  }

  /// Reads data from the drive at [key]
  Future _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(key) ?? 0;
    debugPrint('Storage::' + value.toString() + ' read from key {' + key + '}');
    return value;
  }

  /// Saves [value] to the drive under [key]
  _save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
    debugPrint('Storage::' + value.toString() + ' saved on key {' + key + '}');
  }

  /// Gets a user ID from the backend
  _getUid() async {
    // See if there a UID already exists from a previous session
    int readUid = await _read('uid');

    if (readUid == 0 && kReleaseMode) {
      // If not and in release

      // Ask for a UID
      final response = await http.post(Constants.uidUrl);

      if (response.statusCode == 200) {
        // If the answer is received correctly

        // Assign the new UID
        setState(() {
          uid = json.decode(response.body);
        });
        // Save the UID for later sessions
        _save('uid', uid);
      } else {
        throw Exception('Failed to get UID');
      }
    } else if (readUid == 0 && !kReleaseMode) {
      // If a UID is needed in debug mode

      // Assign a set UID
      setState(() {
        uid = 1234;
      });
      // Save the UID for later sessions
      _save('uid', uid);
    } else {
      // If there already was a UID

      // Use the previous UID
      setState(() {
        uid = readUid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(_song.title, style: TextStyle(fontSize: 40)),
        const SizedBox(height: 10),
        Text(_song.artist, style: TextStyle(fontSize: 20)),
        const SizedBox(height: 30),
        _buildLikeButton(),
        const SizedBox(height: 10),
        _buildDislikeButton(),
      ],
    );
  }

  /// Builds the like button
  Widget _buildLikeButton() {
    return new RaisedButton(
      child: Text('Like', style: TextStyle(fontSize: 25)),
      // Used to disable and enable the button (If voted->null, else->like)
      onPressed: voted ? null : like,
    );
  }

  /// Builds the dislike button
  Widget _buildDislikeButton() {
    return new RaisedButton(
      child: Text('Dislike', style: TextStyle(fontSize: 25)),
      // Used to disable and enable the button (If voted->null, else->dislike)
      onPressed: voted ? null : dislike,
    );
  }

  /// Sends the backend a notification that the user liked this song
  void like() {
    Vote v = new Vote(1, uid, _getTime(), _song.songID);
    if (!voted) mqttClientWrapper.publishVote(v);
    setState(() {
      voted = true;
    });
  }

  /// Sends the backend a notification that the user disliked this song
  void dislike() {
    Vote v = new Vote(-1, uid, _getTime(), _song.songID);
    if (!voted) mqttClientWrapper.publishVote(v);
    setState(() {
      voted = true;
    });
  }

  /// Returns the current time in the correct format (yyyy/mm/dd hh:mm:ss)
  String _getTime() {
    var now = new DateTime.now();
    String out = now.year.toString().padLeft(4, '0') +
        '/' +
        now.month.toString().padLeft(2, '0') +
        '/' +
        now.day.toString().padLeft(2, '0') +
        ' ' +
        now.hour.toString().padLeft(2, '0') +
        ':' +
        now.minute.toString().padLeft(2, '0') +
        ':' +
        now.second.toString().padLeft(2, '0');

    return out;
  }

  /// Carried out when the MQTT connection is established
  void init() {}

  /// Called when a new MQTT message is received with info on the new song
  void _updateClient(Song s) {
    setState(() {
      _song = s;
      voted = false;
    });
  }
}
