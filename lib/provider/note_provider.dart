import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../model/note.dart';

class NoteProvider with ChangeNotifier {
  static final NoteProvider _instance = NoteProvider._internal();
  factory NoteProvider() => _instance;
  NoteProvider._internal();

  List<NoteDto> _notes = [];
  bool _isInitialized = false;

  List<NoteDto> get notes => _notes;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // assets에서 notes.json 로드
      final String jsonString = await rootBundle.loadString('assets/data/notes.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // JSON을 NoteDto 객체로 파싱
      _notes = NoteDto.fromJsonList(jsonList);
      
      // 모든 카드 항목 추가
      _notes.insert(0, NoteDto(noteId: null, name: '모든 카드'));
      
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
  }
  
  Future<List<NoteDto>> getNotes() async {
    if (!_isInitialized) {
      await initialize();
    }
    return _notes;
  }
}