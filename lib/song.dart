class Song {
  String title;
  String artist;
  int songID;

  Song(String s, String a, int id) {
    title = s;
    artist = a;
    songID = id;
  }

  /// Decodes [json] to Song
  Song.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        artist = json['artist'],
        songID = json['songID'];

  /// Encodes Song to JSON
  Map<String, dynamic> toJson() =>
      {'title': title, 'artist': artist, 'songID': songID};
}
