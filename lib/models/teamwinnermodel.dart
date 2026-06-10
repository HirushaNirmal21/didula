class TeamWinnerModel {
  final String winteamid;
  final String winteamName;
  final List<String> membersId;

  TeamWinnerModel({
    required this.winteamid,
    required this.winteamName,
    required this.membersId,
  });

  Map<String, dynamic> toMap() {
    return {
      'winteamid': winteamid,
      'winteamName': winteamName,
      'memberId': membersId,
    };
  }

  factory TeamWinnerModel.fromMap(Map<String, dynamic> map) {
    return TeamWinnerModel(
      winteamid: map['winteamid'] ?? '',
      winteamName: map['winteamName'] ?? '',
      membersId: List<String>.from(map['memberId'] ?? []),
    );
  }
}
