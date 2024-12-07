import 'dart:typed_data';

import 'package:digimon_meta_site_flutter/model/locale_card_data.dart';

import '../enums/form.dart';

class DigimonCard {
  int? cardId;
  String? cardNo;
  int? lv;
  int? dp;
  int? playCost;
  int? digivolveCost1;
  int? digivolveCondition1;
  int? digivolveCost2;
  int? digivolveCondition2;
  String? color1;
  String? color2;
  String? color3;
  String? rarity;
  String? cardType;
  String? form;
  String? attribute;
  List<String>? types;
  bool? isParallel;
  String? sortString;
  DateTime? releaseDate;
  String? noteName;
  int? noteId;
  bool isEn;
  List<LocaleCardData> localeCardData;

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

  String getDigivolveString1() {
    return 'Lv.$digivolveCondition1에서 $digivolveCost1';
  }

  String getDigivolveString2() {
    return 'Lv.$digivolveCondition2에서 $digivolveCost2';
  }

  DigimonCard(
      {this.cardId,
      this.cardNo,
      this.lv,
      this.dp,
      this.playCost,
      this.digivolveCost1,
      this.digivolveCondition1,
      this.digivolveCost2,
      this.digivolveCondition2,
      this.color1,
      this.color2,
      this.color3,
      this.rarity,
      this.cardType,
      this.form,
      this.attribute,
      this.types,
      this.isParallel,
      this.sortString,
      this.releaseDate,
      this.noteId,
      this.noteName,
      required this.isEn,
      required this.localeCardData});

  factory DigimonCard.fromJson(Map<String, dynamic> json) {
    return DigimonCard(
      cardId: json['cardId'],
      cardNo: json['cardNo'],
      lv: json['lv'],
      dp: json['dp'],
      playCost: json['playCost'],
      digivolveCost1: json['digivolveCost1'],
      digivolveCondition1: json['digivolveCondition1'],
      digivolveCost2: json['digivolveCost2'],
      digivolveCondition2: json['digivolveCondition2'],
      color1: json['color1'],
      color2: json['color2'],
      color3: json['color3'],
      rarity: json['rarity'],
      cardType: json['cardType'],
      form: json['form'],
      attribute: json['attribute'],
      types: json['types'] != null ? List<String>.from(json['types']) : null,
      isParallel: json['isParallel'],
      sortString: json['sortString'],
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'])
          : null,
      isEn: json['isEn'] ?? false,
      noteId: json['noteId'],
      noteName: json['noteName'],
      localeCardData: List<LocaleCardData>.from(
          json['localeCardData'].map((x) => LocaleCardData.fromJson(x))),
    );
  }

  String? getDisplayName() {
    return localeCardData.first.name;
  }

  String? getDisplayEffect() {
    return localeCardData.first.effect;
  }

  String? getDisplaySourceEffect() {
    return localeCardData.first.sourceEffect;
  }

  String? getDisplayLocale() {
    return localeCardData.first.locale;
  }

  String? getDisplayImgUrl() {
    return localeCardData.first.imgUrl;
  }
  String? getDisplaySmallImgUrl() {
    return localeCardData.first.smallImgUrl;
  }
}
