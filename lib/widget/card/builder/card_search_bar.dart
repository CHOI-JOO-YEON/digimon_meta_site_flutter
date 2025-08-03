import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/service/card_data_service.dart';
import 'package:digimon_meta_site_flutter/service/color_service.dart';
import 'package:digimon_meta_site_flutter/theme/app_design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../model/note.dart';
import '../../../provider/text_simplify_provider.dart';
import '../../../service/card_overlay_service.dart';
import '../../../service/size_service.dart';
import '../../common/toast_overlay.dart';

// 마퀴 효과를 위한 ScrollingText 위젯 추가
class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double width;

  const ScrollingText({
    Key? key,
    required this.text,
    this.style,
    required this.width,
  }) : super(key: key);

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _needsScroll = false;
  double _textWidth = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    WidgetsBinding.instance.addPostFrameCallback(_checkIfNeedsScroll);
  }

  void _checkIfNeedsScroll(_) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);

    _textWidth = textPainter.width;
    
    if (_textWidth > widget.width - 40) { // 40은 대략적인 패딩과 삭제 버튼 공간
      setState(() {
        _needsScroll = true;
      });
      
      _animation = Tween<double>(
        begin: 0.0,
        end: _textWidth - widget.width + 40,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      );
      
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _animationController.reverse();
            }
          });
        } else if (status == AnimationStatus.dismissed) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              _animationController.forward();
            }
          });
        }
      });
      
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_needsScroll) {
      return Text(
        widget.text,
        style: widget.style,
        overflow: TextOverflow.ellipsis,
      );
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
            margin: EdgeInsets.only(left: -_animation.value),
            child: Text(
              widget.text,
              style: widget.style,
            ),
          ),
        );
      },
    );
  }
}

// MarqueeChip 위젯 추가
class MarqueeChip extends StatelessWidget {
  final String label;
  final VoidCallback? onDeleted;
  final String? deleteButtonTooltipMessage;
  final EdgeInsetsGeometry? labelPadding;
  final TextStyle? labelStyle;

  const MarqueeChip({
    Key? key,
    required this.label,
    this.onDeleted,
    this.deleteButtonTooltipMessage,
    this.labelPadding,
    this.labelStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            child: ScrollingText(
              text: label,
              style: labelStyle,
              width: constraints.maxWidth,
            ),
          );
        }
      ),
      deleteButtonTooltipMessage: deleteButtonTooltipMessage,
      onDeleted: onDeleted,
      labelPadding: labelPadding,
    );
  }
}

class CardSearchBar extends StatefulWidget {
  final SearchParameter searchParameter;
  final List<NoteDto> notes;
  final VoidCallback onSearch;
  final String? viewMode;
  final Function(String)? onViewModeChanged;

  final VoidCallback updateSearchParameter;

  const CardSearchBar(
      {super.key,
      required this.onSearch,
      required this.searchParameter,
      required this.notes,
      this.viewMode,
      this.onViewModeChanged, required this.updateSearchParameter});

  @override
  State<CardSearchBar> createState() => _CardSearchBarState();
}

