import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/model/limit_dto.dart';
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

        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '금지/제한',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 현재 적용 중인 금제
                  _buildCurrentLimitSection(context, currentLimit.key, currentLimit.value),
                  
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
                      _buildExpandableLimitSection(context, entry.key, entry.value)
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
                      _buildExpandableLimitSection(context, entry.key, entry.value)
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
  Widget _buildCurrentLimitSection(BuildContext context, DateTime date, LimitDto limit) {
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
            child: _buildLimitContent(context, limit),
          ),
        ],
      ),
    );
  }

  // 접었다 펼칠 수 있는 금제 섹션
  Widget _buildExpandableLimitSection(BuildContext context, DateTime date, LimitDto limit) {
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
            child: _buildLimitContent(context, limit),
          ),
        ],
      ),
    );
  }

  // 금제 내용 위젯 (펼쳐졌을 때 표시)
  Widget _buildLimitContent(BuildContext context, LimitDto limit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              children: limit.allowedQuantityMap.entries
                  .where((e) => e.value == 0)
                  .map((e) => _buildCardChip(context, e.key, Colors.red))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
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
              children: limit.allowedQuantityMap.entries
                  .where((e) => e.value == 1)
                  .map((e) => _buildCardChip(context, e.key, Colors.orange))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
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
          ...limit.limitPairs.map((pair) => _buildLimitPairSection(context, pair)),
        ],
      ],
    );
  }

  Widget _buildLimitPairSection(BuildContext context, LimitPair pair) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('다음 중 하나만 선택 가능:'),
        const SizedBox(height: 8),
        // 그룹 A
        const Text('그룹 A:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: pair.acardPairNos
                .map((cardNo) => _buildCardChip(context, cardNo, Colors.purple.shade300))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        // 그룹 B
        const Text('그룹 B:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: 8,
            runSpacing: 8,
            children: pair.bcardPairNos
                .map((cardNo) => _buildCardChip(context, cardNo, Colors.purple.shade300))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCardChip(BuildContext context, String cardNo, Color color) {
    // 비패럴렐 카드를 우선적으로 가져옴
    var card = CardDataService().getNonParallelCardByCardNo(cardNo);
    
    if (card == null) {
      // 카드가 없는 경우 대체 UI 표시
      return Container(
        margin: const EdgeInsets.only(right: 4, bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
        ),
        width: 70,
        height: 98, // 카드 비율 (1:1.4)
        child: Center(
          child: Text(
            cardNo,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      );
    }
    
    // CustomCard 위젯을 사용하여 카드 표시
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 2),
      ),
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      child: CustomCard(
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
        // 금제 카드임을 표시하는 시각적 힌트를 위해 isActive를 사용
        isActive: true,
        // 줌 아이콘 비활성화하여 UI 깔끔하게 유지
        zoomActive: false,
      ),
    );
  }
} 