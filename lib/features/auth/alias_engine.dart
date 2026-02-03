import 'dart:math';

class AliasEngine {
  static String randomWord(List<String> words) {
    return words[Random().nextInt(words.length)];
  }

  static String get name {
    final newName = randomWord(_adjectives) + randomWord(_nouns);
    return newName;
  }

  static Map<String, String> splitWords(String alias) {
    final List<String> chars = alias.split('');
    for (int i = 2; i < chars.length; i++) {
      String char = alias[i];
      for (final letter in capitalLetters) {
        if (char == letter) {
          final adjective = alias.substring(0, i);
          final noun = alias.substring(i);
          return {"adjective": adjective, "noun": noun};
        }
      }
    }
    return {"adjective": 'adjective', "noun": "noun"};
  }

  static List<String> get _adjectives {
    return [
      "Absolute",
      "Belligerent",
      "Conspicuous",
      "Dastardly",
      "Elaborate",
      "Forgetful",
      "Ginormous",
      "Holistic",
      "Indignant",
      "Jolly",
      "Knarled",
      "Lopsided",
      "Mega",
      "Nuanced",
      "Ordinary",
      "Punctual",
      "Quintessential",
      "Rowdy",
      "Serpentine",
      "Titular",
      "Unnecessary",
      "Vacated",
      "Wayword",
      "Xenial",
      "Yielding",
      "Zombified",
      /////////////////////////////
      "Angry",
      "Bilingual",
      "Cantankerous",
      "Dangerous",
      "Elegant",
      "Frightened",
      "Gargantuan",
      "Holy",
      "Interested",
      "Jubilant",
      "Known",
      "Lengthy",
      "Marvelous",
      "Nice",
      "Open",
      "Playful",
      "Quarrelsome",
      "Reticent",
      "Sanguine",
      "Tepid",
      "Universal",
      "Vigilant",
      "Wrapped",
      //NO X,
      "Yester",
      "Zesty",
      /////////////////////////
      "Angry",
      "Bountiful",
      "Clandestine",
      "Determined",
      "Enthropic",
      "Flying",
      "Gnarly",
      "Honking",
      "Innocent",
      "Jaded",
      //K?
      "Lingering",
      "Myopic",
      "Nonchalant",
      "",

    ];
  }

  static List<String> get _nouns {
    return [
      "Antagonist",
      "Butler",
      "Cadavre",
      "Dumbwaiter",
      "Entropy",
      "Firefighter",
      "Grasshopper",
      "Hubbub",
      "Isotope",
      "Janitor",
      "Kitten",
      "Laboratory",
      "Monkeybusiness",
      "Nimrod",
      "Octopus",
      "Plant",
      "Quanity",
      "Road",
      "Sarcasm",
      "Torque",
      "Underdog",
      "Variance",
      "Workstation",
      "Xylophone",
      "Yak",
      "Zenith",
      "Astronaut",
      "Bump",
      "Crutch",
      "Doorbell",
      "Eggplant",
      "Flower",
      "Grain",
      "Hyperbole",
      "Illintent",
      "Junkyard",
      "Kenesis",
      "Larynx",
      "Moonshine",
      "Nog",
      "Octave",
      "Pushpin",
      "Quality",
      "Rascal",
      "Sunrise",
      "Trapazoid",
      "Upset",
      "Vocation",
      "Werewolf",
      //no x
      "Yule",
      "Zebra",
      "Albatross",
      "Ballpit",
      "Cuckoo",
      "Darkness",
      "Elbow",
      "Fluctuation",
      "Governer",
      "Helipad",
      "Ink",
      "Jester",
      "",
    ];
  }

  static List<String> capitalLetters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];
}
