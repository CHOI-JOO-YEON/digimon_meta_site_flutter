import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
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
import 'dart:async';

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
  final Function(SearchParameter)? searchWithParameter;
  final bool isExpanded;
  final Function(bool) toggleExpanded;

  const DeckEditorWidget({
    Key? key,
    required this.deck,
    required this.onEditorChanged,
    this.searchWithParameter,
    this.isExpanded = false,
    required this.toggleExpanded,
  }) : super(key: key);

  @override
  State<DeckEditorWidget> createState() => _DeckEditorWidgetState();
}

class _DeckEditorWidgetState extends State<DeckEditorWidget> with WidgetsBindingObserver, TickerProviderStateMixin {
  final TextEditingController _editorController = TextEditingController();
  final FocusNode _editorFocusNode = FocusNode();
  bool _isEditorExpanded = false;
  
  // 애니메이션 컨트롤러들
  late AnimationController _expandAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _pulseAnimation;
  
  // 슬래시 패턴 (슬래시로 시작하는 명령어)
  final RegExp _slashCommandRegex = RegExp(r'(/[a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ_]*)$');
  
  bool _showSuggestions = false;
  List<DigimonCard> _suggestions = [];
  String _currentCommand = '';
  int _commandStartIndex = 0;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();
  final GlobalKey<EditableTextState> _editableTextKey =
      GlobalKey<EditableTextState>();
  Offset _overlayOffset = Offset.zero;
  int _selectedSuggestionIndex = 0;
  
  // 무한 스크롤을 위한 변수들 제거
  final ScrollController _scrollController = ScrollController();
  int _pageSize = 10; // 기본값 유지
  
  // 키보드 네비게이션 중인지 추적하는 변수
  bool _isNavigatingWithKeyboard = false;

  // 현재 참조된 카드들 관리
  List<DigimonCard> _referencedCards = [];
  
  // 최근에 추가한 카드 목록 관리
  List<DigimonCard> _recentlyAddedCards = [];
  
  // 키보드 반복 처리를 위한 타이머
  Timer? _keyRepeatTimer;
  bool _isKeyDown = false;
  int _keyRepeatDelay = 400; // 첫 번째 반복까지의 지연 시간 (밀리초) - 더 길게 설정
  int _keyRepeatInterval = 150; // 반복 간격 (밀리초) - 더 느리게 설정
  LogicalKeyboardKey? _currentKey;

  // 마우스 호버 항목 인덱스
  int? _hoverIndex;

  // 오버레이 상태 추적을 위한 변수 추가
  bool _isOverlayAttached = false;
  
  // 키보드 닫힘 상태 추적
  bool _isKeyboardClosing = false;

  // 키보드 높이 추적
  double _previousKeyboardHeight = 0;

  // 메뉴얼 검색 상태 추적
  bool _isManualSearch = false;

  @override
  void initState() {
    super.initState();
    _editorController.text = widget.deck.description ?? '';
    
    // 애니메이션 컨트롤러 초기화
    _expandAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _expandAnimationController,
      curve: Curves.easeInOutCubic,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // 펄스 애니메이션 반복
    _pulseAnimationController.repeat(reverse: true);
    
    // 텍스트 변경 리스너
    _editorController.addListener(_onTextChanged);
    
    // 포커스 변경 리스너
    _editorFocusNode.addListener(() {
      // 포커스가 없어져도 자동완성 유지 - 다이얼로그를 통해서만 닫힘
      if (!_editorFocusNode.hasFocus && !_showSuggestions) {
        _updateReferencedCards();
      }
    });
    
    // WidgetsBinding 옵저버 등록
    WidgetsBinding.instance.addObserver(this);
    
    // 초기 참조 카드 로드
    _updateReferencedCards();
    
    // 초기 확장 상태 설정
    if (widget.isExpanded) {
      _expandAnimationController.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(DeckEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 확장 상태가 변경된 경우 애니메이션 실행
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandAnimationController.forward();
      } else {
        _expandAnimationController.reverse();
      }
    }
    
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
    // WidgetsBinding 옵저버 제거
    WidgetsBinding.instance.removeObserver(this);
    
    // 애니메이션 컨트롤러 정리
    _expandAnimationController.dispose();
    _pulseAnimationController.dispose();
    
    _removeSuggestions();
    _editorController.dispose();
    _editorFocusNode.dispose();
    _scrollController.dispose();
    _cancelKeyRepeat(); // 타이머 취소
    super.dispose();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 의존성 변경 시(다이얼로그 표시 등) 자동완성 닫기
    if (_isOverlayAttached) {
      _hideOnInteraction();
    }
  }
  
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // 키보드 높이 변화 감지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      
      // 키보드가 내려갔으나 (높이가 0이 됨) 자동완성이 표시 중인 경우
      if (_previousKeyboardHeight > 0 && keyboardHeight == 0 && _showSuggestions) {
        // 자동완성은 유지 (아무것도 하지 않음)
      }
      
