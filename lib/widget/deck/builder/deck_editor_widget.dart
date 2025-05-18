import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/deck-build.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/service/card_data_service.dart';
import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:digimon_meta_site_flutter/widget/common/toast_overlay.dart';
import 'dart:math' as math;
import 'package:digimon_meta_site_flutter/service/card_service.dart';
import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'dart:convert';

// 커스텀 Intent 클래스들 정의
class MoveUpIntent extends Intent {}
class MoveDownIntent extends Intent {}
class ConfirmSelectionIntent extends Intent {}

  // 카드 참조 패턴 정의
class CardReference {
  // 참조 형식: [@cardNo CardName]
  static final RegExp referencePattern = RegExp(r'\[@([A-Za-z0-9]+-\d+(?:-\d+)?)\s+([^\]]+)\]');
  
  // 참조 문자열 생성
  static String create(DigimonCard card) {
    String displayName = card.getDisplayName() ?? '';
    return '[@${card.cardNo} $displayName]';
  }
  
  // 문자열에서 모든 참조 찾기
  static List<RegExpMatch> findAll(String text) {
    return referencePattern.allMatches(text).toList();
  }
  
  // 카드 번호 추출
  static String? extractCardNo(String reference) {
    final match = referencePattern.firstMatch(reference);
    return match?.group(1);
  }
}

class DeckEditorWidget extends StatefulWidget {
  final DeckBuild deck;
  final Function() onEditorChanged;
  final Function(int)? searchNote;
  final bool isExpanded;
  final Function(bool) toggleExpanded;

  const DeckEditorWidget({
    Key? key,
    required this.deck,
    required this.onEditorChanged,
    this.searchNote,
    this.isExpanded = false,
    required this.toggleExpanded,
  }) : super(key: key);

  @override
  State<DeckEditorWidget> createState() => _DeckEditorWidgetState();
}

class _DeckEditorWidgetState extends State<DeckEditorWidget> {
  final TextEditingController _editorController = TextEditingController();
  final FocusNode _editorFocusNode = FocusNode();
  bool _isEditorExpanded = false;
  
  // 슬래시 패턴 (슬래시로 시작하는 명령어)
  final RegExp _slashCommandRegex = RegExp(r'(/[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ_]*)$');
  
  bool _showSuggestions = false;
  List<DigimonCard> _suggestions = [];
  String _currentCommand = '';
  int _commandStartIndex = 0;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  int _selectedSuggestionIndex = 0;
  
  // 키보드 네비게이션 중인지 추적하는 변수
  bool _isNavigatingWithKeyboard = false;

  // 현재 참조된 카드들 관리
  List<DigimonCard> _referencedCards = [];
  
  @override
  void initState() {
    super.initState();
    _editorController.text = widget.deck.description ?? '';
    
    // 텍스트 변경 리스너
    _editorController.addListener(_onTextChanged);
    
    // 포커스 변경 리스너
    _editorFocusNode.addListener(() {
      if (!_editorFocusNode.hasFocus) {
        _removeSuggestions();
        _updateReferencedCards();
      }
    });
    
    // 초기 참조 카드 로드
    _updateReferencedCards();
  }
  
  @override
  void didUpdateWidget(DeckEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 덱이 변경되었고, 현재 에디터 내용과 다른 경우 에디터 텍스트 업데이트
    if (widget.deck != oldWidget.deck || 
        widget.deck.description != _editorController.text) {
      // 현재 커서 위치와 선택 저장
      final currentSelection = _editorController.selection;
      
      // 텍스트 업데이트
      _editorController.text = widget.deck.description ?? '';
      
      // 가능하면 커서 위치 복원 (텍스트가 완전히 다른 경우 마지막으로 이동)
      if (currentSelection.start <= _editorController.text.length) {
        _editorController.selection = currentSelection;
      } else {
        _editorController.selection = TextSelection.collapsed(offset: _editorController.text.length);
      }
      
      _updateReferencedCards();
    }
  }
  
  @override
  void dispose() {
    _removeSuggestions();
    _editorController.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }
  
  // 텍스트에서 참조된 카드 목록 업데이트
  void _updateReferencedCards() {
    final text = _editorController.text;
    final references = CardReference.findAll(text);
    final List<DigimonCard> cards = [];
    
    for (final match in references) {
      final cardNo = match.group(1);
      if (cardNo != null) {
        final card = CardDataService().getCardByCardNo(cardNo);
        if (card != null) {
          if (!cards.any((c) => c.cardNo == card.cardNo)) {
            cards.add(card);
          }
        }
      }
    }
    
    setState(() {
      _referencedCards = cards;
    });
  }
  
