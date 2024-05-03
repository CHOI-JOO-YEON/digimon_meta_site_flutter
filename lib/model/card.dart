import 'dart:typed_data';

import '../enums/form.dart';

class DigimonCard {
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
  String? color3;
  String? rarity;
  String? cardType;
  String? form;
  String? attributes;
  List<String>? types;
  String? imgUrl;
  String? smallImgUrl;
  bool? isParallel;
  String? sortString;
  DateTime? releaseDate;
  String? noteName;
  int? noteId;
  bool isEn;

  // Uint8List? compressedImg;

  String getKorCardType() {
    switch (cardType) {
      case 'DIGITAMA':
        return '디지타마';
      case 'DIGIMON':
        return '디지몬';
      case 'OPTION':
        return '옵션';
      case 'TAMER':
        return '테이머';
    }
    return '';
  }

  String getKorForm() {
    switch (form) {
      case 'IN_TRAINING':
        return '유년기';
      case 'ROOKIE':
        return '성장기';
      case 'CHAMPION':
        return '성숙기';
      case 'ULTIMATE':
        return '완전체';
      case 'MEGA':
        return '궁극체';
      case 'ARMOR':
        return '아머체';
      case 'D_REAPER':
        return '디・리퍼';
      case 'UNKNOWN':
        return '불명';
      case 'HYBRID':
        return '하이브리드체';
      default:
        return '';
    }
  }

  String getTypeString() {
    return types!.join("/");
  }

  String getFormString() {
    return Form.findKorNameByName(form!);
  }

  // void setCompressedImg(Uint8List img) {
  //   compressedImg = img;
  // }

  String getDigivolveString1() {
    return 'Lv.$digivolveCondition1에서 $digivolveCost1';
  }

  String getDigivolveString2() {
    return 'Lv.$digivolveCondition2에서 $digivolveCost2';
  }

  DigimonCard(
      {this.cardId,
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
      this.color3,
      this.rarity,
      this.cardType,
      this.form,
      this.attributes,
      this.types,
      this.imgUrl,
      this.isParallel,
      this.sortString,
      this.smallImgUrl,
      this.releaseDate,
      this.noteId,
      this.noteName,
      required this.isEn});

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
        color2: json['color2'],
        color3: json['color3'],
        rarity: json['rarity'],
        cardType: json['cardType'],
        form: json['form'],
        attributes: json['attributes'],
        types: json['types'] != null ? List<String>.from(json['types']) : null,
        imgUrl: json['imgUrl'],
        smallImgUrl: json['smallImgUrl'],
        isParallel: json['isParallel'],
        sortString: json['sortString'],
        releaseDate: json['releaseDate'] != null
            ? DateTime.parse(json['releaseDate'])
            : null,
        isEn: json['isEn'] ?? false,
        noteId: json['noteId'],
        noteName: json['noteName']);
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
        'color1': color1,
        'color2': color2,
        'color3': color3,
        'rarity': rarity,
        'cardType': cardType,
        'form': form,
        'attributes': attributes,
        'types':
            types != null ? List<dynamic>.from(types!.map((x) => x)) : null,
        'imgUrl': imgUrl,
        'isParallel': isParallel,
        'sortString': sortString,
        'smallImgUrl': smallImgUrl,
        'releaseDate': releaseDate,
      };
}
