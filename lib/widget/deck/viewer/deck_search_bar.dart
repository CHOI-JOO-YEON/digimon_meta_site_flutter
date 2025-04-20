import 'dart:math';

import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../model/deck_search_parameter.dart';
import '../../../model/format.dart';
import '../../../model/limit_dto.dart';
import '../../../provider/format_deck_count_provider.dart';
import '../../../provider/limit_provider.dart';
import '../../../service/color_service.dart';

class DeckSearchBar extends StatefulWidget {
  final bool isMyDeck;
  final List<FormatDto> formatList;
  final DeckSearchParameter searchParameter;
  final FormatDto selectedFormat;
  final Function(FormatDto) updateSelectFormat;
  final Function(int) search;

  const DeckSearchBar(
      {super.key,
      required this.formatList,
      required this.searchParameter,
      required this.search,
      required this.selectedFormat,
      required this.updateSelectFormat,
      required this.isMyDeck});

  @override
  State<DeckSearchBar> createState() => _DeckSearchBarState();
}

class _DeckSearchBarState extends State<DeckSearchBar> {
  FormatDto? _selectedFormat;
  late TextEditingController _searchController;
  bool _isAdvancedOptionsExpanded = false;

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

  void _showDeckSettingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LimitProvider>(
          builder: (context, limitProvider, child) {
            LimitDto? selectedLimit = limitProvider.selectedLimit;
            bool isChecked = widget.isMyDeck
                ? widget.searchParameter.isOnlyValidDeckMy
                : widget.searchParameter.isOnlyValidDeckAll;

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        if (widget.isMyDeck) {
                          widget.searchParameter.isOnlyValidDeckMy = isChecked;
                        } else {
                          widget.searchParameter.isOnlyValidDeckAll = isChecked;
                        }
                        if (selectedLimit != null) {
                          limitProvider.updateSelectLimit(
                              selectedLimit!.restrictionBeginDate);
                        }
                        widget.search(1);
                        Navigator.of(context).pop();
                      },
                      child: const Text('적용'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('취소'),
                    ),
                  ],
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            '금지/제한: ',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: DropdownButtonFormField<LimitDto>(
                              value: selectedLimit,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedLimit = newValue;
                                });
                              },
                              items:
                                  limitProvider.limits.values.map((limitDto) {
                                return DropdownMenuItem<LimitDto>(
                                  value: limitDto,
                                  child: Text(
                                    '${DateFormat('yyyy-MM-dd').format(limitDto.restrictionBeginDate)}',
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '유효한 덱만 보기',
                            style: TextStyle(fontSize: 20),
                          ),
                          Switch(
                            inactiveThumbColor: Colors.red,
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Column(
      children: [
        // 검색 필드 (항상 표시)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _searchController,
                style: TextStyle(fontSize: SizeService.smallFontSize(context)),
                decoration: InputDecoration(
                  labelText: '검색어',
                  labelStyle: TextStyle(
                    fontSize: SizeService.smallFontSize(context),
                    color: Theme.of(context).primaryColor.withOpacity(0.7),
                  ),
                  prefixIcon: const Icon(Icons.search),
                  hintStyle: TextStyle(
                    fontSize: SizeService.smallFontSize(context),
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                ),
                onChanged: (value) {
                  widget.searchParameter.searchString = value;
                },
                onSubmitted: (value) {
                  widget.searchParameter.searchString = value;
                  widget.search(1);
                },
              ),
            ),
            Expanded(
              flex: 1,
              child: TextButton(
                onPressed: () {
                  widget.search(1);
                },
                child: Text(
                  '검색',
                  style: TextStyle(fontSize: SizeService.smallFontSize(context)),
                )
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _isAdvancedOptionsExpanded = !_isAdvancedOptionsExpanded;
                });
              },
              iconSize: SizeService.mediumIconSize(context),
              icon: Icon(_isAdvancedOptionsExpanded ? Icons.expand_less : Icons.expand_more),
              tooltip: '고급 검색 옵션',
            ),
          ],
        ),
        
        // 고급 검색 옵션 (확장/축소 가능)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isAdvancedOptionsExpanded ? (isPortrait ? 200 : 150) : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 8),
                // 포맷 선택
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
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

                          return DropdownButtonHideUnderline(
                            child: DropdownButton<FormatDto>(
                              isExpanded: true,
                              hint: _selectedFormat==null?Text('포맷', style: TextStyle(fontSize: SizeService.smallFontSize(context)),): 
                                  dropDownFormatItem(_selectedFormat!, SizeService.smallFontSize(context), selectedDeckCountStr),
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
                                      child: dropDownFormatItem(format, SizeService.smallFontSize(context), deckCountStr)
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
                                    child: dropDownFormatItem(format, SizeService.smallFontSize(context), deckCountStr)
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedFormat = value;
                                  widget.searchParameter.formatId = value?.formatId;
                                  widget.updateSelectFormat(_selectedFormat!);
                                  widget.search(1);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showDeckSettingDialog(context),
                      iconSize: SizeService.mediumIconSize(context),
                      icon: const Icon(Icons.settings),
                      tooltip: '검색 설정',
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 색상 선택
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround, 
                  children: [
                    ...List.generate(
                      colors.length,
                      (index) {
                        String color = colors[index];
                        Color buttonColor = ColorService.getColorFromString(color);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (widget.searchParameter.colors.contains(color)) {
                                widget.searchParameter.colors.remove(color);
                              } else {
                                widget.searchParameter.colors.add(color);
                              }
                            });
                          },
                          child: Container(
                            width: SizeService.mediumIconSize(context) * 1.5,
                            height: SizeService.mediumIconSize(context) * 1.5,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.searchParameter.colors.contains(color)
                                  ? buttonColor
                                  : buttonColor.withOpacity(0.3),
                              border: Border.all(
                                color: widget.searchParameter.colors.contains(color)
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 1,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // OR/AND 선택
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio(
                      value: 0,
                      groupValue: widget.searchParameter.colorOperation,
                      onChanged: (value) {
                        setState(() {
                          widget.searchParameter.colorOperation = value as int;
                        });
                      },
                    ),
                    Text(
                      '하나라도 포함',
                      style: TextStyle(fontSize: SizeService.smallFontSize(context)),
                    ),
                    SizedBox(width: SizeService.smallFontSize(context)),
                    Radio(
                      value: 1,
                      groupValue: widget.searchParameter.colorOperation,
                      onChanged: (value) {
                        setState(() {
                          widget.searchParameter.colorOperation = value as int;
                        });
                      },
                    ),
                    Text(
                      '모두 포함',
                      style: TextStyle(fontSize: SizeService.smallFontSize(context)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
