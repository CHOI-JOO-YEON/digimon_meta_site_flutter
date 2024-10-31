import 'package:flutter/material.dart';

class LangService {
  static final Map<String, String> _colorMap = {
    'RED': '레드',
    'BLUE': '블루',
    'YELLOW': '옐로우',
    'GREEN': '그린',
    'BLACK': '블랙',
    'PURPLE': '퍼플',
    'WHITE': '화이트',
  };
  static final Map<String, String> _cardTypeMap = {
    'DIGIMON': '디지몬',
    'TAMER': '테이머',
    'OPTION': '옵션',
    'DIGITAMA': '디지타마',
  };

  String getKorText(String text){
    String? result = _colorMap[text];
    if(result!=null){
      return result;
    }
    result = _cardTypeMap[text];
    if(result!=null){
      return result;
    }
    return 'ERROR';
  }
}
