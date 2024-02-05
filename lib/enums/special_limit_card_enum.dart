enum SpecialLimitCard {
  BT6_085('BT6-085',50),
  ;


  final String cardNo;
  final int limit;

  const SpecialLimitCard(this.cardNo, this.limit);

  String get getCardNo=> cardNo;
  int get getLimit=> limit;

  static int getLimitByCardNo(String cardNo){
    for (var card in SpecialLimitCard.values) {
      if(card.cardNo==cardNo) {
        return card.getLimit;
      }
    }
    return 4;
  }
}
