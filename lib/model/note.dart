class NoteDto {
  int? noteId;
  String name;
  DateTime? releaseDate;
  String? cardOrigin;
  int? priority;

  NoteDto({required this.noteId, required this.name, this.releaseDate, this.cardOrigin, this.priority});

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      noteId: json['noteId'],
      name: json['name'],
      releaseDate: json['releaseDate']!=null? DateTime.parse(json['releaseDate']):null,
      cardOrigin: json['cardOrigin'],
      priority:  json['priority']
    );
  }
  static List<NoteDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => NoteDto.fromJson(json)).toList();
  }
}
