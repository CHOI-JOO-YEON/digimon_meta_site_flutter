class FormatDto {
  int formatId;
  String? name;
  DateTime startDate;
  DateTime endDate;
  bool? isOnlyEn;


  FormatDto({required this.formatId, required this.name, required this.startDate,required this.endDate, this.isOnlyEn});

  factory FormatDto.fromJson(Map<String, dynamic> json) {
    return FormatDto(
      formatId: json['id'],
      name: json['formatName'],
      startDate:  DateTime.parse(json['startDate']) ,
      endDate: DateTime.parse(json['endDate']) ,
      isOnlyEn: json['isOnlyEn']??false
    );
  }
  static List<FormatDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => FormatDto.fromJson(json)).toList();
  }

  @override
  String toString() {
    // TODO: implement toString
    return 'formatId: $formatId\t name :$name\t $startDate ~ $endDate';

  }
}
