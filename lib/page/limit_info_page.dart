import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/model/limit_dto.dart';
import 'package:digimon_meta_site_flutter/model/limit_comparison.dart';
import 'package:digimon_meta_site_flutter/provider/limit_provider.dart';
import 'package:digimon_meta_site_flutter/service/card_data_service.dart';
import 'package:digimon_meta_site_flutter/service/card_service.dart';
import 'package:digimon_meta_site_flutter/widget/card/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/model/card.dart';

@RoutePage()
class LimitInfoPage extends StatefulWidget {
  @override
  State<LimitInfoPage> createState() => _LimitInfoPageState();
}

class _LimitInfoPageState extends State<LimitInfoPage> {
  // 확장된 패널을 추적하기 위한 Set
  final Set<DateTime> _expandedPanels = {};
  
  // 입수처로 카드를 검색하는 함수
  void searchNote(int noteId) {
    SearchParameter searchParameter = SearchParameter();
    searchParameter.noteId = noteId;
    context.navigateTo(DeckBuilderRoute(
        searchParameterString: json.encode(searchParameter.toJson())));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LimitProvider>(
      builder: (context, limitProvider, child) {
        final limits = limitProvider.limits.entries.toList();
        limits.sort((a, b) => b.key.compareTo(a.key)); // 날짜 내림차순 정렬

        if (limits.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        // 현재 적용 중인 금제 찾기
        final currentDate = DateTime.now();
        final currentLimit = limits.firstWhere(
          (entry) => entry.key.isBefore(currentDate) || entry.key.isAtSameMomentAs(currentDate),
          orElse: () => limits.first,
        );

        // 적용 예정 금제와 과거 금제 분리
        final futureLimits = limits.where((entry) => entry.key.isAfter(currentDate)).toList();
        final pastLimits = limits.where((entry) => 
          entry.key.isBefore(currentDate) && entry.key != currentLimit.key).toList();

        // 비교 정보를 사전으로 생성
        final Map<DateTime, LimitComparison> comparisons = {};
        for (var comparison in limitProvider.getLimitComparisons()) {
          comparisons[comparison.currentLimit.restrictionBeginDate] = comparison;
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 현재 적용 중인 금제
                  _buildCurrentLimitSection(
                    context, 
                    currentLimit.key, 
                    currentLimit.value, 
                    comparisons[currentLimit.key]
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 적용 예정 금제 (있는 경우)
                  if (futureLimits.isNotEmpty) ...[
                    const Text(
                      '적용 예정 금제',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...futureLimits.map((entry) => 
                      _buildExpandableLimitSection(
                        context, 
                        entry.key, 
                        entry.value, 
                        comparisons[entry.key]
                      )
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // 과거 금제
                  if (pastLimits.isNotEmpty) ...[
                    const Text(
                      '과거 금제',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...pastLimits.map((entry) => 
                      _buildExpandableLimitSection(
                        context, 
                        entry.key, 
                        entry.value, 
                        comparisons[entry.key]
                      )
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 현재 적용 중인 금제 섹션 (항상 펼쳐진 상태)
  Widget _buildCurrentLimitSection(BuildContext context, DateTime date, LimitDto limit, LimitComparison? comparison) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final formattedDate = dateFormat.format(date);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '현재',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1, height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildLimitContent(context, limit, comparison),
          ),
        ],
      ),
    );
  }

  // 접었다 펼칠 수 있는 금제 섹션
  Widget _buildExpandableLimitSection(BuildContext context, DateTime date, LimitDto limit, LimitComparison? comparison) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final formattedDate = dateFormat.format(date);
    final isExpanded = _expandedPanels.contains(date);
    final currentDate = DateTime.now();
    final isFuture = date.isAfter(currentDate);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              _expandedPanels.add(date);
            } else {
              _expandedPanels.remove(date);
            }
          });
        },
        title: Row(
          children: [
            Expanded(
              child: Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isFuture ? Colors.green : Colors.grey,
                ),
              ),
            ),
            if (isFuture)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '예정',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildLimitContent(context, limit, comparison),
          ),
        ],
      ),
    );
  }

  // 금제 내용 위젯 (펼쳐졌을 때 표시)
  Widget _buildLimitContent(BuildContext context, LimitDto limit, LimitComparison? comparison) {
    // 변경 내역 정보 (새로 추가된/제거된 카드)
    final List<String> newlyBannedCards = comparison?.newlyBannedCards ?? [];
    final List<String> newlyRestrictedCards = comparison?.newlyRestrictedCards ?? [];
    final List<String> removedBanCards = comparison?.removedBanCards ?? [];
    final List<String> removedRestrictCards = comparison?.removedRestrictCards ?? [];
    final List<LimitPair> newLimitPairs = comparison?.newLimitPairs ?? [];
    final List<LimitPair> removedLimitPairs = comparison?.removedLimitPairs ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 금지 카드 섹션
        if (limit.allowedQuantityMap.entries.where((e) => e.value == 0).isNotEmpty) ...[
          const Text(
            '금지',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: _getSortedCardChips(
                limit.allowedQuantityMap.entries
                  .where((e) => e.value == 0)
                  .map((e) => e.key)
                  .toList(),
                Colors.red,
                newlyAddedCards: newlyBannedCards,
              ),
            ),
          ),
          
          // 금지 해제된 카드 섹션 (있는 경우)
          if (removedBanCards.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '금지 해제된 카드',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 8,
                    children: _getSortedCardChips(
                      removedBanCards,
                      Colors.green,
                      isRemovedCard: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
        ],
        
        // 제한 카드 섹션
        if (limit.allowedQuantityMap.entries.where((e) => e.value == 1).isNotEmpty) ...[
          const Text(
            '제한',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: _getSortedCardChips(
                limit.allowedQuantityMap.entries
                  .where((e) => e.value == 1)
                  .map((e) => e.key)
                  .toList(),
                Colors.orange,
                newlyAddedCards: newlyRestrictedCards,
              ),
            ),
          ),
          
          // 제한 해제된 카드 섹션 (있는 경우)
          if (removedRestrictCards.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '제한 해제된 카드',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8,
                    runSpacing: 8,
                    children: _getSortedCardChips(
                      removedRestrictCards,
                      Colors.blue,
                      isRemovedCard: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 16),
        ],
        
        // 조합 제한 섹션
        if (limit.limitPairs.isNotEmpty) ...[
          const Text(
            '조합 제한',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          ...limit.limitPairs.map((pair) {
            // 새로 추가된 페어인지 확인
            bool isNewPair = newLimitPairs.any((newPair) => 
              _arePairsEqual(pair, newPair));
            return _buildLimitPairSection(context, pair, isNewPair: isNewPair);
          }),
          
          // 제거된 페어 섹션 (있는 경우)
          if (removedLimitPairs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.teal, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '제거된 조합 제한',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...removedLimitPairs.map((pair) =>
                    _buildLimitPairSection(context, pair, isRemovedPair: true)
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildLimitPairSection(
    BuildContext context, 
    LimitPair pair, {
    bool isNewPair = false,
    bool isRemovedPair = false,
  }) {
    // 페어 컨테이너를 위한 스타일 설정
    BoxDecoration decoration = BoxDecoration(
      color: isRemovedPair ? Colors.grey.shade50 : null,
      borderRadius: BorderRadius.circular(8),
      border: isNewPair 
        ? Border.all(color: Colors.yellow, width: 2)
        : (isRemovedPair 
            ? Border.all(color: Colors.grey.shade300, width: 1)
            : null),
    );
    
    Color textColor = isRemovedPair ? Colors.grey : Colors.black;
    Color titleColor = isRemovedPair ? Colors.grey : Colors.purple.shade800;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(isNewPair || isRemovedPair ? 8 : 0),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '다음 중 하나만 선택 가능:',
                style: TextStyle(
                  color: textColor,
                  fontWeight: isNewPair ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isNewPair)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NEW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              if (isRemovedPair)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '해제',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // 그룹 A
          Text(
            '그룹 A:', 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: _getSortedCardChips(
                pair.acardPairNos, 
                isRemovedPair ? Colors.grey.shade400 : Colors.purple.shade300,
                isRemovedCard: isRemovedPair,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 그룹 B
          Text(
            '그룹 B:', 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 8,
              runSpacing: 8,
              children: _getSortedCardChips(
                pair.bcardPairNos, 
                isRemovedPair ? Colors.grey.shade400 : Colors.purple.shade300,
                isRemovedCard: isRemovedPair,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 헬퍼 메서드: 두 LimitPair가 동일한지 비교
  bool _arePairsEqual(LimitPair pair1, LimitPair pair2) {
    // 두 리스트의 길이가 다르면 다른 페어
    if (pair1.acardPairNos.length != pair2.acardPairNos.length ||
        pair1.bcardPairNos.length != pair2.bcardPairNos.length) {
      return false;
    }
    
    // A 카드 목록과 B 카드 목록이 모두 같은 카드를 포함하는지 확인
    bool sameA = _areCardListsEqual(pair1.acardPairNos, pair2.acardPairNos);
    bool sameB = _areCardListsEqual(pair1.bcardPairNos, pair2.bcardPairNos);
    
    return sameA && sameB;
  }
  
  // 헬퍼 메서드: 두 카드 리스트가 동일한 카드를 포함하는지 비교
  bool _areCardListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    
    // 정렬된 복사본을 생성하여 비교
    final sortedList1 = List<String>.from(list1)..sort();
    final sortedList2 = List<String>.from(list2)..sort();
    
    for (int i = 0; i < sortedList1.length; i++) {
      if (sortedList1[i] != sortedList2[i]) {
        return false;
      }
    }
    
    return true;
  }

  // 카드 정렬 및 표시를 위한 메소드
  List<Widget> _getSortedCardChips(
    List<String> cardNos, 
    Color color, {
    List<String> newlyAddedCards = const [],
    bool isRemovedCard = false,
  }) {
    // 카드 정보와 번호를 함께 담는 리스트 생성
    List<MapEntry<String, DigimonCard?>> cardEntries = [];
    
    for (var cardNo in cardNos) {
      var card = CardDataService().getNonParallelCardByCardNo(cardNo);
      cardEntries.add(MapEntry(cardNo, card));
    }
    
    // 정렬 순서: 1) 새로 추가된 카드 먼저, 2) sortString 기준
    cardEntries.sort((a, b) {
      // 카드 정보가 없는 경우 맨 뒤로
      if (a.value == null && b.value == null) return 0;
      if (a.value == null) return 1;
      if (b.value == null) return -1;
      
      // 1) 새로 추가된 카드 우선 정렬
      bool isANewlyAdded = newlyAddedCards.contains(a.key);
      bool isBNewlyAdded = newlyAddedCards.contains(b.key);
      
      if (isANewlyAdded && !isBNewlyAdded) return -1; // A가 새로 추가된 카드면 앞으로
      if (!isANewlyAdded && isBNewlyAdded) return 1;  // B가 새로 추가된 카드면 앞으로
      
      // 2) sortString 기준 정렬
      String sortStringA = a.value!.sortString ?? '';
      String sortStringB = b.value!.sortString ?? '';
      
      return sortStringA.compareTo(sortStringB); // sortString 기준 오름차순 정렬
    });
    
    // 정렬된 순서로 카드 위젯 생성
    return cardEntries.map((entry) {
      bool isNewlyAdded = newlyAddedCards.contains(entry.key);
      return _buildCardChip(
        context, 
        entry.key, 
        color,
        isNewlyAdded: isNewlyAdded,
        isRemovedCard: isRemovedCard,
      );
    }).toList();
  }

  Widget _buildCardChip(
    BuildContext context, 
    String cardNo, 
    Color color, {
    bool isNewlyAdded = false,
    bool isRemovedCard = false,
  }) {
    // 비패럴렐 카드를 우선적으로 가져옴
    var card = CardDataService().getNonParallelCardByCardNo(cardNo);
    
    // 새로 추가된 카드인 경우 테두리 스타일 설정
    BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isNewlyAdded 
          ? Colors.yellow 
          : (isRemovedCard ? Colors.grey.shade400 : color),
        width: isNewlyAdded ? 3 : 2,
      ),
      boxShadow: isNewlyAdded ? [
        BoxShadow(
          color: Colors.yellow.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 3,
          offset: Offset(0, 0),
        )
      ] : null,
    );
    
    // 새로 추가된 카드는 표시를 위한 추가 위젯
    Widget? badge;
    if (isNewlyAdded) {
      badge = Positioned(
        top: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.yellow,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          child: Text(
            'NEW',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    } else if (isRemovedCard) {
      // 제한 해제된 카드 표시
      badge = Positioned(
        top: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          child: Text(
            '해제',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    
    if (card == null) {
      // 카드가 없는 경우 대체 UI 표시
      return Container(
        margin: const EdgeInsets.only(right: 4, bottom: 4),
        decoration: decoration,
        width: 70,
        height: 98, // 카드 비율 (1:1.4)
        child: Stack(
          children: [
            Center(
              child: Text(
                cardNo,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isRemovedCard ? Colors.grey : color,
                ),
              ),
            ),
            if (badge != null) badge,
          ],
        ),
      );
    }
    
    // CustomCard 위젯을 사용하여 카드 표시
    return Container(
      decoration: decoration,
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      child: Stack(
        children: [
          CustomCard(
            width: 70, // 이미지 크기와 비슷하게 조정
            card: card,
            cardPressEvent: (selectedCard) {
              // 카드 클릭 시 동작
              CardService().showImageDialog(context, selectedCard, searchNote);
            },
            onLongPress: () {
              // 길게 누르면 카드 상세 정보 표시
              CardService().showImageDialog(context, card, searchNote);
            },
            // 항상 컬러로 표시 (흑백 처리 제거)
            isActive: true,
            // 줌 아이콘 비활성화하여 UI 깔끔하게 유지
            zoomActive: false,
            // 금지/제한/페어제한 배지 숨기기
            hideLimitBadges: true,
          ),
          if (badge != null) badge,
        ],
      ),
    );
  }
} 