class _CardSearchBarState extends State<CardSearchBar> {
  TextEditingController? _trieSearchController;
  TextEditingController? _searchStringEditingController;
  TextEditingController? _dialogSearchStringEditingController;
  List<DropdownMenuItem<NoteDto>> dropDownMenuItems = [];
  final List<String> colors = [
    'RED',
    'BLUE',
    'YELLOW',
    'GREEN',
    'BLACK',
    'PURPLE',
    'WHITE'
  ];
  final List<String> cardTypes = [
    'DIGITAMA',
    'DIGIMON',
    'TAMER',
    'OPTION',
  ];
  final List<String> rarities = ['C', 'U', 'R', 'SR', 'SEC', 'P'];
  final List<int> levels = [0, 2, 3, 4, 5, 6, 7];
  NoteDto all = NoteDto(noteId: null, name: '모든 카드');
  bool _isFeaturesSectionExpanded = false;
  bool _isDetailedSearchSectionExpanded = false;
  int _selectedFeatureTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchStringEditingController =
        TextEditingController(text: widget.searchParameter.searchString);
  }

  @override
  void didUpdateWidget(CardSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // searchParameter가 변경되었을 때 텍스트 필드 갱신
    if (widget.searchParameter.searchString != oldWidget.searchParameter.searchString) {
      _searchStringEditingController?.text = widget.searchParameter.searchString ?? '';
    }
  }

  String getCardTypeByString(String s) {
    switch (s) {
      case 'TAMER':
        return '테이머';
      case 'OPTION':
        return '옵션';
      case 'DIGIMON':
        return '디지몬';
      case 'DIGITAMA':
        return '디지타마';
      default:
        return "에러";
    }
  }

  String getKorColorStringByEn(String s) {
    switch (s) {
      case 'RED':
        return '레드';
      case 'BLUE':
        return '블루';
      case 'YELLOW':
        return '옐로';
      case 'GREEN':
        return '그린';
      case 'BLACK':
        return '블랙';
      case 'PURPLE':
        return '퍼플';
      case 'WHITE':
        return '화이트';
      default:
        return "에러";
    }
  }


  void _showFilterDialog() {
    CardOverlayService().removeAllOverlays();
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        // 검색 결과 변수들을 StatefulBuilder 내부로 이동
        Set<String> searchResults = CardDataService().searchTypes("");
        Set<String> formSearchResults = CardDataService().searchForms("");
        Set<String> attributeSearchResults = CardDataService().searchAttributes("");
        
        // Set 복사본을 생성하여 원본과 분리
        Set<String> selectedTypes = Set.from(widget.searchParameter.types);
        Set<String> selectedForms = Set.from(widget.searchParameter.forms);
        Set<String> selectedAttributes = Set.from(widget.searchParameter.attributes);
        
        int formOperation = widget.searchParameter.formOperation;
        int attributeOperation = widget.searchParameter.attributeOperation;
    
    TextEditingController _cardNameSearchController = TextEditingController(
      text: widget.searchParameter.cardNameSearch ?? ''
    );
    TextEditingController _cardNoSearchController = TextEditingController(
      text: widget.searchParameter.cardNoSearch ?? ''
    );
    TextEditingController _effectSearchController = TextEditingController(
      text: widget.searchParameter.effectSearch ?? ''
    );
    TextEditingController _sourceEffectSearchController = TextEditingController(
      text: widget.searchParameter.sourceEffectSearch ?? ''
    );
    
    NoteDto? selectedNote;

    if (widget.searchParameter.noteId == null) {
      selectedNote = all;
    } else {
      for (var note in widget.notes) {
        if (note.noteId == widget.searchParameter.noteId) {
          selectedNote = note;
          break;
        }
      }
    }

    Map<String, bool> selectedColorMap = {};
    for (var color in colors) {
      selectedColorMap[color] =
          widget.searchParameter.colors?.contains(color) ?? false;
    }

    Map<String, bool> selectedCardTypeMap = {};
    for (var cardType in cardTypes) {
      selectedCardTypeMap[cardType] =
          widget.searchParameter.cardTypes?.contains(cardType) ?? false;
    }

    Map<int, bool> selectedLvMap = {};
    for (var lv in levels) {
      selectedLvMap[lv] = widget.searchParameter.lvs?.contains(lv) ?? false;
    }

    Map<String, bool> selectedRarityMap = {};
    for (var rarity in rarities) {
      selectedRarityMap[rarity] =
          widget.searchParameter.rarities?.contains(rarity) ?? false;
    }

    RangeValues currentDpRange = RangeValues(
        widget.searchParameter.minDp as double,
        widget.searchParameter.maxDp as double);

    RangeValues currentPlayCostRange = RangeValues(
        widget.searchParameter.minPlayCost as double,
        widget.searchParameter.maxPlayCost as double);
    RangeValues currentDigivolutionCostRange = RangeValues(
        widget.searchParameter.minDigivolutionCost as double,
        widget.searchParameter.maxDigivolutionCost as double);

    _dialogSearchStringEditingController =
        TextEditingController(text: _searchStringEditingController?.value.text);
    _trieSearchController = TextEditingController();
    TextEditingController formSearchController = TextEditingController();
    TextEditingController attributeSearchController = TextEditingController();
    int parallelOption = widget.searchParameter.parallelOption;
    bool enCardInclude = widget.searchParameter.isEnglishCardInclude;
    int typeOperation = widget.searchParameter.typeOperation;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(isPortrait ? 16 : 24),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isPortrait ? double.infinity : 600,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                  ),
                ],
              ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                    // 헤더
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.1),
                            Theme.of(context).primaryColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                          child: Row(
                            children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                                color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                  "세부 검색 조건",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close_rounded, size: 24),
                              color: Colors.grey[600],
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 검색어 입력
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 통합 검색어
                            _buildSearchSection(
                              title: "통합 검색",
                              icon: Icons.search_rounded,
                              child: TextField(
                                controller: _dialogSearchStringEditingController,
                                decoration: InputDecoration(
                                  hintText: '카드명, 효과, 번호 등 통합 검색',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).primaryColor),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 상세 검색
                            _buildExpandableSection(
                              title: "상세 검색",
                              icon: Icons.manage_search_rounded,
                              isExpanded: _isDetailedSearchSectionExpanded,
                              onToggle: () => setState(() => _isDetailedSearchSectionExpanded = !_isDetailedSearchSectionExpanded),
                              child: Column(
                                children: [
                                  _buildDetailedSearchField(
                                    controller: _cardNameSearchController,
                                    label: "카드명",
                                    hint: "@ 접두사로 정규표현식 사용 가능",
                                    icon: Icons.badge_rounded,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailedSearchField(
                                    controller: _cardNoSearchController,
                                    label: "카드 번호",
                                    hint: "@ 접두사로 정규표현식 사용 가능",
                                    icon: Icons.numbers_rounded,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailedSearchField(
                                    controller: _effectSearchController,
                                    label: "상단 텍스트",
                                    hint: "@ 접두사로 정규표현식 사용 가능",
                                    icon: Icons.description_rounded,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailedSearchField(
                                    controller: _sourceEffectSearchController,
                                    label: "하단 텍스트",
                                    hint: "@ 접두사로 정규표현식 사용 가능",
                                    icon: Icons.notes_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            
                            const SizedBox(height: 24),
                            
                            // 입수처
                            _buildSearchSection(
                              title: "입수처",
                              icon: Icons.inventory_2_rounded,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                        child: DropdownButton<NoteDto>(
                          value: selectedNote,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600]),
                          hint: Text(
                                    selectedNote?.name ?? "입수처 선택",
                                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                          ),
                          items: dropDownMenuItems,
                          onChanged: (NoteDto? newValue) {
                            setState(() {
                              selectedNote = newValue;
                              if (newValue!.cardOrigin == 'ENGLISH') {
                                enCardInclude = true;
                              }
                            });
                          },
                        ),
                      ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 레벨
                            _buildSearchSection(
                              title: "레벨",
                              icon: Icons.stairs_rounded,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                        children: selectedLvMap.keys.map((lv) {
                                  final isSelected = selectedLvMap[lv] ?? false;
                                  return _buildFilterChip(
                                    label: lv == 0 ? '−' : '$lv',
                                    isSelected: isSelected,
                                    onSelected: (selected) {
                                  setState(() {
                                        selectedLvMap[lv] = selected;
                                  });
                                },
                          );
                        }).toList(),
                      ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 컬러
                            _buildSearchSection(
                              title: "컬러",
                              icon: Icons.palette_rounded,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                        children: selectedColorMap.keys.map((color) {
                                  final isSelected = selectedColorMap[color] ?? false;
                                  return _buildColorChip(
                                    color: color,
                                    label: getKorColorStringByEn(color),
                                    isSelected: isSelected,
                                    onSelected: (selected) {
                                  setState(() {
                                        selectedColorMap[color] = selected;
                                  });
                                },
                          );
                        }).toList(),
                      ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 카드 타입
                            _buildSearchSection(
                              title: "카드 타입",
                              icon: Icons.category_rounded,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                        children: selectedCardTypeMap.keys.map((cardType) {
                                  final isSelected = selectedCardTypeMap[cardType] ?? false;
                                  return _buildFilterChip(
                                    label: getCardTypeByString(cardType),
                                    isSelected: isSelected,
                                    onSelected: (selected) {
                                  setState(() {
                                        selectedCardTypeMap[cardType] = selected;
                                  });
                                },
                          );
                        }).toList(),
                      ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 레어도
                            _buildSearchSection(
                              title: "레어도",
                              icon: Icons.diamond_rounded,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                        children: selectedRarityMap.keys.map((rarity) {
                                  final isSelected = selectedRarityMap[rarity] ?? false;
                                  return _buildFilterChip(
                                    label: rarity,
                                    isSelected: isSelected,
                                    onSelected: (selected) {
                                  setState(() {
                                        selectedRarityMap[rarity] = selected;
                                  });
                                },
                          );
                        }).toList(),
                      ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 패럴렐 여부
                            _buildSearchSection(
                              title: "패럴렐 여부",
                              icon: Icons.auto_awesome_rounded,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                          children: [
                                  _buildFilterChip(
                                    label: "모두",
                                    isSelected: parallelOption == 0,
                                    onSelected: (selected) {
                                      if (selected) setState(() => parallelOption = 0);
                                    },
                                  ),
                                  _buildFilterChip(
                                    label: "일반 카드만",
                                    isSelected: parallelOption == 1,
                                    onSelected: (selected) {
                                      if (selected) setState(() => parallelOption = 1);
                                    },
                                  ),
                                  _buildFilterChip(
                                    label: "패럴렐 카드만",
                                    isSelected: parallelOption == 2,
                                    onSelected: (selected) {
                                      if (selected) setState(() => parallelOption = 2);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 미발매 카드 포함 여부
                            _buildSearchSection(
                              title: "미발매 카드 포함",
                              icon: Icons.new_releases_rounded,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                        children: [
                                  _buildFilterChip(
                                    label: "한국 발매카드만",
                                    isSelected: !enCardInclude,
                                    onSelected: (selected) {
                                      if (selected) setState(() => enCardInclude = false);
                                    },
                                  ),
                                  _buildFilterChip(
                                    label: "미발매 카드 포함",
                                    isSelected: enCardInclude,
                                    onSelected: (selected) {
                                      if (selected) setState(() => enCardInclude = true);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 수치 범위들
                            _buildRangeSection(
                              title: "DP",
                              icon: Icons.flash_on_rounded,
                              currentRange: currentDpRange,
                        min: 1000,
                        max: 17000,
                        divisions: 16,
                              onChanged: (values) => setState(() => currentDpRange = values),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            _buildRangeSection(
                              title: "등장/사용 코스트",
                              icon: Icons.toll_rounded,
                              currentRange: currentPlayCostRange,
                        min: 0,
                        max: 20,
                        divisions: 20,
                              onChanged: (values) => setState(() => currentPlayCostRange = values),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            _buildRangeSection(
                              title: "진화 코스트",
                              icon: Icons.trending_up_rounded,
                              currentRange: currentDigivolutionCostRange,
                        min: 0,
                        max: 8,
                        divisions: 8,
                              onChanged: (values) => setState(() => currentDigivolutionCostRange = values),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // 특징 섹션
                            _buildExpandableSection(
                              title: "특징",
                              icon: Icons.category_outlined,
                              isExpanded: _isFeaturesSectionExpanded,
                              onToggle: () => setState(() => _isFeaturesSectionExpanded = !_isFeaturesSectionExpanded),
                              child: Column(
                                children: [
                                  // 특징 옵션 선택
                              Container(
                                    padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                          child: _buildFilterChip(
                                            label: "하나라도 포함",
                                            isSelected: typeOperation == 1,
                                            onSelected: (selected) {
                                              if (selected) {
                                                setState(() {
                                                  typeOperation = 1;
                                                  formOperation = 1;
                                                  attributeOperation = 1;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                                    Expanded(
                                          child: _buildFilterChip(
                                            label: "모두 포함",
                                            isSelected: typeOperation == 0,
                                            onSelected: (selected) {
                                              if (selected) {
                                                                      setState(() {
                                                  typeOperation = 0;
                                                  formOperation = 0;
                                                  attributeOperation = 0;
                                                                      });
                                              }
                                                                    },
                                                      ),
                                                    ),
                                                  ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // 형태, 유형, 속성 검색 탭 (인라인으로 변경)
                                  Column(
                                    children: [
                                      // 커스텀 탭 바
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => setState(() => _selectedFeatureTabIndex = 0),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                  decoration: BoxDecoration(
                                                    color: _selectedFeatureTabIndex == 0 ? Theme.of(context).primaryColor : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    "형태",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: _selectedFeatureTabIndex == 0 ? Colors.white : Colors.grey[700],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => setState(() => _selectedFeatureTabIndex = 1),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                  decoration: BoxDecoration(
                                                    color: _selectedFeatureTabIndex == 1 ? Theme.of(context).primaryColor : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    "유형",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: _selectedFeatureTabIndex == 1 ? Colors.white : Colors.grey[700],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () => setState(() => _selectedFeatureTabIndex = 2),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                                  decoration: BoxDecoration(
                                                    color: _selectedFeatureTabIndex == 2 ? Theme.of(context).primaryColor : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    "속성",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: _selectedFeatureTabIndex == 2 ? Colors.white : Colors.grey[700],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 250,
                                        child: IndexedStack(
                                          index: _selectedFeatureTabIndex,
                                          children: [
                                            // 형태 탭
                                            _buildSearchResultsList(
                                              controller: formSearchController,
                                              results: formSearchResults,
                                              selectedItems: selectedForms,
                                              onItemSelected: (item) {
                                                setState(() {
                                                  selectedForms.add(item);
                                                });
                                              },
                                              onItemDeselected: (item) {
                                                setState(() {
                                                  selectedForms.remove(item);
                                                });
                                              },
                                              hint: "형태 검색",
                                              icon: Icons.badge_rounded,
                                              displayTransform: (item) => CardDataService().getDisplayFormName(item),
                                              onSearchChanged: (value) {
                                                setState(() {
                                                  formSearchResults = CardDataService().searchForms(value);
                                                });
                                              },
                                            ),
                                            // 유형 탭
                                            _buildSearchResultsList(
                                              controller: _trieSearchController!,
                                              results: searchResults,
                                              selectedItems: selectedTypes,
                                              onItemSelected: (item) {
                                                setState(() {
                                                  selectedTypes.add(item);
                                                });
                                              },
                                              onItemDeselected: (item) {
                                                setState(() {
                                                  selectedTypes.remove(item);
                                                });
                                              },
                                              hint: "유형 검색",
                                              icon: Icons.category_rounded,
                                              onSearchChanged: (value) {
                                                setState(() {
                                                  searchResults = CardDataService().searchTypes(value);
                                                });
                                              },
                                            ),
                                            // 속성 탭
                                            _buildSearchResultsList(
                                              controller: attributeSearchController,
                                              results: attributeSearchResults,
                                              selectedItems: selectedAttributes,
                                              onItemSelected: (item) {
                                                setState(() {
                                                  selectedAttributes.add(item);
                                                });
                                              },
                                              onItemDeselected: (item) {
                                                setState(() {
                                                  selectedAttributes.remove(item);
                                                });
                                              },
                                              hint: "속성 검색",
                                              icon: Icons.category_outlined,
                                              onSearchChanged: (value) {
                                                setState(() {
                                                  attributeSearchResults = CardDataService().searchAttributes(value);
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                                      ),
                                                    ),
                                                  ],
                        ),
                      ),
                    ),
                    
                    // 하단 액션 버튼
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        border: Border(top: BorderSide(color: Colors.grey[200]!)),
                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                  onPressed: () {
                                // 초기화 로직
                    selectedNote = all;
                                selectedColorMap.updateAll((key, value) => false);
                                selectedCardTypeMap.updateAll((key, value) => false);
                                selectedLvMap.updateAll((key, value) => false);
                                selectedRarityMap.updateAll((key, value) => false);
                    currentDpRange = const RangeValues(1000, 17000);
                    currentPlayCostRange = const RangeValues(0, 20);
                    currentDigivolutionCostRange = const RangeValues(0, 8);
                    parallelOption = 0;
                                                                 _dialogSearchStringEditingController!.clear();
                    _cardNameSearchController.clear();
                    _cardNoSearchController.clear();
                    _effectSearchController.clear();
                    _sourceEffectSearchController.clear();
                    enCardInclude = true;
                                selectedTypes.clear();
                                typeOperation = 1;
                                selectedForms.clear();
                                formOperation = 1;
                                selectedAttributes.clear();
                                attributeOperation = 1;
                    setState(() {});
                  },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                              icon: Icon(Icons.refresh_rounded, color: Colors.grey[600]),
                              label: Text(
                                "초기화",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                  onPressed: () {
                                // 기존 적용 로직
                    if (selectedNote != null) {
                      widget.searchParameter.noteId = selectedNote?.noteId;
                    }

                    widget.searchParameter.colors = selectedColorMap.entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toSet();

                    widget.searchParameter.cardTypes = selectedCardTypeMap
                        .entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toSet();

                    widget.searchParameter.lvs = selectedLvMap.entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toSet();

                    widget.searchParameter.rarities = selectedRarityMap.entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toSet();

                    widget.searchParameter.minDp = currentDpRange.start.round();
                    widget.searchParameter.maxDp = currentDpRange.end.round();
                    widget.searchParameter.minPlayCost =
                        currentPlayCostRange.start.round();
                    widget.searchParameter.maxPlayCost =
                        currentPlayCostRange.end.round();
                    widget.searchParameter.minDigivolutionCost =
                        currentDigivolutionCostRange.start.round();
                    widget.searchParameter.maxDigivolutionCost =
                        currentDigivolutionCostRange.end.round();
                    widget.searchParameter.searchString =
                        _dialogSearchStringEditingController?.value.text;
                    _searchStringEditingController?.text =
                        _dialogSearchStringEditingController!.value.text;
                    
                    widget.searchParameter.cardNameSearch =
                        _cardNameSearchController.text.isEmpty ? null : _cardNameSearchController.text;
                    widget.searchParameter.cardNoSearch =
                        _cardNoSearchController.text.isEmpty ? null : _cardNoSearchController.text;
                    widget.searchParameter.effectSearch =
                        _effectSearchController.text.isEmpty ? null : _effectSearchController.text;
                    widget.searchParameter.sourceEffectSearch =
                        _sourceEffectSearchController.text.isEmpty ? null : _sourceEffectSearchController.text;
                    
                    widget.searchParameter.parallelOption = parallelOption;
                    widget.searchParameter.isEnglishCardInclude = enCardInclude;
                    widget.searchParameter.typeOperation = typeOperation;
                    widget.searchParameter.types = selectedTypes;
                    widget.searchParameter.formOperation = formOperation;
                    widget.searchParameter.forms = selectedForms;
                    widget.searchParameter.attributeOperation = attributeOperation;
                    widget.searchParameter.attributes = selectedAttributes;

                    Navigator.pop(context);
                    widget.updateSearchParameter();

                    ToastOverlay.show(
                      context,
                      '검색 조건이 적용되었습니다.',
                      type: ToastType.info
                    );
                  },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.search_rounded, color: Colors.white),
                              label: const Text(
                                "적용",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  void resetSearchCondition(){
    _searchStringEditingController =
        TextEditingController(text: '');
    widget.searchParameter.reset();
    widget.updateSearchParameter();
    setState(() {});
  }

  Comparator<NoteDto> noteDtoComparator = (a, b) {
    if (a.releaseDate == null && b.releaseDate == null) {
      return a.name.compareTo(b.name);
    } else if (a.releaseDate == null) {
      return 1;
    } else if (b.releaseDate == null) {
      return -1;
    }

    int releaseDateComparison = b.releaseDate!.compareTo(a.releaseDate!);
    if (releaseDateComparison != 0) {
      return releaseDateComparison;
    }

    if (a.priority == null && b.priority == null) {
      return 0;
    } else if (a.priority == null) {
      return 1;
    } else if (b.priority == null) {
      return -1;
    }

    return b.priority!.compareTo(a.priority!);
  };

  List<DropdownMenuItem<NoteDto>> generateDropDownMenuItems() {
    List<NoteDto> boosterPackList = [];
    List<NoteDto> staterDeckList = [];
    List<NoteDto> boosterPromoList = [];
    List<NoteDto> starterPromoList = [];
    List<NoteDto> eventList = [];
    List<NoteDto> enList = [];
    List<NoteDto> etcList = [];

    for (var note in widget.notes) {
      switch (note.cardOrigin) {
        case 'BOOSTER_PACK':
          boosterPackList.add(note);
          break;
        case 'STARTER_DECK':
          staterDeckList.add(note);
          break;
        case 'BOOSTER_PROMO':
          boosterPromoList.add(note);
          break;
        case 'STARTER_PROMO':
          starterPromoList.add(note);
          break;
        case 'EVENT':
          eventList.add(note);
          break;
        case 'ENGLISH':
          enList.add(note);
          break;
        default:
          etcList.add(note);
      }
    }

    boosterPackList.sort(noteDtoComparator);
    staterDeckList.sort(noteDtoComparator);
    boosterPromoList.sort(noteDtoComparator);
    starterPromoList.sort(noteDtoComparator);
    eventList.sort(noteDtoComparator);
    etcList.sort(noteDtoComparator);

    List<DropdownMenuItem<NoteDto>> menuItems = [];

    menuItems.add(
      DropdownMenuItem<NoteDto>(
        value: all,
        child: Text(
          all.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
    menuItems.add(
      const DropdownMenuItem<NoteDto>(
        enabled: false,
        child: Divider(),
      ),
    );
    menuItems
        .addAll(_createMenuItemsWithHeaderAndDivider('부스터 팩', boosterPackList));
    menuItems
        .addAll(_createMenuItemsWithHeaderAndDivider('스타터 덱', staterDeckList));
    menuItems.addAll(
        _createMenuItemsWithHeaderAndDivider('부스터 프로모', boosterPromoList));
    menuItems.addAll(
        _createMenuItemsWithHeaderAndDivider('스타터 프로모', starterPromoList));
    menuItems.addAll(_createMenuItemsWithHeaderAndDivider('이벤트', eventList));
    menuItems.addAll(_createMenuItemsWithHeaderAndDivider('미발매 카드', enList));

    if (!etcList.isEmpty) {
      menuItems.addAll(_createMenuItemsWithHeaderAndDivider('기타', etcList));
    }

    return menuItems;
  }

  List<DropdownMenuItem<NoteDto>> _createMenuItemsWithHeaderAndDivider(
      String header, List<NoteDto> items) {
    List<DropdownMenuItem<NoteDto>> menuItems = [];

    menuItems.add(
      DropdownMenuItem<NoteDto>(
        enabled: false,
        child: Text(
          header,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );

    for (var item in items) {
      menuItems.add(
        DropdownMenuItem<NoteDto>(
          value: item,
          child: Text(item.name),
        ),
      );
    }

    if (items.isNotEmpty) {
      menuItems.add(
        const DropdownMenuItem<NoteDto>(
          enabled: false,
          child: Divider(),
        ),
      );
    }

    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    dropDownMenuItems = generateDropDownMenuItems();
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallHeight = screenHeight < 600; // 세로 높이가 작은 화면 감지
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final isMobile = screenWidth < 768; // 모바일 화면 감지
    final isVerySmall = screenWidth < 480; // 매우 작은 화면 감지

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isPortrait ? (isMobile ? 12 : 16) : (isMobile ? 16 : 20),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.05),
        //     blurRadius: 10,
        //     offset: const Offset(0, 2),
        //   ),
        // ],
      ),
      child: Row(
      children: [
          // 검색 텍스트 필드
        Expanded(
             flex: isMobile ? 6 : 5,
            child: Container(
              decoration: AppComponentStyles.cardDecoration(),
              child: TextField(
                controller: _searchStringEditingController,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                scrollPhysics: const BouncingScrollPhysics(),
                onChanged: (value) {
                  widget.searchParameter.searchString = value;
                  setState(() {}); // 테두리 색상 업데이트를 위해
                },
                onSubmitted: (value) {
                  widget.updateSearchParameter();
                },
                decoration: AppComponentStyles.searchFieldDecoration(
                  hintText: '카드명/효과/번호',
                  isMobile: isMobile,
                                 ).copyWith(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : 20,
                    vertical: isMobile ? 16 : 18,
                  ),
                   prefixIcon: Container(
                     margin: const EdgeInsets.all(8),
                     decoration: BoxDecoration(
                       color: AppColors.primary.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(AppRadius.small),
                     ),
                     child: Icon(
                       Icons.search_rounded,
                       size: isMobile ? 16 : (isSmallHeight ? 18 : 20),
                       color: AppColors.primary,
                     ),
                   ),
                   suffixIcon: _searchStringEditingController?.text.isNotEmpty == true
                     ? Container(
                         margin: const EdgeInsets.all(8),
                         child: Material(
                           color: AppColors.neutral400,
                           borderRadius: BorderRadius.circular(AppRadius.small),
                           child: InkWell(
                             borderRadius: BorderRadius.circular(AppRadius.small),
                             onTap: () {
                               _searchStringEditingController?.clear();
                               widget.searchParameter.searchString = '';
                               setState(() {});
                             },
                             child: Container(
                               padding: const EdgeInsets.all(4),
                               child: Icon(
                                 Icons.clear_rounded,
                                 size: isMobile ? 14 : (isSmallHeight ? 16 : 18),
                                 color: AppColors.textTertiary,
                               ),
                             ),
                           ),
                         ),
                       )
                     : null,
                 ),
                style: isMobile 
                  ? AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500)
                  : AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          
          SizedBox(width: isMobile ? 6 : 8),
          
          // 검색 버튼
          // if (!isVerySmall)
          //   _buildActionButton(
          //     icon: Icons.search_rounded,
          //     tooltip: '검색',
          //         onPressed: () {
          //           widget.updateSearchParameter();
          //         },
          //     isMobile: isMobile,
          //     isSmallHeight: isSmallHeight,
          //     style: AppComponentStyles.primaryButtonOutline(
          //       isMobile: isMobile,
          //       isSmall: isSmallHeight,
          //     ),
          //   ),
          
          if (!isVerySmall) SizedBox(width: isMobile ? 4 : 6),
          
        // 필터 버튼
          _buildActionButton(
            icon: Icons.tune_rounded,
            tooltip: '상세 필터',
                  onPressed: () {
                    _showFilterDialog();
                  },
            isMobile: isMobile,
            isSmallHeight: isSmallHeight,
            style: AppComponentStyles.secondaryButton(
              isMobile: isMobile,
              isSmall: isSmallHeight,
            ),
          ),
          
          SizedBox(width: isMobile ? 4 : 6),
          
          // 초기화 버튼
        if (!isVerySmall)
            _buildActionButton(
              icon: Icons.refresh_rounded,
                    tooltip: '초기화',
                    onPressed: () {
                      resetSearchCondition();
                      ToastOverlay.show(
                        context,
                        '검색 조건이 초기화되었습니다.',
                        type: ToastType.warning
                      );
                    },
              isMobile: isMobile,
              isSmallHeight: isSmallHeight,
              style: AppComponentStyles.warningButton(
                isMobile: isMobile,
                isSmall: isSmallHeight,
              ),
            ),
          
          if (!isVerySmall) SizedBox(width: isMobile ? 4 : 6),
          
        // 뷰 모드 전환 버튼
        if (widget.viewMode != null)
            _buildActionButton(
              icon: widget.viewMode == 'grid' 
                ? Icons.view_list_rounded 
                : Icons.grid_view_rounded,
              tooltip: widget.viewMode == 'grid' ? '리스트 뷰' : '그리드 뷰',
                onPressed: () {
                  if (widget.onViewModeChanged != null) {
                    widget.onViewModeChanged!(
                      widget.viewMode == 'grid' ? 'list' : 'grid',
                    );
                  }
                },
              isMobile: isMobile,
              isSmallHeight: isSmallHeight,
              style: AppComponentStyles.accentButton(
                isMobile: isMobile,
                isSmall: isSmallHeight,
              ),
            ),
        ],
      ),
    );
  }

  // 🎨 새로운 디자인 시스템을 적용한 액션 버튼
  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isMobile,
    required bool isSmallHeight,
    required ButtonStyle style,
  }) {
    final buttonSize = isMobile ? 44.0 : (isSmallHeight ? 48.0 : 52.0);
    final iconSize = isMobile ? 20.0 : (isSmallHeight ? 22.0 : 24.0);
    
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style.copyWith(
          minimumSize: MaterialStateProperty.all(Size(buttonSize, buttonSize)),
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
          ),
        ),
        child: Tooltip(
          message: tooltip,
          child: Icon(
            icon,
            size: iconSize,
          ),
        ),
      ),
    );
  }

  // 검색 섹션을 생성하는 헬퍼 메서드
  Widget _buildSearchSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  // 확장 가능한 섹션을 생성하는 헬퍼 메서드
  Widget _buildExpandableSection({
    required String title,
    required IconData icon,
    bool isExpanded = false,
    VoidCallback? onToggle,
    required Widget child,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) child,
      ],
    );
  }

  // 상세 검색 필드를 생성하는 헬퍼 메서드
  Widget _buildDetailedSearchField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

     // 필터 칩을 생성하는 헬퍼 메서드
   Widget _buildFilterChip({
     required String label,
     bool isSelected = false,
     Function(bool)? onSelected,
   }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[100],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[800],
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 1.5,
        ),
      ),
    );
  }

     // 색상 칩을 생성하는 헬퍼 메서드
   Widget _buildColorChip({
     required String color,
     required String label,
     bool isSelected = false,
     Function(bool)? onSelected,
   }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: ColorService.getColorFromString(color.toUpperCase()),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[100],
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).primaryColor : Colors.grey[800],
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          width: 1.5,
        ),
      ),
    );
  }

  // 범위 선택 섹션을 생성하는 헬퍼 메서드
     Widget _buildRangeSection({
     required String title,
     required IconData icon,
     required RangeValues currentRange,
     double min = 0,
     double max = 100,
     int divisions = 10,
     ValueChanged<RangeValues>? onChanged,
   }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        RangeSlider(
          values: currentRange,
          min: min,
          max: max,
          divisions: divisions,
          labels: RangeLabels(
            currentRange.start.round().toString(),
            currentRange.end.round().toString(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // 검색 결과 목록을 표시하는 위젯
  Widget _buildSearchResultsList({
    required TextEditingController controller,
    required Set<String> results,
    required Set<String> selectedItems,
    required ValueChanged<String> onItemSelected,
    required ValueChanged<String> onItemDeselected,
    required String hint,
    required IconData icon,
    String Function(String)? displayTransform,
    ValueChanged<String>? onSearchChanged,
  }) {
    return Column(
      children: [
        // 검색 필드
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
              prefixIcon: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // 결과 리스트 (고정 높이)
        Container(
          height: 180, // 고정 높이로 사이즈 문제 해결
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 검색 결과 (왼쪽)
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '검색 결과',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: results.isEmpty
                          ? Center(
                              child: Text(
                                '검색 결과 없음',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final item = results.elementAt(index);
                                final isSelected = selectedItems.contains(item);
                                final displayLabel = displayTransform?.call(item) ?? item;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  child: _buildFilterChip(
                                    label: displayLabel,
                                    isSelected: isSelected,
                                    onSelected: (selected) {
                                      if (selected) {
                                        onItemSelected(item);
                                      } else {
                                        onItemDeselected(item);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // 선택된 항목 (오른쪽)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '선택된 항목',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: selectedItems.isEmpty
                          ? Center(
                              child: Text(
                                '선택된 항목 없음',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(8),
                              child: Wrap(
                                runSpacing: 4,
                                spacing: 4,
                                children: selectedItems
                                    .map((item) => MarqueeChip(
                                          label: displayTransform?.call(item) ?? item,
                                          deleteButtonTooltipMessage: '제거',
                                          onDeleted: () => onItemDeselected(item),
                                          labelStyle: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                          labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        ))
                                    .toList(),
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
