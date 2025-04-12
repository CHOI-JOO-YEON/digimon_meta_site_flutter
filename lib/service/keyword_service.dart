import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 카테고리 데이터 모델
class KeywordCategory {
  final String name;
  final String description;
  final List<KeywordPattern> patterns;

  KeywordCategory({
    required this.name,
    required this.description,
    required this.patterns,
  });

  factory KeywordCategory.fromJson(Map<String, dynamic> json) {
    final List<dynamic> patternsJson = json['patterns'] ?? [];
    
    return KeywordCategory(
      name: json['name'] as String,
      description: json['description'] as String,
      patterns: patternsJson.map((pattern) => KeywordPattern.fromJson(pattern)).toList(),
    );
  }
}

/// 패턴 기반 키워드 데이터 모델
class KeywordPattern {
  final String pattern;
  final String description;
  final RegExp regExp;

  KeywordPattern({
    required this.pattern,
    required this.description,
  }) : regExp = RegExp(pattern);

  factory KeywordPattern.fromJson(Map<String, dynamic> json) {
    return KeywordPattern(
      pattern: json['pattern'] as String,
      description: json['description'] as String,
    );
  }

  /// 패턴에 맞는 설명 생성
  String generateDescription(String keyword) {
    final match = regExp.firstMatch(keyword);
    if (match == null) return '';

    String result = description;
    // 캡처 그룹을 {1}, {2} 등의 플레이스홀더로 대체
    for (int i = 1; i <= match.groupCount; i++) {
      result = result.replaceAll('{$i}', match.group(i) ?? '');
    }
    return result;
  }

  /// 키워드가 이 패턴에 맞는지 확인
  bool isMatch(String keyword) {
    return regExp.hasMatch(keyword);
  }
}

/// 키워드 관리 서비스
class KeywordService {
  static final KeywordService _instance = KeywordService._internal();
  factory KeywordService() => _instance;
  KeywordService._internal();

  List<KeywordCategory> _categories = [];
  bool _isLoaded = false;

  /// 키워드 데이터 로딩
  Future<void> loadKeywords() async {
    if (_isLoaded) return;
    
    try {
      // assets에서 키워드 JSON 파일 로딩
      final String jsonString = await rootBundle.loadString('assets/data/keyword.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // 카테고리 목록 추출
      final List<dynamic> categoriesJson = jsonData['categories'];
      _categories = categoriesJson.map((json) => KeywordCategory.fromJson(json)).toList();
      
      _isLoaded = true;
    } catch (e) {
      debugPrint('키워드 데이터 로딩 실패: $e');
      _categories = [];
    }
  }

  /// 특정 카테고리 찾기
  KeywordCategory? getCategory(String name) {
    if (!_isLoaded) {
      debugPrint('키워드 데이터가 로딩되지 않았습니다. loadKeywords()를 먼저 호출하세요.');
      return null;
    }
    
    try {
      return _categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  /// 모든 카테고리 가져오기
  List<KeywordCategory> getAllCategories() {
    if (!_isLoaded) {
      debugPrint('키워드 데이터가 로딩되지 않았습니다. loadKeywords()를 먼저 호출하세요.');
      return [];
    }
    
    return List.from(_categories);
  }

  /// 카테고리에서 패턴 찾기
  KeywordPattern? _findPatternInCategory(KeywordCategory category, String name) {
    for (final pattern in category.patterns) {
      if (pattern.isMatch(name)) {
        return pattern;
      }
    }
    return null;
  }

  /// 패턴 매칭을 시도하여 설명 가져오기
  Map<String, dynamic>? _findMatchingPattern(String name) {
    // 1. 모든 카테고리에서 정확한 이름 일치 확인
    for (final category in _categories) {
      if (category.name == name) {
        return {
          'category': category,
          'pattern': null,
        };
      }
    }
    
    // 2. 모든 카테고리의 패턴에서 매칭 확인
    for (final category in _categories) {
      final pattern = _findPatternInCategory(category, name);
      if (pattern != null) {
        return {
          'category': category,
          'pattern': pattern,
        };
      }
    }
    
    // 3. 내부 괄호를 제거한 형태로 다시 시도
    final nestedBracketStart = name.indexOf('《');
    final nestedBracketEnd = name.lastIndexOf('》');
    if (nestedBracketStart != -1 && nestedBracketEnd != -1 && nestedBracketStart < nestedBracketEnd) {
      // 내부 괄호 전까지의 텍스트만 추출 (예: "리커버리 +1 《덱》" -> "리커버리 +1")
      final simplifiedName = name.substring(0, nestedBracketStart).trim();
      
      for (final category in _categories) {
        final pattern = _findPatternInCategory(category, simplifiedName);
        if (pattern != null) {
          return {
            'category': category,
            'pattern': pattern,
          };
        }
      }
    }
    
    return null;
  }

  /// 키워드에 대한 설명 텍스트 가져오기
  String getKeywordDescription(String name) {
    if (!_isLoaded) {
      debugPrint('키워드 데이터가 로딩되지 않았습니다. loadKeywords()를 먼저 호출하세요.');
      return '키워드 데이터가 로딩되지 않았습니다.';
    }
    
    // 카테고리 및 패턴 매칭 시도
    final match = _findMatchingPattern(name);
    if (match != null) {
      final category = match['category'] as KeywordCategory;
      final pattern = match['pattern'] as KeywordPattern?;
      
      if (pattern != null) {
        return pattern.generateDescription(name);
      } else {
        return category.description;
      }
    }
    
    // 매칭되는 것이 없는 경우
    return '이 효과에 대한 자세한 설명이 없습니다.';
  }
} 