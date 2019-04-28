class Menu {
  int id;
  String title;
  bool statut;
  String image;

  Menu.fromJson(Map jsonMap)
    : id = jsonMap['id'] as int,
      title = jsonMap['title'],
      image = jsonMap['image'],
      statut = jsonMap['statut'] ?? false;
}




class PF {
  int id;
  String title;
  String subtitle;
  bool statut;

  PF.fromJson(Map jsonMap)
    : id = jsonMap['id'] as int,
      title = jsonMap['title'],
      subtitle = jsonMap['subtitle'],
      statut = jsonMap['statut'] ?? false;
}


class Methode {
  int id;
  String title;
  String subtitle;
  String avantage;
  String inconvenient;
  String audio_ha;
  String audio_za;
  String numero;
  String image;
  bool statut;

  Methode.fromJson(Map jsonMap)
    : id = jsonMap['id'] as int,
      title = jsonMap['title'],
      subtitle = jsonMap['subtitle'],
      avantage = jsonMap['avantage'],
      inconvenient = jsonMap['inconvenient'],
      audio_ha = jsonMap['audio_ha'],
      audio_za = jsonMap['audio_za'],
      numero = jsonMap['numero'],
      image = jsonMap['image'] ?? '',
      statut = jsonMap['statut'] ?? false;
}