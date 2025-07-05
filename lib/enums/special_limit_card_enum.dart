enum SpecialLimitCard {
  BT6_085('BT6-085',50),
  EX2_046('EX2-046',50),
  BT11_061('BT11-061',50),
  EX9_048('EX9-048',50),
  BT22_079('BT22-079',50),
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
