class TeamModel {
  final String teamid;
  final String teamName;
  final List<String> members;

  TeamModel({
    required this.teamid,
    required this.teamName,
    required this.members,
  });

  Map<String, dynamic> toMap() {
    return {'teamid': teamid, 'teamName': teamName, 'members': members};
  }

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      teamid: map['teamid'] ?? '',
      teamName: map['teamName'] ?? '',
      members: List<String>.from(map['members'] ?? []),
    );
  }
}
