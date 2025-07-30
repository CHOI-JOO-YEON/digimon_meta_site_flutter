import 'dart:math';

import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:digimon_meta_site_flutter/theme/app_design_system.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../model/deck_search_parameter.dart';
import '../../../model/format.dart';
import '../../../provider/format_deck_count_provider.dart';
import '../../../service/color_service.dart';

class DeckSearchBar extends StatefulWidget {
  final bool isMyDeck;
  final List<FormatDto> formatList;
  final DeckSearchParameter searchParameter;
  final FormatDto selectedFormat;
  final Function(FormatDto) updateSelectFormat;
  final Function(int) search;
  final int? totalResults;

  const DeckSearchBar(
      {super.key,
      required this.formatList,
      required this.searchParameter,
      required this.search,
      required this.selectedFormat,
      required this.updateSelectFormat,
      required this.isMyDeck,
      this.totalResults});

  @override
  State<DeckSearchBar> createState() => _DeckSearchBarState();
}

class _DeckSearchBarState extends State<DeckSearchBar> {
  FormatDto? _selectedFormat;
  late TextEditingController _searchController;

  List<String> colors = [
    "RED",
    "BLUE",
    "YELLOW",
    "GREEN",
    "BLACK",
    "PURPLE",
    "WHITE"
  ];

  @override
  void initState() {
    super.initState();
    _selectedFormat = widget.selectedFormat;
    _searchController = TextEditingController(text: widget.searchParameter.searchString);
  }

