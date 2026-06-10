enum Moods { happy, sad, angry, excited, bored }

//mood extention
extension MoodExtention on Moods {
  String get name {
    switch (this) {
      case Moods.happy:
        return "Happy";

      case Moods.angry:
        return "Angry";

      case Moods.sad:
        return "Sad";

      case Moods.excited:
        return "Excited";

      case Moods.bored:
        return "Bored";

      // ignore: unreachable_switch_default
      default:
        return " ";
    }
  }

  // ignore: non_constant_identifier_names
  String get Emogi {
    switch (this) {
      case Moods.happy:
        return "😊";

      case Moods.angry:
        return "😡";

      case Moods.sad:
        return "😢";

      case Moods.excited:
        return "😯";

      case Moods.bored:
        return "🫡";

      // ignore: unreachable_switch_default
      default:
        return " ";
    }
  }

  static Moods fromString(String moodString) {
    return Moods.values.firstWhere(
      (mood) => mood.name == moodString,
      orElse: () => Moods.happy,
    );
  }
}
