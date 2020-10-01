// Flutter code sample for RaisedButton

// This sample shows how to render a disabled RaisedButton, an enabled RaisedButton
// and lastly a RaisedButton with gradient background.
//
// ![Three raised buttons, one enabled, another disabled, and the last one
// styled with a blue gradient background](https://flutter.github.io/assets-for-api-docs/assets/material/raised_button.png)
import 'package:flutter/material.dart';
import 'MQTTClientWrapper.dart';
import 'song.dart';

int uid;
bool voted = false;
String _song = "Placeholder";
String _artist = "Placeholder";

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test',
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

  void setup() {
    mqttClientWrapper = MQTTClientWrapper(() => init(), (s) => updateClient(s));
    mqttClientWrapper.prepareMqttClient();
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('$_song', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 10),
        Text('$_artist', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 30),
        _buildLikeButton(),
        const SizedBox(height: 10),
        _buildDislikeButton(),
      ],
    );
  }

  Widget _buildLikeButton() {
    return new RaisedButton(
      child: Text('Like', style: TextStyle(fontSize: 25)),
      onPressed: voted ? null : like,
    );
  }

  Widget _buildDislikeButton() {
    return new RaisedButton(
      child: Text('Dislike', style: TextStyle(fontSize: 25)),
      onPressed: voted ? null : dislike,
    );
  }

  void like() {
    //if (!voted) print('Liked');
    if (!voted) mqttClientWrapper.publishVote(true, uid);
    setState(() {
      voted = true;
    });
  }

  void dislike() {
    //if (!voted) print('Disliked');
    if (!voted) mqttClientWrapper.publishVote(false, uid);
    setState(() {
      voted = true;
    });
  }

  void init() {
    uid = 0;
    voted = false;
  }

  void updateClient(Song s) {
    setState(() {
      _song = s.song;
      _artist = s.artist;
      voted = false;
    });
  }
}
