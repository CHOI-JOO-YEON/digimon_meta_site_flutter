class SortCriterionDto {
  final String field;
  final bool? ascending;
  final Map<String, int>? orderMap;

  SortCriterionDto({
    required this.field,
    this.ascending,
    this.orderMap,
  });

  factory SortCriterionDto.fromJson(Map<String, dynamic> json) {
    return SortCriterionDto(
      field: json['field'] as String,
      ascending: json['ascending'] as bool?,
      orderMap: json['orderMap'] != null 
          ? Map<String, int>.from(json['orderMap'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'ascending': ascending,
      'orderMap': orderMap,
    };
  }
} 