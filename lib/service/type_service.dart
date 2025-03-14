
import '../api/card_api.dart';
import '../model/type.dart';

class TypeService {
  static final TypeService _instance = TypeService._internal();

  factory TypeService() {
    return _instance;
  }

  TypeService._internal();

  Map<String, TypeDto> map={};


  void insert(TypeDto typeDto) {
    map[typeDto.name]=typeDto;
  }

  Map<int, TypeDto> search(String word) {
    Map<int, TypeDto> result = {};

    for (MapEntry<String,TypeDto> entry in map.entries) {
      if(entry.key.contains(word)) {
        result[entry.value.typeId] = entry.value;
      }
    }
    return result;
  }

  Future<void> init() async {
    if(map.isEmpty) {
      List<TypeDto> types = await CardApi().getTypes();
      for (var type in types) {
        TypeService().insert(type);
      }
    }
  }

}