  @override
  void didUpdateWidget(DeckSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchParameter.searchString != _searchController.text) {
      _searchController.text = widget.searchParameter.searchString;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  void _clearAllFilters() {
    setState(() {
      widget.searchParameter.searchString = '';
      widget.searchParameter.colors.clear();
      widget.searchParameter.colors.addAll([
        "RED", "BLUE", "YELLOW", "GREEN", "BLACK", "PURPLE", "WHITE"
      ]);
      widget.searchParameter.colorOperation = 0;
      _searchController.clear();
    });
  }

  void _showAdvancedFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                                  "고급 검색 필터",
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
                    
                    // 컨텐츠
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAdvancedFilterContent(setDialogState, true),
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
                                _clearAllFilters();
                                widget.search(1);
                                Navigator.of(context).pop();
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
                                widget.search(1);
                                Navigator.of(context).pop();
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

  bool _hasActiveFilters() {
    return widget.searchParameter.searchString.isNotEmpty ||
           widget.searchParameter.colors.length != colors.length ||
           widget.searchParameter.colorOperation != 0;
  }


  Widget _buildAdvancedFilterContent(StateSetter setFilterState, bool isDialog) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 포맷 선택 섹션
        _buildSearchSection(
          title: "포맷",
          icon: Icons.category_rounded,
          child: Consumer<FormatDeckCountProvider>(
            builder: (context, deckCountProvider, child) {
              String selectedDeckCountStr = '';
              if (_selectedFormat != null) {
                final selectedDeckCount = deckCountProvider.getFormatDeckCount(
                  _selectedFormat!.formatId,
                  widget.isMyDeck,
                );
                selectedDeckCountStr =
                selectedDeckCount > 99 ? ' (99+)' : ' ($selectedDeckCount)';
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<FormatDto>(
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600]),
                    hint: Text(
                      _selectedFormat?.name ?? "포맷 선택",
                      style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                    ),
                    value: _selectedFormat,
                    items: [
                      const DropdownMenuItem<FormatDto>(
                        enabled: false,
                        child: Text(
                          '일반 포맷',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...widget.formatList
                          .where((format) => format.isOnlyEn == false)
                          .map((format) {
                        final deckCount = deckCountProvider
                            .getFormatDeckCount(format.formatId, widget.isMyDeck);
                        final deckCountStr = deckCount > 99 ? '99+' : '$deckCount';

                        return DropdownMenuItem<FormatDto>(
                          value: format,
                          child: dropDownFormatItem(format, 14.0, deckCountStr)
                        );
                      }),
                      const DropdownMenuItem<FormatDto>(
                        enabled: false,
                        child: Text(
                          '미발매 포맷 [예상 발매 일정]',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...widget.formatList
                          .where((format) => format.isOnlyEn == true)
                          .toList()
                          .reversed
                          .map((format) {
                        final deckCount = deckCountProvider
                            .getFormatDeckCount(format.formatId, widget.isMyDeck);
                        final deckCountStr = deckCount > 99 ? '99+' : '$deckCount';

                        return DropdownMenuItem<FormatDto>(
                          value: format,
                          child: dropDownFormatItem(format, 14.0, deckCountStr)
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setFilterState(() {
                        _selectedFormat = value;
                        widget.searchParameter.formatId = value?.formatId;
                        widget.updateSelectFormat(_selectedFormat!);
                        if (!isDialog) widget.search(1);
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 색상 필터 섹션
        _buildSearchSection(
          title: "색상",
          icon: Icons.palette_rounded,
          child: Column(
            children: [
              // 색상 선택
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  colors.length,
                  (index) {
                    String color = colors[index];
                    bool isSelected = widget.searchParameter.colors.contains(color);

                    return _buildColorChip(
                      color: color,
                      label: _getKoreanColorName(color),
                      isSelected: isSelected,
                      onSelected: (selected) {
                        setFilterState(() {
                          if (selected) {
                            widget.searchParameter.colors.add(color);
                          } else {
                            widget.searchParameter.colors.remove(color);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 색상 조건 선택
              Text(
                '색상 조건',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setFilterState(() {
                            widget.searchParameter.colorOperation = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: widget.searchParameter.colorOperation == 0 ? Theme.of(context).primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "하나라도 포함",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: widget.searchParameter.colorOperation == 0 ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setFilterState(() {
                            widget.searchParameter.colorOperation = 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: widget.searchParameter.colorOperation == 1 ? Theme.of(context).primaryColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "모두 포함",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: widget.searchParameter.colorOperation == 1 ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
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
        
        const SizedBox(height: 24),
        
        // 유효한 덱만 보기 섹션
        _buildSearchSection(
          title: "필터 옵션",
          icon: Icons.filter_alt_rounded,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '유효한 덱만 보기',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Switch(
                value: widget.isMyDeck
                    ? widget.searchParameter.isOnlyValidDeckMy
                    : widget.searchParameter.isOnlyValidDeckAll,
                onChanged: (value) {
                  setFilterState(() {
                    if (widget.isMyDeck) {
                      widget.searchParameter.isOnlyValidDeckMy = value;
                    } else {
                      widget.searchParameter.isOnlyValidDeckAll = value;
                    }
                    if (!isDialog) widget.search(1);
                  });
                },
                activeColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ],
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
              color: ColorService.getColorFromString(color),
              borderRadius: BorderRadius.circular(6),
              border: color == "WHITE" ? Border.all(color: Colors.grey[400]!) : null,
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

  // 색상 이름을 한글로 변환하는 헬퍼 메서드
  String _getKoreanColorName(String color) {
    switch (color) {
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
        return color;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallHeight = screenHeight < 600;
    final isMobile = screenWidth < 768;
    final isVerySmall = screenWidth < 480;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 12,
        vertical: isPortrait ? (isMobile ? 8 : 12) : (isMobile ? 12 : 16),
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
      ),
      child: Row(
        children: [
          // 검색 텍스트 필드
          Expanded(
            flex: isMobile ? 6 : 5,
            child: Container(
              decoration: AppComponentStyles.cardDecoration(),
              child: TextField(
                controller: _searchController,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                scrollPhysics: const BouncingScrollPhysics(),
                onChanged: (value) {
                  widget.searchParameter.searchString = value;
                },
                onSubmitted: (value) {
                  widget.searchParameter.searchString = value;
                  widget.search(1);
                },
                decoration: AppComponentStyles.searchFieldDecoration(
                  hintText: '검색어',
                  isMobile: isMobile,
                ).copyWith(
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
                  suffixIcon: _searchController.text.isNotEmpty
                    ? Container(
                        margin: const EdgeInsets.all(8),
                        child: Material(
                          color: AppColors.neutral400,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.small),
                            onTap: () {
                              _searchController.clear();
                              widget.searchParameter.searchString = '';
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
          
          // 결과 수 표시
          if (widget.totalResults != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.format_list_numbered,
                    size: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.totalResults}',
                    style: TextStyle(
                      fontSize: SizeService.smallFontSize(context) * 0.9,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: isMobile ? 4 : 6),
          ],
          
          // 검색 버튼
          if (!isVerySmall)
            _buildActionButton(
              icon: Icons.search_rounded,
              tooltip: '검색',
              onPressed: () {
                widget.search(1);
              },
              isMobile: isMobile,
              isSmallHeight: isSmallHeight,
              style: AppComponentStyles.primaryButtonOutline(
                isMobile: isMobile,
                isSmall: isSmallHeight,
              ),
            ),
          
          if (!isVerySmall) SizedBox(width: isMobile ? 4 : 6),
          
          // 필터 버튼
          _buildActionButton(
            icon: Icons.tune_rounded,
            tooltip: '고급 검색 필터',
            onPressed: () {
              _showAdvancedFilterDialog(context);
            },
            isMobile: isMobile,
            isSmallHeight: isSmallHeight,
            style: AppComponentStyles.secondaryButton(
              isMobile: isMobile,
              isSmall: isSmallHeight,
            ),
          ),
          
          SizedBox(width: isMobile ? 4 : 6),
          
          // 필터 초기화 버튼 (활성 필터가 있을 때만 표시)
          if (_hasActiveFilters() && !isVerySmall)
            _buildActionButton(
              icon: Icons.refresh_rounded,
              tooltip: '필터 초기화',
              onPressed: () {
                _clearAllFilters();
                widget.search(1);
              },
              isMobile: isMobile,
              isSmallHeight: isSmallHeight,
              style: AppComponentStyles.warningButton(
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
    final buttonSize = isMobile ? 36.0 : (isSmallHeight ? 40.0 : 44.0);
    final iconSize = isMobile ? 16.0 : (isSmallHeight ? 18.0 : 20.0);
    
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

  Widget dropDownFormatItem(FormatDto formatDto, double fontSize, String selectedDeckCountStr)
  {
    String formatDateRange(DateTime startDate, DateTime endDate) {
      final dateFormat = DateFormat('yyyy-MM-dd');
      return '${dateFormat.format(startDate)} ~ ${dateFormat.format(endDate)}';
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: fontSize, color: Colors.black, fontFamily: 'JalnanGothic',),
        children:  [
          TextSpan(text: '${formatDto.name} ($selectedDeckCountStr개의 덱)\n'),
          TextSpan(
            text: '[${formatDateRange(formatDto.startDate, formatDto.endDate)}]',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
