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
      : vote = json['score'],
        uid = json['userID'],
        timestamp = json['timestamp'],
        songID = json['songID'];

  /// Encodes Song to JSON
  Map<String, dynamic> toJson() =>
      {'score': vote, 'userID': uid, 'timestamp': timestamp, 'songID': songID};
}
