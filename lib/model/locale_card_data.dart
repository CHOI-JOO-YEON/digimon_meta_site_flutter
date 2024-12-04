class LocaleCardData {
  String name;
  String? effect;
  String? sourceEffect;
  String locale;

  LocaleCardData(
      {this.effect,
      this.sourceEffect,
      required this.name,
      required this.locale});

  factory LocaleCardData.fromJson(Map<String, dynamic> json) {
    return LocaleCardData(
        name: json['name'],
        effect: json['effect'],
        sourceEffect: json['sourceEffect'],
        locale: json['locale']);
  }
}
