import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/card_collect_dto.dart';
import 'package:flutter/foundation.dart';
import '../api/collect_api.dart';

class CollectProvider with ChangeNotifier {
  bool collectMode = false;
  Map<int, int> collectMapById ={};
  Map<String, int> collectMapByCardNo ={};

  void clear(){
    collectMode=false;
    collectMapById={};
    collectMapByCardNo={};
  }

  Future<void> initialize() async {
    clear();
    List<CardCollectDto>? list = await CollectApi().getCollect();
    if (list != null) {
      for (CardCollectDto cardCollect in list) {
        collectMapById[cardCollect.cardImgId]=cardCollect.quantity;

        collectMapByCardNo[cardCollect.cardNo!] =( collectMapByCardNo[cardCollect.cardNo!]??0)+cardCollect.quantity;
      }
    }
    notifyListeners();
  }

  Future<bool> save() async {
    List<CardCollectDto> list = [];
    for (var c in collectMapById.entries) {
      list.add(CardCollectDto(cardImgId: c.key, quantity: c.value));
    }

    bool isSave =  await CollectApi().postCollect(list);

    if(!isSave) {
      return false;
    }

    List<CardCollectDto>? newList = await CollectApi().getCollect();

    clear();
    if (newList != null) {
      for (CardCollectDto cardCollect in newList) {
        collectMapById[cardCollect.cardImgId]=cardCollect.quantity;
        collectMapByCardNo[cardCollect.cardNo!] = (collectMapByCardNo[cardCollect.cardNo!] ?? 0) + cardCollect.quantity;
      }
    }
    notifyListeners();
    return true;
  }

  int getCardQuantityById(int cardImgId) {
    if(collectMapById.containsKey(cardImgId)) {
      return collectMapById[cardImgId]!;
    }
    return 0;
  }

  int getCardQuantityByCardNo(String cardNo) {
    if(collectMapByCardNo.containsKey(cardNo)) {
      return collectMapByCardNo[cardNo]!;
    }
    return 0;
  }

  void addCard(DigimonCard card) {
    collectMapById[card.cardId!] =( collectMapById[card.cardId!]??0)+1;
    collectMapByCardNo[card.cardNo!] =( collectMapByCardNo[card.cardNo!]??0)+1;
    notifyListeners();
  }

  void removeCard(DigimonCard card) {
    int? nowCardId =  collectMapById[card.cardId];

    if(nowCardId!=null&&nowCardId>0) {
      collectMapById[card.cardId!]=nowCardId-1;
    }


    int? nowCardNo=  collectMapByCardNo[card.cardNo!];

    if(nowCardNo!=null&&nowCardNo>0) {
      collectMapByCardNo[card.cardNo!]=nowCardNo-1;
    }
    notifyListeners();
  }


}