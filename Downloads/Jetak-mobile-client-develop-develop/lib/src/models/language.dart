class Language {
  String code;
  String englishName;
  String localName;
  String flag;
  bool selected;
  bool isSvgFlag;

  Language(this.code, this.englishName, this.localName, this.flag, {this.selected = false, this.isSvgFlag = false});
}

class LanguagesList {
  final List<Language> _languages = [
    Language("en", "English", "English", "assets/img/united-states-of-america.png"),
    Language("he", "Hebrew", "עִברִית", "assets/img/israel_flag.svg", isSvgFlag: true),
    Language("ar", "Arabic", "العربية", "assets/img/united-arab-emirates.png"),
    // Language("es", "Spanish", "Spana", "assets/img/spain.png"),
    // Language("fr", "French (France)", "Français - France", "assets/img/france.png"),
    // Language("fr_CA", "French (Canada)", "Français - Canadien", "assets/img/canada.png"),
    // Language("pt_BR", "Portugese (Brazil)", "Brazilian", "assets/img/brazil.png"),
    // Language("ko", "Korean", "Korean", "assets/img/united-states-of-america.png"),
  ];

  List<Language> get languages => _languages;
}
