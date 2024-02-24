import 'package:digimon_meta_site_flutter/enums/special_limit_card_enum.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';

import 'card.dart';

class Deck{

  Deck.responseDto(DeckResponseDto deckResponseDto){
    deckId=deckResponseDto.deckId;
    deckName=deckResponseDto.deckName??'My Deck';
    if(deckResponseDto.cardAndCntMap!=null) {

      for (var cardEntry in deckResponseDto.cardAndCntMap!.entries) {
        for(int i=0;i<cardEntry.value;i++){
          addCard(cardEntry.key);
        }
      }
    }
  }
  Deck();


  int? deckId;
  Map<DigimonCard,int> deckMap={};
  List<DigimonCard> deckCards = [];
  Map<DigimonCard,int> tamaMap={};
  List<DigimonCard> tamaCards = [];
  Map<int,DigimonCard> cardMap ={};
  int deckCount=0;
  int tamaCount=0;
  String deckName = 'My Deck';

  void clear(){
    deckMap.clear();
    tamaMap.clear();
    deckCards.clear();
    tamaCards.clear();
    cardMap.clear();
    deckCount=0;
    tamaCount=0;
  }

  addCard(DigimonCard card){
    if(cardMap.containsKey(card.cardId)) {
      card = cardMap[card.cardId]!;
    }else{
      cardMap[card.cardId!]=card;
    }
    if(card.cardType=='DIGITAMA') {
      if (tamaMap.containsKey(card)) {
        if(tamaMap[card]!<SpecialLimitCard.getLimitByCardNo(card.cardNo!)){
          tamaMap[card] = tamaMap[card]! + 1;
          tamaCount++;

        }
      } else {
        tamaMap[card] = 1;
        tamaCards.add(card);
        tamaCards.sort(digimonCardComparator);
        tamaCount++;
      }
    }else {
      if (deckMap.containsKey(card)) {
        if(deckMap[card]!<SpecialLimitCard.getLimitByCardNo(card.cardNo!)){
          deckMap[card] = deckMap[card]! + 1;
          deckCount++;
        }
      } else {
        deckMap[card] = 1;
        deckCards.add(card);
        deckCards.sort(digimonCardComparator);
        deckCount++;
      }
    }
  }


  removeCard(DigimonCard card){
    if(card.cardType=='DIGITAMA') {
      if (tamaMap.containsKey(card)) {
        if(tamaMap[card]==1) {
          tamaMap.remove(card);
          tamaCards.remove(card);
          tamaCards.sort(digimonCardComparator);
          tamaCount--;

        }else{
          tamaMap[card] =tamaMap[card]!-1;
          tamaCount--;
        }
      }
    }else {
      if (deckMap.containsKey(card)) {
        if(deckMap[card]==1) {
          deckMap.remove(card);
          deckCards.remove(card);
          deckCards.sort(digimonCardComparator);
          deckCount--;
        }else{
          deckMap[card] =deckMap[card]!-1;
          deckCount--;
        }
      }
    }

  }

  static final Map<String, int> _colorOrder = {
    'RED': 1, 'BLUE': 2, 'YELLOW': 3, 'GREEN': 4, 'BLACK': 5, 'PURPLE': 6, 'WHITE': 7
  };
  static final Map<String, int> _cardTypeOrder = {
    'DIGIMON': 1, 'TAMER': 2, 'OPTION': 3
  };

  int digimonCardComparator(DigimonCard a, DigimonCard b) {
    // cardType 정렬
    if (a.cardType != b.cardType) {
      return _cardTypeOrder[a.cardType]!.compareTo(_cardTypeOrder[b.cardType]!);
    }


    // lv 오름차순
    if (a.lv!=null&&b.lv!=null&&a.lv != b.lv) {
      return a.lv!.compareTo(b.lv!);
    }

    // color1 정렬
    if (a.color1!=null&&b.color1!=null&&a.color1 != b.color1) {
      return _colorOrder[a.color1]!.compareTo(_colorOrder[b.color1]!);
    }

    if(a.playCost!=null&&b.playCost!=null&&a.playCost!=b.playCost) {
      return a.playCost!.compareTo(b.playCost!);
    }

    // sortString 오름차순
    if (a.sortString != b.sortString) {
      return a.sortString!.compareTo(b.sortString!);
    }

    // isParallel
    if (a.isParallel != b.isParallel) {
      return a.isParallel! ? 1 : -1;
    }

    return 0;
  }

}