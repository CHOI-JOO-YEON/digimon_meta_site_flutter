import 'dart:typed_data';

class DigimonCard{
  int? cardId;
  String? cardNo;
  String? cardName;
  int? lv;
  int? dp;
  int? playCost;
  int? digivolveCost1;
  int? digivolveCondition1;
  int? digivolveCost2;
  int? digivolveCondition2;
  String? effect;
  String? sourceEffect;
  String? color1;
  String? color2;
  String? rarity;
  String? cardType;
  String? form;
  String? attributes;
  List<String>? types;
  String? imgUrl;
  bool? isParallel;
  String? sortString;

  Uint8List? compressedImg;

  void setCompressedImg(Uint8List img) {
    compressedImg = img;
  }

  DigimonCard({
    this.cardId,
    this.cardNo,
    this.cardName,
    this.lv,
    this.dp,
    this.playCost,
    this.digivolveCost1,
    this.digivolveCondition1,
    this.digivolveCost2,
    this.digivolveCondition2,
    this.effect,
    this.sourceEffect,
    this.color1,
    this.color2,
    this.rarity,
    this.cardType,
    this.form,
    this.attributes,
    this.types,
    this.imgUrl,
    this.isParallel,
    this.sortString
  });

  factory DigimonCard.fromJson(Map<String, dynamic> json) {
    return DigimonCard(
      cardId: json['cardId'],
      cardNo: json['cardNo'],
      cardName: json['cardName'],
      lv: json['lv'],
      dp: json['dp'],
      playCost: json['playCost'],
      digivolveCost1: json['digivolveCost1'],
      digivolveCondition1: json['digivolveCondition1'],
      digivolveCost2: json['digivolveCost2'],
      digivolveCondition2: json['digivolveCondition2'],
      effect: json['effect'],
      sourceEffect: json['sourceEffect'],
      color1: json['color1'],
      // 직접 할당
      color2: json['color2'],
      // 직접 할당
      rarity: json['rarity'],
      // 직접 할당
      cardType: json['cardType'],
      // 직접 할당
      form: json['form'],
      // 직접 할당
      attributes: json['attributes'],
      types: json['types'] != null ? List<String>.from(json['types']) : null,
      imgUrl: json['imgUrl'],
      isParallel: json['isParallel'],
      sortString: json['sortString']
    );
  }

  Map<String, dynamic> toJson() => {
        'cardId': cardId,
        'cardNo': cardNo,
        'cardName': cardName,
        'lv': lv,
        'dp': dp,
        'playCost': playCost,
        'digivolveCost1': digivolveCost1,
        'digivolveCondition1': digivolveCondition1,
        'digivolveCost2': digivolveCost2,
        'digivolveCondition2': digivolveCondition2,
        'effect': effect,
        'sourceEffect': sourceEffect,
        // Handle the toJson for complex types or enums
        'color1': color1,
        'color2': color2,
        'rarity': rarity,
        'cardType': cardType,
        'form': form,
        'attributes': attributes,
        'types':
            types != null ? List<dynamic>.from(types!.map((x) => x)) : null,
        'imgUrl': imgUrl,
        'isParallel': isParallel,
        'sortString': sortString

      };
}
