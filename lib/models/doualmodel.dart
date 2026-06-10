class DoualModel {
  final String doualId;
  final String player1Ids;
  final String player2Ids;
  final String player1Name;
  final String player2Name;
  final String player1Image;
  final String player2Image;

  DoualModel({
    required this.doualId,
    required this.player1Ids,
    required this.player2Ids,
    required this.player1Name,
    required this.player2Name,
    required this.player1Image,
    required this.player2Image,
  });

  factory DoualModel.fromJson(Map<String, dynamic> map) {
    return DoualModel(
      doualId: map['doualId'] ?? '',
      player1Ids: map['player1Ids'] ?? '',
      player2Ids: map['player2Ids'] ?? '',
      player1Name: map['player1Name'] ?? '',
      player2Name: map['player2Name'] ?? '',
      player1Image: map['player1Image'] ?? '',
      player2Image: map['player2Image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doualId': doualId,
      'player1Ids': player1Ids,
      'player2Ids': player2Ids,
      'player1Name': player1Name,
      'player2Name': player2Name,
      'player1Image': player1Image,
      'player2Image': player2Image,
    };
  }
}
