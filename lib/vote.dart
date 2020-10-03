class Vote {
  int vote;
  int uid;
  String timestamp;
  int songID;

  Vote(int vote, int uid, String timestamp, int songID) {
    this.vote = vote;
    this.uid = uid;
    this.timestamp = timestamp;
    this.songID = songID;
  }

  /// Decodes [json] to Song
  Vote.fromJson(Map<String, dynamic> json)
      : vote = json['vote'],
        uid = json['uid'],
        timestamp = json['timestamp'],
        songID = json['songID'];

  /// Encodes Song to JSON
  Map<String, dynamic> toJson() =>
      {'vote': vote, 'uid': uid, 'timestamp': timestamp, 'songID': songID};
}
