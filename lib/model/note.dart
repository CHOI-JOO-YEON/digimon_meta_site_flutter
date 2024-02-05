class NoteDto {
  int? noteId;
  String name;

  NoteDto({required this.noteId, required this.name});

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      noteId: json['noteId'],
      name: json['name'],
    );
  }
  static List<NoteDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => NoteDto.fromJson(json)).toList();
  }
}
