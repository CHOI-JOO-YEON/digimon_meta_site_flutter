class TypeDto {
  int typeId;
  String name;

  TypeDto({required this.typeId, required this.name});

  factory TypeDto.fromJson(Map<String, dynamic> json) {
    return TypeDto(
      typeId: json['id'],
      name: json['name'],
    );
  }
  static List<TypeDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => TypeDto.fromJson(json)).toList();
  }
}
