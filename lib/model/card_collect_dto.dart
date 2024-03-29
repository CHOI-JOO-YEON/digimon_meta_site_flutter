class CardCollectDto {
  final int cardImgId;
  final int quantity;
  final String? cardNo;

  CardCollectDto({required this.cardImgId, required this.quantity,this.cardNo});

  Map<String, dynamic> toJson() {
    return {
      'cardImgId': cardImgId,
      'quantity': quantity,
    };
  }

  factory CardCollectDto.fromJson(Map<String, dynamic> json) {
    return CardCollectDto(
      cardImgId: json['cardImgId'],
      quantity: json['quantity'],
      cardNo: json['cardNo'],
    );
  }

  static List<CardCollectDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => CardCollectDto.fromJson(json)).toList();
  }
}