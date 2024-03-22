class NoteDto {
  int? noteId;
  String name;
  DateTime? releaseDate;
  String? cardOrigin;

  NoteDto({required this.noteId, required this.name, this.releaseDate, this.cardOrigin});

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      noteId: json['noteId'],
      name: json['name'],
      releaseDate: json['releaseDate']!=null? DateTime.parse(json['releaseDate']):null,
      cardOrigin: json['cardOrigin']
    );
  }
  static List<NoteDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => NoteDto.fromJson(json)).toList();
  }
}
