import 'sort_criterion_dto.dart';

class UserSettingDto {
  final List<String>? localePriority;
  final int? defaultLimitId;
  final bool? strictDeck;
  final List<SortCriterionDto>? sortPriority;

  UserSettingDto({
    this.localePriority,
    this.defaultLimitId,
    this.strictDeck,
    this.sortPriority,
  });

  factory UserSettingDto.fromJson(Map<String, dynamic> json) {
    return UserSettingDto(
      localePriority: json['localePriority'] != null
          ? List<String>.from(json['localePriority'] as List)
          : null,
      defaultLimitId: json['defaultLimitId'] as int?,
      strictDeck: json['strictDeck'] as bool?,
      sortPriority: json['sortPriority'] != null
          ? (json['sortPriority'] as List)
              .map((item) => SortCriterionDto.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localePriority': localePriority,
      'defaultLimitId': defaultLimitId,
      'strictDeck': strictDeck,
      'sortPriority': sortPriority?.map((item) => item.toJson()).toList(),
    };
  }
} 