      _previousKeyboardHeight = keyboardHeight;
    });
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

        // 텍스트를 덱 설명에 임시 저장하여 포커스 변경 시에도 유지
        widget.deck.description = text;
        widget.onEditorChanged();

        // "/"만 입력했거나 접두어로 시작하는 경우
        if (_currentCommand.length > 1) {
          _searchCards(_currentCommand.substring(1)); // 슬래시 제거
        } else {
          _showRecentCards();
        }
        return;
      }
    }
    
    // 포커스 손실로 인한 불필요한 제안 제거 방지
    if (_editorFocusNode.hasFocus) {
      _removeSuggestions();
    }
    
    // 일반 텍스트 변경
    widget.deck.description = text;
    widget.onEditorChanged();
    
    // 참조된 카드 목록 업데이트
    _updateReferencedCards();
    
    // 헤더의 카운터 업데이트를 위해 setState 호출
    setState(() {});

    // 텍스트 입력으로 높이가 변할 수 있으므로 오버레이 위치 업데이트
    if (_showSuggestions) {
      _updateOverlay();
    }
  }
  
  void _showRecentCards() {
    // 최근 추가한 카드 표시
    if (_recentlyAddedCards.isEmpty) {
      // 최근 추가한 카드가 없는 경우 아무것도 표시하지 않음
      _suggestions = [];
    } else {
      // 최근 추가한 카드를 역순으로 표시 (전체 데이터)
      _suggestions = _recentlyAddedCards.reversed.toList();
    }
    
    _selectedSuggestionIndex = 0;
    
    // 제안할 카드가 있는 경우에만 자동완성 표시
    if (_suggestions.isNotEmpty) {
      _showAutocomplete();
    } else {
      _removeSuggestions();
    }
  }
  
  void _searchCards(String query) {
    final searchService = CardDataService();
    
    // 검색어가 비어있으면 최근 카드 표시
    if (query.isEmpty) {
      _showRecentCards();
      return;
    }
    
    List<DigimonCard> results = [];
    
    // 카드 번호로 먼저 검색 (cardNo 기준 prefix 검색)
    // if (query.isNotEmpty) {
    //   results = searchService.searchCardsByNumber(query)
    //       .where((card) => 
    //           card.cardNo != null && 
    //           card.cardNo!.toLowerCase().startsWith(query.toLowerCase()) && 
    //           card.isParallel == false) // 패럴렐 카드 제외, prefix 검색
    //       .toList();
        
    //   if (results.isNotEmpty) {
    //     _allSearchResults = results; // 전체 검색 결과 저장
    //     _suggestions = results.take(_pageSize).toList(); // 첫 페이지만 표시
    //     _hasMoreData = results.length > _pageSize;
    //     _selectedSuggestionIndex = 0;
    //     _showAutocomplete();
    //     return;
    //   }
    // }
    
    // 이름으로 카드 검색 (prefix 검색, 패럴렐 카드 제외)
    results = searchService.searchCardsByText(query)
        .where((card) => 
            card.getDisplayName() != null && 
            card.getDisplayName()!.toLowerCase().startsWith(query.toLowerCase()) && 
            card.isParallel == false)
        .toList();
    
    // 전체 결과 표시 (무한 스크롤 대신)
    _suggestions = results;
    
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
    _isOverlayAttached = true;

    // 오버레이가 생성된 후 위치 업데이트
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateOverlay();
    });

    // 외부 클릭 감지를 위한 리스너 추가
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 다이얼로그가 열리는 것을 감지
      if (ModalRoute.of(context)?.isCurrent == false) {
        _hideOnInteraction();
      }
    });
  }
  
  void _removeSuggestions() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      _isOverlayAttached = false;
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
    
    // 최근 추가한 카드 목록에 추가 (중복 제거)
    if (!_recentlyAddedCards.any((c) => c.cardNo == card.cardNo)) {
      _recentlyAddedCards.add(card);
      // 최대 20개로 제한
      if (_recentlyAddedCards.length > 20) {
        _recentlyAddedCards.removeAt(0);
      }
    } else {
      // 이미 있는 경우, 해당 카드를 제거하고 맨 뒤에 추가 (가장 최근으로 갱신)
      _recentlyAddedCards.removeWhere((c) => c.cardNo == card.cardNo);
      _recentlyAddedCards.add(card);
    }
    
    // 토스트 메시지 표시
    ToastOverlay.show(
      context, 
      '카드 참조가 추가되었습니다: ${card.getDisplayName()}',
      type: ToastType.success,
    );
    
    _removeSuggestions();
    
    // 수동 검색 모드 해제
    setState(() {
      _isManualSearch = false;
    });

    // 편집기에 포커스를 다시 맞춤
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(_editorFocusNode);
      }
    });
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
      
      // 스크롤 위치 조정 - 선택된 항목이 보이도록
      if (_scrollController.hasClients && _suggestions.length > 3) {
        final itemHeight = 48.0; // 각 항목의 예상 높이
        final targetPosition = itemHeight * _selectedSuggestionIndex;
        
        if (targetPosition < _scrollController.position.pixels ||
            targetPosition > _scrollController.position.viewportDimension + _scrollController.position.pixels - itemHeight) {
          _scrollController.animateTo(
            targetPosition,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
      }
      
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
      
      // 스크롤 위치 조정 - 선택된 항목이 보이도록
      if (_scrollController.hasClients && _suggestions.length > 3) {
        final itemHeight = 48.0; // 각 항목의 예상 높이
        final targetPosition = itemHeight * _selectedSuggestionIndex;
        
        if (targetPosition > _scrollController.position.viewportDimension + _scrollController.position.pixels - itemHeight * 2 ||
            targetPosition < _scrollController.position.pixels) {
          _scrollController.animateTo(
            targetPosition - itemHeight,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        }
      }
      
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

      // 커서 위치 기반으로 오버레이 위치 계산
      _overlayOffset = _calculateCaretOffset();

      // 오버레이 강제 업데이트 - 이 방식이 더 안정적
      _overlayEntry!.markNeedsBuild();
    }
  }
  
  // 키 반복 타이머 취소
  void _cancelKeyRepeat() {
    _keyRepeatTimer?.cancel();
    _keyRepeatTimer = null;
    _isKeyDown = false;
    _currentKey = null;
  }
  
  // 키 반복 시작
  void _startKeyRepeat(LogicalKeyboardKey key) {
    _cancelKeyRepeat();
    _isKeyDown = true;
    _currentKey = key;
    
    // 첫 번째 반복은 즉시 실행
    _processKeyAction(key);
    
    // 추가 반복을 위한 타이머 설정
    _keyRepeatTimer = Timer(Duration(milliseconds: _keyRepeatDelay), () {
      // 첫 번째 딜레이 후, 더 빠른 간격으로 반복
      _keyRepeatTimer = Timer.periodic(Duration(milliseconds: _keyRepeatInterval), (timer) {
        if (_isKeyDown) {
          _processKeyAction(key);
        } else {
          _cancelKeyRepeat();
        }
      });
    });
  }
  
  // 키 액션 처리
  void _processKeyAction(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveSelectionUp();
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _moveSelectionDown();
    }
  }

  // 현재 커서 위치를 기준으로 오버레이 위치 계산
  Offset _calculateCaretOffset() {
    final EditableTextState? editable = _editableTextKey.currentState;
    final RenderBox? containerBox =
        _textFieldKey.currentContext?.findRenderObject() as RenderBox?;

    if (editable != null && containerBox != null) {
      final RenderEditable renderEditable = editable.renderEditable;
      final TextPosition position = _editorController.selection.extent;
      final caretRect = renderEditable.getLocalRectForCaret(position);
      final caretGlobal = renderEditable.localToGlobal(caretRect.bottomLeft);
      final containerGlobal = containerBox.localToGlobal(Offset.zero);
      return caretGlobal - containerGlobal + const Offset(0, 5);
    }

    // 기본적으로 텍스트 필드 아래에 위치
    final size = containerBox?.size ?? Size.zero;
    return Offset(0, size.height);
  }

  OverlayEntry _createOverlayEntry() {
    // TextField의 RenderBox 가져오기 (정확한 위치 계산을 위해 GlobalKey 사용)
    final renderBox = _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size.zero;

    // 최초 생성 시 오버레이 위치 계산
    _overlayOffset = _calculateCaretOffset();
    
    // 고정 높이 정의
    final double maxOverlayHeight = 320.0; // 최대 높이 제한 약간 증가
    
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: _overlayOffset,
          child: TweenAnimationBuilder<double>(
            duration: Duration(milliseconds: 200),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.95 + (0.05 * value),
                alignment: Alignment.topCenter,
                child: Opacity(
                  opacity: value,
                  child: Material(
                    elevation: 12.0,
                    borderRadius: BorderRadius.circular(16),
                    shadowColor: Colors.black.withOpacity(0.15),
                    child: Container(
                      // 최대 높이 지정
                      constraints: BoxConstraints(
                        maxHeight: maxOverlayHeight,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).cardColor,
                            Theme.of(context).cardColor.withOpacity(0.95),
                          ],
                        ),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 헤더 추가
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).primaryColor.withOpacity(0.1),
                                  Theme.of(context).primaryColor.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(14),
                                topRight: Radius.circular(14),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search_rounded,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '카드 검색 결과',
                                  style: TextStyle(
                                    fontSize: SizeService.bodyFontSize(context) * 0.85,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${_suggestions.length}개',
                                    style: TextStyle(
                                      fontSize: SizeService.bodyFontSize(context) * 0.75,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: _suggestions.isEmpty 
                              ? Container(
                                  height: 80,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.search_off_rounded,
                                          color: Colors.grey.shade400,
                                          size: 24,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          '검색 결과가 없습니다',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: SizeService.bodyFontSize(context) * 0.9,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ScrollConfiguration(
                                  behavior: ScrollBehavior().copyWith(
                                    scrollbars: true,
                                    dragDevices: {
                                      PointerDeviceKind.touch,
                                      PointerDeviceKind.mouse,
                                      PointerDeviceKind.trackpad,
                                      PointerDeviceKind.stylus,
                                      PointerDeviceKind.unknown,
                                    },
                                    physics: ClampingScrollPhysics(), 
                                  ),
                                  child: RawScrollbar(
                                    controller: _scrollController,
                                    thumbVisibility: true,
                                    thickness: 4.0,
                                    radius: Radius.circular(10),
                                    thumbColor: Theme.of(context).primaryColor.withOpacity(0.3),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      controller: _scrollController,
                                      padding: EdgeInsets.symmetric(vertical: 4),
                                      itemCount: _suggestions.length,
                                      itemBuilder: (context, index) {
                                        final card = _suggestions[index];
                                        final isSelected = index == _selectedSuggestionIndex;
                                        final isHovered = index == _hoverIndex;
                                        
                                        return AnimatedContainer(
                                          duration: Duration(milliseconds: 150),
                                          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedSuggestionIndex = index;
                                              });
                                              _selectSuggestion(card);
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: MouseRegion(
                                              onEnter: (event) {
                                                setState(() {
                                                  _hoverIndex = index;
                                                  _selectedSuggestionIndex = index;
                                                });
                                                _updateOverlay();
                                              },
                                              onExit: (event) {
                                                if (_hoverIndex == index) {
                                                  setState(() {
                                                    _hoverIndex = null;
                                                  });
                                                  _updateOverlay();
                                                }
                                              },
                                              cursor: SystemMouseCursors.click,
                                              child: AnimatedContainer(
                                                duration: Duration(milliseconds: 150),
                                                height: 52.0,
                                                decoration: BoxDecoration(
                                                  gradient: isSelected || isHovered 
                                                      ? LinearGradient(
                                                          colors: [
                                                            Theme.of(context).primaryColor.withOpacity(0.15),
                                                            Theme.of(context).primaryColor.withOpacity(0.08),
                                                          ],
                                                        )
                                                      : null,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: isSelected || isHovered
                                                      ? Border.all(
                                                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                                                          width: 1.5,
                                                        )
                                                      : null,
                                                  boxShadow: isSelected || isHovered 
                                                      ? [
                                                          BoxShadow(
                                                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                                                            blurRadius: 8,
                                                            offset: Offset(0, 2),
                                                          ),
                                                        ]
                                                      : null,
                                                ),
                                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: _getColorForCardType(card).withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(
                                                          color: _getColorForCardType(card).withOpacity(0.3),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        card.cardNo ?? '',
                                                        style: TextStyle(
                                                          fontSize: SizeService.bodyFontSize(context) * 0.8,
                                                          fontWeight: FontWeight.w600,
                                                          color: _getColorForCardType(card),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        card.getDisplayName() ?? '',
                                                        style: TextStyle(
                                                          fontSize: SizeService.bodyFontSize(context) * 0.9,
                                                          fontWeight: (isSelected || isHovered) ? FontWeight.w600 : FontWeight.w500,
                                                          color: (isSelected || isHovered) 
                                                              ? Theme.of(context).primaryColor
                                                              : Theme.of(context).textTheme.bodyLarge?.color,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    if (isSelected || isHovered)
                                                      Icon(
                                                        Icons.arrow_forward_ios_rounded,
                                                        size: 14,
                                                        color: Theme.of(context).primaryColor,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  bool _isMobileWeb() {
    // 모바일 웹 브라우저 감지
    final navigatorPlatform = WidgetsBinding.instance.window.platformDispatcher.defaultRouteName;
    return navigatorPlatform.contains('android') || 
           navigatorPlatform.contains('ios') || 
           navigatorPlatform.contains('mobile');
  }

  @override
  Widget build(BuildContext context) {
    // 현재 키보드 높이 저장
    _previousKeyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    // 모바일 환경인지 확인
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    // 텍스트 필드 위젯 - 키보드 이벤트 처리 로직 복원
    Widget textField = Focus(
      onKeyEvent: (FocusNode node, KeyEvent event) {
        // 자동완성이 활성화된 경우에만 특정 키 이벤트를 가로챔
        if (_showSuggestions) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              // 키 반복 시작
              _startKeyRepeat(LogicalKeyboardKey.arrowUp);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              // 키 반복 시작
              _startKeyRepeat(LogicalKeyboardKey.arrowDown);
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter || 
                      event.logicalKey == LogicalKeyboardKey.tab) {
              _confirmSelection();
              return KeyEventResult.handled;
            }
          } else if (event is KeyUpEvent) {
            // 키에서 손을 뗀 경우 반복 취소
            if (event.logicalKey == LogicalKeyboardKey.arrowUp || 
                event.logicalKey == LogicalKeyboardKey.arrowDown) {
              _cancelKeyRepeat();
              return KeyEventResult.handled;
            }
          }
        } else if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.tab) {
          return KeyEventResult.handled;
        }
        // 다른 모든 키 이벤트는 전달됨
        return KeyEventResult.ignored;
      },
             child: TextField(
         key: _editableTextKey,
         controller: _editorController,
         focusNode: _editorFocusNode,
         maxLines: 10,
         minLines: 5,
         maxLength: 1000,
         style: TextStyle(
           fontSize: SizeService.bodyFontSize(context),
           height: 1.5,
           letterSpacing: 0.2,
         ),
         buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
           // 카운터를 헤더로 이동했으므로 빈 위젯 반환
           return SizedBox.shrink();
         },
         inputFormatters: [
           LengthLimitingTextInputFormatter(1000),
         ],
         decoration: InputDecoration(
           hintText: '덱 설명을 입력하세요 (최대 1000자)',
           hintStyle: TextStyle(
             color: Colors.grey.shade500,
             fontSize: SizeService.bodyFontSize(context) * 0.95,
             fontWeight: FontWeight.w400,
           ),
           contentPadding: EdgeInsets.all(SizeService.paddingSize(context) * 1.2),
           filled: true,
           fillColor: Colors.transparent,
           border: InputBorder.none,
           enabledBorder: InputBorder.none,
           focusedBorder: InputBorder.none,
           errorBorder: InputBorder.none,
           focusedErrorBorder: InputBorder.none,
           disabledBorder: InputBorder.none,
           counterText: null, // buildCounter를 사용하므로 기본 카운터 텍스트 숨김
         ),
         scrollPadding: EdgeInsets.zero,
         keyboardType: TextInputType.multiline,
         textInputAction: TextInputAction.newline,
         enableInteractiveSelection: true,
         // 화면 바깥 터치 시 키보드 닫기만 처리
         onTapOutside: (event) {
           // 화면 바깥을 터치했을 때 키보드는 닫히지만 자동완성은 유지
           if (!_showSuggestions) {
             _editorFocusNode.unfocus();
           }
         },
         // 모바일 웹에서의 동작 개선
         autocorrect: false, // 자동 수정 비활성화
         enableSuggestions: false, // 제안 기능 비활성화
       ),
    );

    // 카드 검색 버튼 제거

    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).cardColor,
                Theme.of(context).cardColor.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          margin: EdgeInsets.only(bottom: SizeService.paddingSize(context)),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // 상위 위젯에 있는 토글 함수 호출
                    widget.toggleExpanded(!widget.isExpanded);
                  },
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: widget.isExpanded ? Radius.zero : Radius.circular(20),
                    bottomRight: widget.isExpanded ? Radius.zero : Radius.circular(20),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(SizeService.paddingSize(context)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.1),
                          Theme.of(context).primaryColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: widget.isExpanded ? Radius.zero : Radius.circular(20),
                        bottomRight: widget.isExpanded ? Radius.zero : Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedRotation(
                          turns: widget.isExpanded ? 0.5 : 0,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          child: AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: widget.isExpanded ? 1.0 : _pulseAnimation.value,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.expand_more_rounded,
                                    size: SizeService.bodyFontSize(context) * 1.3,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: SizeService.paddingSize(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_note_rounded,
                                    size: SizeService.bodyFontSize(context) * 1.2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '덱 설명',
                                    style: TextStyle(
                                      fontSize: SizeService.bodyFontSize(context) * 1.1,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              if (!widget.isExpanded && _referencedCards.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${_referencedCards.length}개의 카드 참조',
                                    style: TextStyle(
                                      fontSize: SizeService.bodyFontSize(context) * 0.85,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                                                 if (widget.isExpanded) ...[
                           Container(
                             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                             decoration: BoxDecoration(
                               color: _editorController.text.length >= 1000
                                   ? Colors.red.withOpacity(0.1)
                                   : Colors.grey.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(8),
                             ),
                             child: Text(
                               '${_editorController.text.length}/1000',
                               style: TextStyle(
                                 fontSize: SizeService.bodyFontSize(context) * 0.75,
                                 fontWeight: FontWeight.w500,
                                 color: _editorController.text.length >= 1000 ? Colors.red : Colors.grey.shade600,
                               ),
                             ),
                           ),
                           SizedBox(width: 8),
                           Container(
                             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                             decoration: BoxDecoration(
                               color: Theme.of(context).primaryColor.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(20),
                               border: Border.all(
                                 color: Theme.of(context).primaryColor.withOpacity(0.2),
                                 width: 1,
                               ),
                             ),
                             child: Row(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Icon(
                                   Icons.keyboard_rounded,
                                   size: 14,
                                   color: Theme.of(context).primaryColor,
                                 ),
                                 SizedBox(width: 4),
                                 Text(
                                   '편집중',
                                   style: TextStyle(
                                     fontSize: SizeService.bodyFontSize(context) * 0.8,
                                     fontWeight: FontWeight.w600,
                                     color: Theme.of(context).primaryColor,
                                   ),
                                 ),
                               ],
                             ),
                           ),
                         ],
                      ],
                    ),
                  ),
                ),
              ),
              ClipRect(
                child: AnimatedSize(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOutCubic,
                  child: widget.isExpanded
                      ? Padding(
                          padding: EdgeInsets.all(SizeService.paddingSize(context) * 1.2),
                          child: Column(
                                                         children: [
                               CompositedTransformTarget(
                                 link: _layerLink,
                                 child: Material(
                                   key: _textFieldKey,
                                   clipBehavior: Clip.antiAlias,
                                   borderRadius: BorderRadius.circular(16),
                                   elevation: _editorFocusNode.hasFocus ? 4 : 2,
                                   shadowColor: _editorFocusNode.hasFocus 
                                       ? Theme.of(context).primaryColor.withOpacity(0.2)
                                       : Colors.black.withOpacity(0.1),
                                   child: Container(
                                     decoration: BoxDecoration(
                                       gradient: LinearGradient(
                                         begin: Alignment.topLeft,
                                         end: Alignment.bottomRight,
                                         colors: [
                                           Colors.grey.shade50,
                                           Colors.white,
                                         ],
                                       ),
                                       border: Border.all(
                                         color: _editorFocusNode.hasFocus 
                                             ? Theme.of(context).primaryColor.withOpacity(0.5)
                                             : Colors.grey.shade300,
                                         width: _editorFocusNode.hasFocus ? 2 : 1,
                                       ),
                                       borderRadius: BorderRadius.circular(16),
                                     ),
                                     child: textField,
                                   ),
                                 ),
                               ),
                              SizedBox(height: SizeService.paddingSize(context)),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade50,
                                      Colors.indigo.shade50,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.lightbulb_outline_rounded,
                                        size: 16,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        '/ 명령어를 입력하면 카드 참조를 추가할 수 있습니다.',
                                        style: TextStyle(
                                          fontSize: SizeService.bodyFontSize(context) * 0.85,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // 참조된 카드 표시 영역
                              if (_referencedCards.isNotEmpty) 
                                _buildReferencedCardsSection(),
                            ],
                          ),
                        )
                      : SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 카드 정보 표시 메서드
  void _showCardInfo(BuildContext context, String cardNo) {
    final card = CardDataService().getCardByCardNo(cardNo);
    if (card != null) {
      // CardService를 사용하여 카드 이미지 다이얼로그 표시
      CardService().showImageDialog(
        context, 
        card, 
        searchWithParameter: widget.searchWithParameter
      );
    }
  }

  // 참조된 카드 UI 부분 수정
  Widget _buildReferencedCardsSection() {
    if (_referencedCards.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: SizeService.paddingSize(context) * 1.5),
        Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.15),
                      Theme.of(context).primaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.link_rounded,
                  size: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '참조된 카드',
                style: TextStyle(
                  fontSize: SizeService.bodyFontSize(context) * 1.05,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_referencedCards.length}',
                  style: TextStyle(
                    fontSize: SizeService.bodyFontSize(context) * 0.8,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity, // 전체 가로 폭 사용
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade50,
                Colors.white,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.all(16.0),
          child: _referencedCards.isEmpty
              ? Container(
                  height: 60,
                  child: Center(
                    child: Text(
                      '참조된 카드가 없습니다',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: SizeService.bodyFontSize(context) * 0.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 12.0, // 가로 간격
                  runSpacing: 12.0, // 세로 간격
                  children: _referencedCards.asMap().entries.map((entry) {
                    final index = entry.key;
                    final card = entry.value;
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: CardReferenceChip(
                              card: card,
                              onTap: () => _showCardInfo(context, card.cardNo!),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  // 다른 위젯과의 상호작용 시 자동완성 닫기
  void _hideOnInteraction() {
    if (_showSuggestions) {
      _removeSuggestions();
    }
  }

  // 자동완성 UI에서 MouseRegion 위젯에 추가할 onTap 핸들러 
  void _onItemHover(int index) {
    if (index != _selectedSuggestionIndex && index >= 0 && index < _suggestions.length) {
      setState(() {
        _selectedSuggestionIndex = index;
        _hoverIndex = index;
      });
      _updateOverlay();
    }
  }

  // 카드 타입에 따른 배경색 반환 함수
  Color _getColorForCardType(DigimonCard card) {
    if (card.color1 == 'RED') return Colors.red.shade600;
    if (card.color1 == 'BLUE') return Colors.blue.shade600;
    if (card.color1 == 'GREEN') return Colors.green.shade600;
    if (card.color1 == 'YELLOW') return Colors.orange.shade600;
    if (card.color1 == 'BLACK') return Colors.grey.shade700;
    if (card.color1 == 'PURPLE') return Colors.purple.shade600;
    if (card.color1 == 'WHITE') return Colors.blueGrey.shade500;
    return Colors.grey.shade600;
  }
}

// 참조된 카드를 나타내는 칩 위젯
class CardReferenceChip extends StatefulWidget {
  final DigimonCard card;
  final VoidCallback onTap;

  const CardReferenceChip({
    Key? key,
    required this.card,
    required this.onTap,
  }) : super(key: key);

  @override
  State<CardReferenceChip> createState() => _CardReferenceChipState();
}

class _CardReferenceChipState extends State<CardReferenceChip> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
    _elevationAnimation = Tween<double>(
      begin: 2.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _getColorForCardType(widget.card);
    
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      cursor: SystemMouseCursors.click,
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cardColor.withOpacity(0.9),
                      cardColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: cardColor.withOpacity(0.3),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 2),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.card.cardNo}',
                        style: TextStyle(
                          fontSize: SizeService.bodyFontSize(context) * 0.75,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (widget.card.getDisplayName() != null) ...[
                      SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 140),
                        child: Text(
                          widget.card.getDisplayName()!,
                          style: TextStyle(
                            fontSize: SizeService.bodyFontSize(context) * 0.85,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (_isHovered) ...[
                      SizedBox(width: 8),
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // 카드 타입에 따른 배경색 반환
  Color _getColorForCardType(DigimonCard card) {
    if (card.color1 == 'RED') return Colors.red.shade600;
    if (card.color1 == 'BLUE') return Colors.blue.shade600;
    if (card.color1 == 'GREEN') return Colors.green.shade600;
    if (card.color1 == 'YELLOW') return Colors.orange.shade600;
    if (card.color1 == 'BLACK') return Colors.grey.shade700;
    if (card.color1 == 'PURPLE') return Colors.purple.shade600;
    if (card.color1 == 'WHITE') return Colors.blueGrey.shade500;
    return Colors.grey.shade600;
  }
} 