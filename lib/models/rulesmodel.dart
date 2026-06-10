class Rulesmodel {
  final String ruleId;
  final String description;
  final String userId;

  Rulesmodel({
    required this.ruleId,
    required this.description,
    required this.userId,
  });

  factory Rulesmodel.fromJson(Map<String, dynamic> data, String id) {
    return Rulesmodel(
      ruleId: id,
      description: data["description"] ?? "",
      userId: data["userId"] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {"ruleId": ruleId, "description": description, "userId": userId};
  }
}
