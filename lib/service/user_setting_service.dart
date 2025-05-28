import 'package:flutter/material.dart';
import '../api/user_setting_api.dart';
import '../model/user_setting_dto.dart';
import '../model/sort_criterion_dto.dart';
import '../provider/user_provider.dart';
import '../provider/limit_provider.dart';
import '../provider/deck_sort_provider.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

class UserSettingService {
  static final UserSettingService _instance = UserSettingService._internal();
  factory UserSettingService() => _instance;
  UserSettingService._internal();

  final UserSettingApi _api = UserSettingApi();

  // 로컬 스토리지 키
  static const String _localePriorityKey = 'localePriority';
  static const String _defaultLimitIdKey = 'defaultLimitId';
  static const String _strictDeckKey = 'strictDeck';
  static const String _sortPriorityKey = 'sortPriority';

  // 사용자 설정 로드 (로그인 시 서버에서, 비로그인 시 로컬에서)
  Future<UserSettingDto> loadUserSetting(BuildContext context) async {
    final userProvider = UserProvider();
    
    if (userProvider.isLogin) {
      // 로그인된 경우 서버에서 설정 로드
      final serverSetting = await _api.getUserSetting();
      if (serverSetting != null) {
        // 서버 설정을 로컬에도 저장
        _saveToLocal(serverSetting);
        return serverSetting;
      }
    }
    
    // 비로그인이거나 서버에서 로드 실패 시 로컬에서 로드
    return _loadFromLocal();
  }

  // 사용자 설정 저장 (로그인 시 서버에, 항상 로컬에)
  Future<bool> saveUserSetting(BuildContext context, UserSettingDto setting) async {
    final userProvider = UserProvider();
    
    // 항상 로컬에 저장
    _saveToLocal(setting);
    
    if (userProvider.isLogin) {
      // 로그인된 경우 서버에도 저장
      return await _api.updateUserSetting(setting);
    }
    
    return true; // 비로그인 시에는 로컬 저장만 성공하면 true
  }

  // 로컬 스토리지에서 설정 로드
  UserSettingDto _loadFromLocal() {
    final localePriorityStr = html.window.localStorage[_localePriorityKey];
    final defaultLimitIdStr = html.window.localStorage[_defaultLimitIdKey];
    final strictDeckStr = html.window.localStorage[_strictDeckKey];
    final sortPriorityStr = html.window.localStorage[_sortPriorityKey];

    List<SortCriterionDto>? sortPriority;
    if (sortPriorityStr != null && sortPriorityStr.isNotEmpty) {
      // 기존 문자열 형식을 SortCriterionDto로 변환
      final sortStrings = sortPriorityStr.split(',').where((s) => s.isNotEmpty).toList();
      sortPriority = sortStrings.map((sortString) {
        List<String> parts = sortString.split(':');
        if (parts.length == 2) {
          return SortCriterionDto(
            field: parts[0],
            ascending: parts[1] == 'asc',
          );
        }
        return SortCriterionDto(field: sortString, ascending: true);
      }).toList();
    }

    return UserSettingDto(
      localePriority: localePriorityStr != null 
          ? localePriorityStr.split(',').where((s) => s.isNotEmpty).toList()
          : null,
      defaultLimitId: defaultLimitIdStr != null 
          ? int.tryParse(defaultLimitIdStr)
          : null,
      strictDeck: strictDeckStr != null 
          ? strictDeckStr.toLowerCase() == 'true'
          : null,
      sortPriority: sortPriority,
    );
  }

  // 로컬 스토리지에 설정 저장
  void _saveToLocal(UserSettingDto setting) {
    if (setting.localePriority != null) {
      html.window.localStorage[_localePriorityKey] = setting.localePriority!.join(',');
    }
    if (setting.defaultLimitId != null) {
      html.window.localStorage[_defaultLimitIdKey] = setting.defaultLimitId.toString();
    }
    if (setting.strictDeck != null) {
      html.window.localStorage[_strictDeckKey] = setting.strictDeck.toString();
    }
    if (setting.sortPriority != null) {
      // SortCriterionDto를 문자열 형식으로 변환하여 저장
      final sortStrings = setting.sortPriority!.map((criterion) => 
        '${criterion.field}:${criterion.ascending == true ? 'asc' : 'desc'}'
      ).toList();
      html.window.localStorage[_sortPriorityKey] = sortStrings.join(',');
    }
  }

  // 설정 초기화
  void clearSettings() {
    html.window.localStorage.remove(_localePriorityKey);
    html.window.localStorage.remove(_defaultLimitIdKey);
    html.window.localStorage.remove(_strictDeckKey);
    html.window.localStorage.remove(_sortPriorityKey);
  }

  // 설정을 Provider들에 자동 적용
  Future<void> applyUserSetting(BuildContext context, UserSettingDto setting) async {
    try {
      // 금제 설정 적용
      if (setting.defaultLimitId != null) {
        final limitProvider = Provider.of<LimitProvider>(context, listen: false);
        if (setting.defaultLimitId == 0) {
          // 최신 금제 선택 - 가장 최근 날짜의 금제 사용
          if (limitProvider.limits.isNotEmpty) {
            final latestLimit = limitProvider.limits.values
                .reduce((a, b) => a.restrictionBeginDate.isAfter(b.restrictionBeginDate) ? a : b);
            limitProvider.updateSelectLimit(latestLimit.restrictionBeginDate);
          }
        } else {
          // 특정 금제 ID 선택
          final targetLimit = limitProvider.limits.values
              .where((limit) => limit.id == setting.defaultLimitId)
              .firstOrNull;
          if (targetLimit != null) {
            limitProvider.updateSelectLimit(targetLimit.restrictionBeginDate);
          }
        }
      }

      // 정렬 우선순위 설정 적용
      if (setting.sortPriority != null && setting.sortPriority!.isNotEmpty) {
        final deckSortProvider = Provider.of<DeckSortProvider>(context, listen: false);
        List<SortCriterion> sortCriteria = [];
        
        for (SortCriterionDto sortDto in setting.sortPriority!) {
          sortCriteria.add(SortCriterion(
            sortDto.field,
            ascending: sortDto.ascending ?? true,
            orderMap: sortDto.orderMap,
          ));
        }
        
        if (sortCriteria.isNotEmpty) {
          deckSortProvider.setSortPriority(sortCriteria);
        }
      }
    } catch (e) {
      print('Error applying user settings: $e');
    }
  }
} 