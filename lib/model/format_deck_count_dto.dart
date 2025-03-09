class FormatDeckCountDto {
  Map<int, int> formatAllDeckCount;
  Map<int, int> formatMyDeckCount;

  FormatDeckCountDto({
    required this.formatAllDeckCount,
    required this.formatMyDeckCount,
  });

  factory FormatDeckCountDto.fromJson(Map<String, dynamic> json) {
    // Parse the formatAllDeckCount
    Map<int, int> allDeckCount = {};
    List<dynamic> allDeckCountList = json['allFormatCount'] ?? [];
    for (var item in allDeckCountList) {
      allDeckCount[item['formatId']] = item['count'];
    }

    // Parse the formatMyDeckCount
    Map<int, int> myDeckCount = {};
    List<dynamic> myDeckCountList = json['myFormatCount'] ?? [];
    for (var item in myDeckCountList) {
      myDeckCount[item['formatId']] = item['count'];
    }

    return FormatDeckCountDto(
      formatAllDeckCount: allDeckCount,
      formatMyDeckCount: myDeckCount,
    );
  }
}