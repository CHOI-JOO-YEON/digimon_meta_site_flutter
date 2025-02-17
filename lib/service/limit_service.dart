import 'dart:math';

import 'package:digimon_meta_site_flutter/model/card.dart';

import '../enums/special_limit_card_enum.dart';
import '../provider/limit_provider.dart';

class LimitService {
  int getCardLimit(DigimonCard card) {
    return min(LimitProvider().getCardAllowedQuantity(card.cardNo!),
        SpecialLimitCard.getLimitByCardNo(card.cardNo!));
  }

  bool isAllowedByLimitPair(String cardNo, Set<String> deckCardNos) {
    return LimitProvider().isAllowedByLimitPair(cardNo, deckCardNos);
  }
}
