// Flutter code sample for RaisedButton

// This sample shows how to render a disabled RaisedButton, an enabled RaisedButton
// and lastly a RaisedButton with gradient background.
//
// ![Three raised buttons, one enabled, another disabled, and the last one
// styled with a blue gradient background](https://flutter.github.io/assets-for-api-docs/assets/material/raised_button.png)
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  String _song = "Placeholder";
  String _artist = "Placeholder";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('$_song', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 10),
        Text('$_artist', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 30),
        RaisedButton(
          onPressed: () => like(),
          child: Text('Like', style: TextStyle(fontSize: 25)),
        ),
        const SizedBox(height: 10),
        RaisedButton(
          onPressed: () => dislike(),
          child: Text('Dislike', style: TextStyle(fontSize: 25)),
        ),
      ],
    );
  }

  void like() {}

  void dislike() {}
}
