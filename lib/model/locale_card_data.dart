class LocaleCardData {
  String name;
  String? effect;
  String? sourceEffect;
  String locale;
  String? imgUrl;
  String? smallImgUrl;

  LocaleCardData(
      {this.effect,
      this.sourceEffect,
      required this.name,
      required this.locale,
      this.imgUrl,
      this.smallImgUrl});

  factory LocaleCardData.fromJson(Map<String, dynamic> json) {
    return LocaleCardData(
      name: json['name'],
      effect: json['effect'],
      sourceEffect: json['sourceEffect'],
      locale: json['locale'],
      imgUrl: json['imgUrl'],
      smallImgUrl: json['smallImgUrl'],
    );
  }
}