  void _onTextChanged() {
    // 자동완성이 표시 중이고 키보드 네비게이션 중이면 텍스트 변경 처리 무시
    if (_showSuggestions && _isNavigatingWithKeyboard) {
      return;
    }
  
    final text = _editorController.text;
    final selection = _editorController.selection;
    
    // 현재 커서 위치까지의 텍스트 확인
    if (selection.baseOffset > 0) {
      final textBeforeCursor = text.substring(0, selection.baseOffset);
      
      // 슬래시 명령어 확인 (예: /)
      if (_slashCommandRegex.hasMatch(textBeforeCursor)) {
        final match = _slashCommandRegex.firstMatch(textBeforeCursor)!;
        _commandStartIndex = match.start;
        _currentCommand = match.group(0)!;
        
        print('명령어 감지: $_currentCommand');
        
        // "/"만 입력했거나 접두어로 시작하는 경우
        if (_currentCommand.length > 1) {
          _searchCards(_currentCommand.substring(1)); // 슬래시 제거
        } else {
          _showRecentCards();
        }
        return;
      }
    }
    
    _removeSuggestions();
    
    // 일반 텍스트 변경
    widget.deck.description = text;
    widget.onEditorChanged();
    
    // 참조된 카드 목록 업데이트
    _updateReferencedCards();
  }
  
  void _showRecentCards() {
    // 최근 카드 표시 (5개로 제한)
    // 패럴렐 카드 제외
    _suggestions = CardDataService().getRecentCards(10)
        .where((card) => card.isParallel == false)
        .take(5)
        .toList();
    
    _selectedSuggestionIndex = 0;
    _showAutocomplete();
  }
  
  void _searchCards(String query) {
    final searchService = CardDataService();
    List<DigimonCard> results = [];
    
    // 검색어가 비어있으면 최근 카드 표시
    if (query.isEmpty) {
      _showRecentCards();
      return;
    }
    
    // 카드 번호로 먼저 검색 (cardNo 기준)
    if (query.isNotEmpty) {
      results = searchService.searchCardsByNumber(query)
          .where((card) => card.isParallel == false) // 패럴렐 카드 제외
          .take(5)
          .toList();
      
      if (results.isNotEmpty) {
        _suggestions = results;
        _selectedSuggestionIndex = 0;
        _showAutocomplete();
        return;
      }
    }
    
    // 이름으로 카드 검색 (패럴렐 카드 제외)
    _suggestions = searchService.searchCardsByText(query)
        .where((card) => 
            card.getDisplayName() != null && 
            card.getDisplayName()!.toLowerCase().contains(query.toLowerCase()) &&
            card.isParallel == false) // 패럴렐 카드 제외
        .take(5)
        .toList();
    
    // 항상 첫 번째 항목이 선택되도록 설정
    _selectedSuggestionIndex = 0;
    
    if (_suggestions.isNotEmpty) {
      _showAutocomplete();
    } else {
      _removeSuggestions();
    }
  }
  
  void _showAutocomplete() {
    if (_suggestions.isEmpty) {
      _removeSuggestions();
      return;
    }
    
    // 기존 오버레이 먼저 제거
    _overlayEntry?.remove();
    _overlayEntry = null;
    
    // 상태 업데이트
    setState(() {
      _showSuggestions = true;
      // 명시적으로 첫 번째 항목이 선택되도록 보장
      _selectedSuggestionIndex = 0;
    });
    
    // 오버레이 생성 및 표시
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }
  
