import 'dart:convert';

import '../model/deck-build.dart';

enum SiteName {
  dev('Dev/DCGO'),
  tts('테이블탑 시뮬레이터');

  final String name;

  const SiteName(this.name);

  String get getName => name;
}
extension SiteNameMapExtension on SiteName {
  Map<String, int> convertStringToMap(String deckCode) {
    switch (this) {
      case SiteName.dev:
        return _convertStringToMapByDigimonDev(deckCode);
      case SiteName.tts:
        return _convertStringToMapByTTS(deckCode);
      default:
        return {};
    }
  }
  String ExportToSiteDeckCode(DeckBuild deck) {
    switch (this) {
      case SiteName.dev:
        return _convertDeckToDeckCodeByDev(deck);
      case SiteName.tts:
        return _convertDeckToDeckCodeByTTS(deck);
      default:
        return "";
    }
  }

  Map<String, int> _convertStringToMapByDigimonDev(String deckCode){
    Map<String, int> result = {};
    List<String> lines = deckCode.split('\n');

    for (String line in lines) {
      if (line.trim().isEmpty || line.trim().startsWith('//')) {
        continue;
      }

      List<String> parts = line.trim().split(RegExp('\\s+'));
      if (parts.length >= 2) {
        int cardCount = int.parse(parts[0]);
        String cardNo = parts[parts.length - 1];
        if (RegExp('.*\\D\$').hasMatch(cardNo)) {
          cardNo = cardNo.substring(0, cardNo.length - 2);
        }
        result[cardNo] = cardCount;
      }
    }

    return result;
  }


  Map<String, int> _convertStringToMapByTTS(String deckCode) {
    Map<String, int> result = {};
    List<dynamic> readStrings;
    try {
      readStrings = jsonDecode(deckCode);
    } catch (e) {
      throw 'JsonProcessingException: $e';
    }
    for (int i = 1; i < readStrings.length; i++) {
      String cardCode = readStrings[i];
      if (RegExp(r'\D$').hasMatch(cardCode)) {
        cardCode = cardCode.substring(0, cardCode.length - 1);
      }
      result.update(cardCode, (value) => value + 1, ifAbsent: () => 1);
    }


    return result;
  }

  String _convertDeckToDeckCodeByTTS(DeckBuild deck) {
    List<String> returnStrings = [];
    returnStrings.add("Exported from Digimon-Meta");
    for (var entry in deck.deckMap.entries) {
      for(int i=0;i<entry.value;i++){
        returnStrings.add(entry.key.cardNo!);
      }
    }

    for (var entry in deck.tamaMap.entries) {
      for(int i=0;i<entry.value;i++){
        returnStrings.add(entry.key.cardNo!);
      }
    }

    return jsonEncode(returnStrings);
  }

  String _convertDeckToDeckCodeByDev(DeckBuild deck) {
    StringBuffer stringBuffer = StringBuffer();

    for (var entry in deck.deckMap.entries) {
      stringBuffer.writeln('${entry.value} ${entry.key.cardNo}');
    }

    for (var entry in deck.tamaMap.entries) {
      stringBuffer.writeln('${entry.value} ${entry.key.cardNo}');
    }

    return stringBuffer.toString();
  }

}