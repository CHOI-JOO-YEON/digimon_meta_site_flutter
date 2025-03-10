class TypeDto {
  int typeId;
  String name;

  TypeDto({required this.typeId, required this.name});

  Map<String, dynamic> toJson() {
    return {
      'typeId': typeId,
      'name': name,
    };
  }

  String toString() {
    return 'TypeDto(typeId: $typeId, name: $name)';
  }

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
