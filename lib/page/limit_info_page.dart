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
import 'dart:async';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:digimon_meta_site_flutter/widget/common/toast_overlay.dart';

@RoutePage()
class LimitInfoPage extends StatefulWidget {
  @override
  State<LimitInfoPage> createState() => _LimitInfoPageState();
}

class _LimitInfoPageState extends State<LimitInfoPage> {
  // 확장된 패널을 추적하기 위한 Set
  final Set<DateTime> _expandedPanels = {};
  // 현재 다운로드 중인 금제 날짜를 저장
  DateTime? _capturingDate;
  // 이미지 생성 오버레이 컨트롤러
  OverlayEntry? _overlayEntry;
  // 이미지 생성 완료 콜백
  VoidCallback? _onImageReady;
  
  // 입수처로 카드를 검색하는 함수
  void searchWithParameter(SearchParameter parameter) {
    context.navigateTo(DeckBuilderRoute(
        searchParameterString: json.encode(parameter.toJson())));
  }

  // 특정 금제 정보를 이미지로 캡처하는 함수
  Future<void> _captureAndDownloadImage(DateTime limitDate, LimitDto limitDto, LimitComparison? comparison) async {
    setState(() {
      _capturingDate = limitDate;
    });

    try {
      // 다운로드 시작 알림
      ToastOverlay.show(context, '이미지를 저장하는 중입니다...', type: ToastType.info);
      
      // 고정 사이즈 이미지를 위한 오버레이 생성
      final completer = Completer<ui.Image>();
      final key = GlobalKey();
      
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -10000, // 화면 밖으로 배치
          child: Material(
            child: RepaintBoundary(
              key: key,
              child: Container(
                width: 600, // 고정 너비
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 금제 정보 헤더
                    _buildImageHeader(limitDate),
                    
                    // 금제 내용
                    _buildImageContent(context, limitDto, comparison),
                    
                    // 푸터
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Image created using DGCHub (dgchub.com)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      
      // 오버레이 추가
      Overlay.of(context).insert(_overlayEntry!);
      
      // 이미지 렌더링 완료 대기 (약간의 지연 추가)
      await Future.delayed(Duration(milliseconds: 500));
      
      // 이미지 캡처
      RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // 고해상도 이미지를 위한 픽셀 비율 설정
      final image = await boundary.toImage(pixelRatio: 2.0);
      
      // 오버레이 제거
      _overlayEntry?.remove();
      _overlayEntry = null;
      
      // 이미지를 파일로 변환
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        // 금제 날짜를 파일명으로 사용
        final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
        final fileName = '디지몬_금제_${dateFormat.format(limitDate)}.png';
        
        // 웹에서 이미지 다운로드
        await WebImageDownloader.downloadImageFromUInt8List(
          uInt8List: byteData.buffer.asUint8List(),
          name: fileName,
          imageType: ImageType.png
        );
        
        // 성공 알림
        ToastOverlay.show(context, '이미지가 성공적으로 저장되었습니다', type: ToastType.success);
      }
    } catch (e) {
      ToastOverlay.show(context, '이미지 저장 중 오류가 발생했습니다: $e', type: ToastType.error);
      
      // 오류 발생 시 오버레이 제거
      _overlayEntry?.remove();
      _overlayEntry = null;
    } finally {
      setState(() {
        _capturingDate = null;
      });
    }
  }
  
  // 이미지 용 헤더 위젯
  Widget _buildImageHeader(DateTime date) {
    final dateFormat = DateFormat('yyyy년 MM월 dd일');
    final formattedDate = dateFormat.format(date);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 사이트 제목
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              '디지몬 카드 게임 금제 정보',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'JalnanGothic',
              ),
            ),
          ),
        ),
        Divider(thickness: 2),
        SizedBox(height: 8),
        
        // 날짜 (상태 표시 제거)
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Divider(),
      ],
    );
  }
  
  // 이미지 용 컨텐츠 위젯
  Widget _buildImageContent(BuildContext context, LimitDto limit, LimitComparison? comparison) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 기존 금제 내용 위젯 재사용
        _buildLimitContent(context, limit, comparison),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LimitProvider>(
      builder: (context, limitProvider, child) {
        final limits = limitProvider.limits.entries.toList();
        limits.sort((a, b) => b.key.compareTo(a.key)); // 날짜 내림차순 정렬

        if (limits.isEmpty) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
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
    final isCapturing = _capturingDate == date;
    
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
                const SizedBox(width: 8),
                // 다운로드 버튼 추가
                IconButton(
                  icon: isCapturing 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      )
                    : Icon(Icons.download, color: Colors.blue),
                  tooltip: '이미지로 저장',
                  onPressed: isCapturing 
                    ? null 
                    : () => _captureAndDownloadImage(date, limit, comparison),
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
    final isCapturing = _capturingDate == date;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ExpansionTile(
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
                // 다운로드 버튼 추가
                IconButton(
                  icon: isCapturing 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isFuture ? Colors.green : Colors.grey,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.download, 
                        color: isFuture ? Colors.green : Colors.grey
                      ),
                  tooltip: '이미지로 저장',
                  onPressed: isCapturing 
                    ? null 
                    : () => _captureAndDownloadImage(date, limit, comparison),
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
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.block, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        '금지',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: Colors.red.shade100),
                Padding(
                  padding: const EdgeInsets.all(12.0),
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
                  Divider(height: 1, thickness: 1, color: Colors.red.shade100),
                  Container(
                    padding: const EdgeInsets.all(12),
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
              ],
            ),
          ),
        ],
        
        // 제한 카드 섹션
        if (limit.allowedQuantityMap.entries.where((e) => e.value == 1).isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        '제한',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: Colors.orange.shade100),
                Padding(
                  padding: const EdgeInsets.all(12.0),
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
                  Divider(height: 1, thickness: 1, color: Colors.orange.shade100),
                  Container(
                    padding: const EdgeInsets.all(12),
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
              ],
            ),
          ),
        ],
        
        // 조합 제한 섹션
        if (limit.limitPairs.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.compare_arrows, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        '조합 제한',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, thickness: 1, color: Colors.purple.shade100),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...limit.limitPairs.map((pair) {
                        // 새로 추가된 페어인지 확인
                        bool isNewPair = newLimitPairs.any((newPair) => 
                          _arePairsEqual(pair, newPair));
                        return _buildLimitPairSection(context, pair, isNewPair: isNewPair);
                      }),
                    ],
                  ),
                ),
                
                // 제거된 페어 섹션 (있는 경우)
                if (removedLimitPairs.isNotEmpty) ...[
                  Divider(height: 1, thickness: 1, color: Colors.purple.shade100),
                  Container(
                    padding: const EdgeInsets.all(12),
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
            ),
          ),
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
    Color bgColor = isRemovedPair ? Colors.grey.shade50 : Colors.white;
    Color borderColor = isNewPair 
      ? Colors.yellow 
      : (isRemovedPair ? Colors.grey.shade300 : Colors.purple.shade200);
    
    BoxDecoration decoration = BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: borderColor, width: isNewPair ? 2 : 1),
      boxShadow: isNewPair ? [
        BoxShadow(
          color: Colors.yellow.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 2,
          offset: Offset(0, 1),
        )
      ] : null,
    );
    
    Color textColor = isRemovedPair ? Colors.grey : Colors.black;
    Color titleColor = isRemovedPair ? Colors.grey : Colors.purple.shade800;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 영역
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isRemovedPair 
                ? Colors.grey.shade100
                : Colors.purple.shade100.withOpacity(0.5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(7),
                topRight: Radius.circular(7),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.swap_horiz, 
                  color: isRemovedPair ? Colors.grey : Colors.purple.shade700,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '그룹 하나만 선택 가능',
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
          ),
          
          // 카드 그룹들
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 그룹 A
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isRemovedPair 
                      ? Colors.grey.shade50 
                      : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isRemovedPair 
                        ? Colors.grey.shade200 
                        : Colors.purple.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '그룹 A', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 8,
                        children: _getSortedCardChips(
                          pair.acardPairNos, 
                          isRemovedPair ? Colors.grey.shade400 : Colors.purple.shade300,
                          isRemovedCard: isRemovedPair,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 중앙에 OR 표시
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isRemovedPair 
                            ? Colors.grey.shade300 
                            : Colors.purple.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 그룹 B
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isRemovedPair 
                      ? Colors.grey.shade50 
                      : Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isRemovedPair 
                        ? Colors.grey.shade200 
                        : Colors.purple.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '그룹 B', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 8,
                        children: _getSortedCardChips(
                          pair.bcardPairNos, 
                          isRemovedPair ? Colors.grey.shade400 : Colors.purple.shade300,
                          isRemovedCard: isRemovedPair,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
    
    // 이미지 저장을 위한 고정 크기 설정
    final double cardWidth = 65; // 약간 작게 조정
    final double cardHeight = 91; // 카드 비율 유지 (1:1.4)
    
    if (card == null) {
      // 카드가 없는 경우 대체 UI 표시
      return Container(
        margin: const EdgeInsets.only(right: 4, bottom: 4),
        decoration: decoration,
        width: cardWidth,
        height: cardHeight,
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
            width: cardWidth, // 고정된 크기 사용
            card: card,
            cardPressEvent: (selectedCard) {
              // 카드 클릭 시 동작
              CardService().showImageDialog(context, selectedCard, searchWithParameter: searchWithParameter);
            },
            onLongPress: () {
              // 길게 누르면 카드 상세 정보 표시
              CardService().showImageDialog(context, card, searchWithParameter: searchWithParameter);
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