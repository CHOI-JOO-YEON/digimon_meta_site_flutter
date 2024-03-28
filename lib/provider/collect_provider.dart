import 'package:digimon_meta_site_flutter/model/card_collect_dto.dart';
import 'package:flutter/foundation.dart';
import '../api/collect_api.dart';

class CollectProvider with ChangeNotifier {
  bool collectMode = false;
  Map<int, int> collectMap ={};

  void clear(){
    collectMode=false;
    collectMap={};
  }

  Future<void> initialize() async {
    clear();
    List<CardCollectDto>? list = await CollectApi().getCollect();
    if (list != null) {
      for (CardCollectDto cardCollect in list) {
        collectMap[cardCollect.cardImgId]=cardCollect.quantity;
      }
    }
    notifyListeners();
  }

  Future<bool> save() async {
    List<CardCollectDto> list = [];
    for (var c in collectMap.entries) {
      list.add(CardCollectDto(cardImgId: c.key, quantity: c.value));
    }

    bool isSave =  await CollectApi().postCollect(list);

    if(!isSave) {
      return false;
    }



    List<CardCollectDto>? newList = await CollectApi().getCollect();

    clear();
    if (list != null) {
      for (CardCollectDto cardCollect in list) {
        collectMap[cardCollect.cardImgId]=cardCollect.quantity;
      }
    }
    notifyListeners();
    return true;
  }

  int getCardQuantity(int cardImgId) {
    if(collectMap.containsKey(cardImgId)) {
      return collectMap[cardImgId]!;
    }
    return 0;
  }

  void addCard(int cardImgId) {
    collectMap[cardImgId] =( collectMap[cardImgId]??0)+1;
    notifyListeners();
  }

  void removeCard(int cardImgId) {
    int? now =  collectMap[cardImgId];

    if(now!=null&&now>0) {
      collectMap[cardImgId]=now-1;
    }
    notifyListeners();
  }


}