class NoteDto {
  int? noteId;
  String name;
  DateTime? releaseDate;
  String? cardOrigin;
  int? priority;
  int? cardCount;
  bool? isDisable;
  String? description;
  String? parent;

  NoteDto({
    required this.noteId, 
    required this.name, 
    this.releaseDate, 
    this.cardOrigin, 
    this.priority,
    this.cardCount,
    this.isDisable,
    this.description,
    this.parent
  });

  factory NoteDto.fromJson(Map<String, dynamic> json) {
    return NoteDto(
      noteId: json['noteId'],
      name: json['name'],
      releaseDate: json['releaseDate']!=null? DateTime.parse(json['releaseDate']):null,
      cardOrigin: json['cardOrigin'],
      priority: json['priority'],
      cardCount: json['cardCount'],
      isDisable: json['isDisable'],
      description: json['description'],
      parent: json['parent']
    );
  }
  static List<NoteDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => NoteDto.fromJson(json)).toList();
  }
}
