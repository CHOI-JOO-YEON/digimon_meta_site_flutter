import 'package:flutter/foundation.dart';
import 'package:digimon_meta_site_flutter/api/limit_api.dart';
import 'package:digimon_meta_site_flutter/enums/special_limit_card_enum.dart';
import '../model/limit_dto.dart';

class TextSimplifyProvider with ChangeNotifier {
  static final TextSimplifyProvider _instance =
      TextSimplifyProvider._internal();

  factory TextSimplifyProvider() {
    return _instance;
  }

  TextSimplifyProvider._internal();

  bool isTextSimplify = true;

  void updateTextSimplify(bool newTextSimplify) {
    if (isTextSimplify != newTextSimplify) {
      isTextSimplify = newTextSimplify;
      notifyListeners();
    }
  }

  bool getTextSimplify() {
    return isTextSimplify;
  }
}
