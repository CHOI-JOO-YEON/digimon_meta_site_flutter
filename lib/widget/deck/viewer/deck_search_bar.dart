import 'dart:math';

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
    // TODO: implement initState
    super.initState();

    _selectedFormat = widget.selectedFormat;
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
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double fontSize = min(MediaQuery.sizeOf(context).width * 0.009, 15);
    double iconSize = MediaQuery.sizeOf(context).width * 0.02;
    if (isPortrait) {
      fontSize *= 2;
      iconSize *= 2;
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child:  Consumer<FormatDeckCountProvider>(
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
                      hint: _selectedFormat==null?Text('포맷', style: TextStyle(fontSize: fontSize),): 
                          dropDownFormatItem(_selectedFormat!, fontSize, selectedDeckCountStr),
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
                              child: dropDownFormatItem(format, fontSize, deckCountStr)
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
                            child: dropDownFormatItem(format, fontSize, deckCountStr)
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
            // Expanded(flex: 1, child: ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => _showDeckSettingDialog(context),
              iconSize: fontSize,
              icon: const Icon(Icons.settings),
              tooltip: '검색 설정',
            ),
            Expanded(
              flex: 3,
              child: TextField(
                style: TextStyle(fontSize: fontSize),
                decoration: InputDecoration(
                  labelText: '검색어',
                  labelStyle: TextStyle(fontSize: fontSize),
                ),
                onChanged: (value) {
                  setState(() {
                    widget.searchParameter.searchString = value;
                  });
                },
                onSubmitted: (value) {
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
                    style: TextStyle(fontSize: fontSize),
                  )),
            )
          ],
        ),
        SizedBox(height: fontSize),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
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
                  width: iconSize,
                  height: iconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.searchParameter.colors.contains(color)
                        ? buttonColor
                        : buttonColor.withOpacity(0.3),
                  ),
                ),
              );
            },
          ),
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
            'OR',
            style: TextStyle(fontSize: fontSize),
          ),
          SizedBox(width: fontSize),
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
            'AND',
            style: TextStyle(fontSize: fontSize),
          ),
        ]),
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