  void _removeSuggestions() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    
    setState(() {
      _showSuggestions = false;
    });
  }
  
  void _selectSuggestion(DigimonCard card) {
    final text = _editorController.text;
    
    // 카드 참조 형식으로 생성 (간단한 [cardNo] 형식)
    final cardRef = CardReference.create(card);
    
          // 명령어를 카드 참조로 교체
      final newText = text.replaceRange(_commandStartIndex, _commandStartIndex + _currentCommand.length, cardRef);
      
      // 에디터 텍스트 업데이트
      _editorController.value = TextEditingController.fromValue(
        TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: _commandStartIndex + cardRef.length),
        ),
      ).value;
      
      // 덱 설명 업데이트
      widget.deck.description = newText;
      widget.onEditorChanged();
      
      // 참조 카드 목록 업데이트
      _updateReferencedCards();
      
      // 토스트 메시지 표시
      ToastOverlay.show(
        context, 
        '카드 참조가 추가되었습니다: ${card.getDisplayName()}',
        type: ToastType.success,
      );
      
      _removeSuggestions();
    }
    
    void _moveSelectionUp() {
      if (_suggestions.isNotEmpty) {
        // 키보드 네비게이션 중임을 표시
        _isNavigatingWithKeyboard = true;
        
        int newIndex;
        
        if (_selectedSuggestionIndex <= 0) {
          // 첫 항목에서는 마지막 항목으로 이동
          newIndex = _suggestions.length - 1;
        } else {
          newIndex = _selectedSuggestionIndex - 1;
        }
        
        setState(() {
          _selectedSuggestionIndex = newIndex;
        });
        
        _updateOverlay();
        
        // 짧은 딜레이 후 네비게이션 상태 해제
        Future.delayed(Duration(milliseconds: 100), () {
          _isNavigatingWithKeyboard = false;
        });
      }
    }
    
    void _moveSelectionDown() {
      if (_suggestions.isNotEmpty) {
        // 키보드 네비게이션 중임을 표시
        _isNavigatingWithKeyboard = true;
        
        int newIndex;
        
        if (_selectedSuggestionIndex >= _suggestions.length - 1) {
          // 마지막 항목에서는 첫 항목으로 이동
          newIndex = 0;
        } else {
          newIndex = _selectedSuggestionIndex + 1;
        }
        
        setState(() {
          _selectedSuggestionIndex = newIndex;
        });
        
        _updateOverlay();
        
        // 짧은 딜레이 후 네비게이션 상태 해제
        Future.delayed(Duration(milliseconds: 100), () {
          _isNavigatingWithKeyboard = false;
        });
      }
    }
  
  void _confirmSelection() {
    if (_suggestions.isNotEmpty) {
      // 키보드 네비게이션 중임을 표시
      _isNavigatingWithKeyboard = true;
      
      if (_showSuggestions && _suggestions.isNotEmpty && 
          _selectedSuggestionIndex >= 0 && _selectedSuggestionIndex < _suggestions.length) {
        _selectSuggestion(_suggestions[_selectedSuggestionIndex]);
      }
      
      // 짧은 딜레이 후 네비게이션 상태 해제
      Future.delayed(Duration(milliseconds: 100), () {
        _isNavigatingWithKeyboard = false;
      });
    }
  }
  
  void _updateOverlay() {
    if (_overlayEntry != null) {
      // 범위를 벗어난 경우 수정
      if (_selectedSuggestionIndex < 0 || _selectedSuggestionIndex >= _suggestions.length) {
        _selectedSuggestionIndex = 0;
      }
      
      // 오버레이 강제 업데이트 - 이 방식이 더 안정적
      _overlayEntry!.markNeedsBuild();
    }
  }
  
  bool _handleKey(FocusNode node, RawKeyEvent event) {
    if (!_showSuggestions) return false;
    
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _moveSelectionUp();
        return true;
      } 
      
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _moveSelectionDown();
        return true;
      }
      
      if (event.logicalKey == LogicalKeyboardKey.enter || 
          event.logicalKey == LogicalKeyboardKey.tab) {
        _confirmSelection();
        return true;
      }
    }
    
    return false;
  }
  
  OverlayEntry _createOverlayEntry() {
    // TextField의 RenderBox 가져오기
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    // 정확한 높이 계산 (더 신뢰성 있게)
    final double headerHeight = 34.0;  // 헤더 높이
    final double itemHeight = 48.0;    // 각 항목 높이
    final double listPadding = 4.0;    // 리스트 패딩
    
    // 정확히 5개 항목에 맞는 전체 높이 계산
    final double exactHeight = headerHeight + (itemHeight * math.min(5, _suggestions.length)) + listPadding;
    
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, 80), // 텍스트 필드 아래에 위치
          child: Material(
            elevation: 4.0,
            borderRadius: BorderRadius.circular(SizeService.roundRadius(context) / 2),
            child: Container(
              // 정확한 높이 지정
              height: exactHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(SizeService.roundRadius(context) / 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 상단에 안내 텍스트 추가
                  Container(
                    height: headerHeight,
                    padding: EdgeInsets.symmetric(
                      vertical: 6, 
                      horizontal: SizeService.paddingSize(context) / 2
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Text(
                      '방향키(↑↓)로 선택 후 엔터키로 확정',
                      style: TextStyle(
                        fontSize: SizeService.bodyFontSize(context) * 0.8,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // 카드 목록
                  Expanded(
                    child: _suggestions.isEmpty 
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              '검색 결과가 없습니다',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: SizeService.bodyFontSize(context),
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: NeverScrollableScrollPhysics(), // 스크롤 비활성화 (고정 5개)
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final card = _suggestions[index];
                          final isSelected = index == _selectedSuggestionIndex;
                          
                          return Container(
                            height: itemHeight, // 정확한 높이 지정
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                              border: isSelected 
                                  ? Border(left: BorderSide(color: Theme.of(context).primaryColor, width: 3.0)) 
                                  : null,
                            ),
                            child: ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact, // 좀 더 조밀하게
                              title: Text(
                                "${card.cardNo} - ${card.getDisplayName()}",
                                style: TextStyle(
                                  fontSize: SizeService.bodyFontSize(context),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 1, // 한 줄로 제한
                                overflow: TextOverflow.ellipsis, // 길면 말줄임표 표시
                              ),
                              onTap: () => _selectSuggestion(card),
                              // 기존 tileColor 대신 Container의 decoration으로 처리
                              tileColor: null,
                            ),
                          );
                        },
                      ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 텍스트 필드 위젯
    Widget textField = Focus(
      onKeyEvent: (FocusNode node, KeyEvent event) {
        // 자동완성이 활성화된 경우에만 특정 키 이벤트를 가로챔
        if (_showSuggestions && event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            _moveSelectionUp();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            _moveSelectionDown();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.tab) {
            _confirmSelection();
            return KeyEventResult.handled;
          }
        }
        else if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
          return KeyEventResult.handled;
        }
        // 다른 모든 키 이벤트는 전달됨
        return KeyEventResult.ignored;
      },
      child: TextField(
        controller: _editorController,
        focusNode: _editorFocusNode,
        maxLines: 10,
        minLines: 5,
        decoration: InputDecoration(
          hintText: '덱 설명을 입력하세요',
          contentPadding: EdgeInsets.all(SizeService.paddingSize(context)),
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        enableInteractiveSelection: true,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(SizeService.roundRadius(context)),
      ),
      margin: EdgeInsets.only(bottom: SizeService.paddingSize(context)),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // 상위 위젯에 있는 토글 함수 호출
              widget.toggleExpanded(!widget.isExpanded);
            },
            child: Padding(
              padding: EdgeInsets.all(SizeService.paddingSize(context) / 2),
              child: Row(
                children: [
                  Icon(
                    widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: SizeService.bodyFontSize(context) * 1.5,
                  ),
                  SizedBox(width: SizeService.paddingSize(context) / 2),
                  Text(
                    '덱 설명',
                    style: TextStyle(
                      fontSize: SizeService.bodyFontSize(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isExpanded)
            Padding(
              padding: EdgeInsets.all(SizeService.paddingSize(context)),
              child: Column(
                children: [
                  CompositedTransformTarget(
                    link: _layerLink,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(SizeService.roundRadius(context) / 2),
                      ),
                      child: textField,
                    ),
                  ),
                  SizedBox(height: SizeService.paddingSize(context)),
                  Text(
                    '/ 명령어를 입력하면 카드 참조를 추가할 수 있습니다.',
                    style: TextStyle(
                      fontSize: SizeService.bodyFontSize(context) * 0.8,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  
                  // 참조된 카드 표시 영역
                  if (_referencedCards.isNotEmpty) 
                    _buildReferencedCardsSection(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // 카드 정보 표시 메서드
  void _showCardInfo(BuildContext context, String cardNo) {
    final card = CardDataService().getCardByCardNo(cardNo);
    if (card != null) {
      // CardService를 사용하여 카드 이미지 다이얼로그 표시
      CardService().showImageDialog(context, card, widget.searchNote);
    }
  }

  // 참조된 카드 UI 부분 수정
  Widget _buildReferencedCardsSection() {
    if (_referencedCards.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: SizeService.paddingSize(context)),
        Divider(height: 1, color: Colors.grey.shade300),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '참조된 카드',
              style: TextStyle(
                fontSize: SizeService.bodyFontSize(context) * 0.9,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 8.0, // 가로 간격
            runSpacing: 8.0, // 세로 간격
            children: _referencedCards.map((card) {
              return CardReferenceChip(
                card: card,
                onTap: () => _showCardInfo(context, card.cardNo!),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// 참조된 카드를 나타내는 칩 위젯
class CardReferenceChip extends StatelessWidget {
  final DigimonCard card;
  final VoidCallback onTap;

  const CardReferenceChip({
    Key? key,
    required this.card,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getColorForCardType(card),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${card.cardNo}',
              style: TextStyle(
                fontSize: SizeService.bodyFontSize(context) * 0.8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (card.getDisplayName() != null) ...[
              SizedBox(width: 4),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 120),
                child: Text(
                  card.getDisplayName()!,
                  style: TextStyle(
                    fontSize: SizeService.bodyFontSize(context) * 0.8,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  // 카드 타입에 따른 배경색 반환
  Color _getColorForCardType(DigimonCard card) {
    if (card.color1 == 'RED') return Colors.red.shade700;
    if (card.color1 == 'BLUE') return Colors.blue.shade700;
    if (card.color1 == 'GREEN') return Colors.green.shade700;
    if (card.color1 == 'YELLOW') return Colors.amber.shade700;
    if (card.color1 == 'BLACK') return Colors.grey.shade800;
    if (card.color1 == 'PURPLE') return Colors.purple.shade700;
    if (card.color1 == 'WHITE') return Colors.blueGrey.shade400;
    return Colors.grey.shade700;
  }
} 