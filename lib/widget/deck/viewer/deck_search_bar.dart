import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../model/deck_search_parameter.dart';
import '../../../model/format.dart';
import '../../../model/limit_dto.dart';
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
      required this.search, required this.selectedFormat, required this.updateSelectFormat, required this.isMyDeck});

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
            bool isChecked = widget.isMyDeck?widget.searchParameter.isOnlyValidDeckMy: widget.searchParameter.isOnlyValidDeckAll;

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        if(widget.isMyDeck) {
                          widget.searchParameter.isOnlyValidDeckMy=isChecked;
                        }else{
                          widget.searchParameter.isOnlyValidDeckAll=isChecked;
                        }
                        if (selectedLimit != null) {
                          limitProvider.updateSelectLimit(
                              selectedLimit!.restrictionBeginDate);
                        }
                        widget.search(1);
                        Navigator.of(context).pop();
                      },
                      child: Text('적용'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('취소'),
                    ),
                  ],
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            '금지/제한: ',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(
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
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
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
      iconSize *=2;
    }
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<FormatDto>(
                  isExpanded: true,
                  hint: Text(
                    _selectedFormat == null
                        ? '포맷'
                        : '${_selectedFormat!.name} \n['
                            '${DateFormat('yyyy-MM-dd').format(_selectedFormat!.startDate)} ~ '
                            '${DateFormat('yyyy-MM-dd').format(_selectedFormat!.endDate)}]',
                    style: TextStyle(fontSize: fontSize),
                    // overflow: TextOverflow.ellipsis,
                  ),
                  value: _selectedFormat,
                  items: [
                    DropdownMenuItem<FormatDto>(
                      child: Text('일반 포맷',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      enabled: false,
                    ),
                    ...widget.formatList
                        .where((format) => format.isOnlyEn == false)
                        .map((format) {
                      return DropdownMenuItem<FormatDto>(
                        value: format,
                        child: Text(
                          '${format.name} \n['
                          '${DateFormat('yyyy-MM-dd').format(format.startDate)} ~ '
                          '${DateFormat('yyyy-MM-dd').format(format.endDate)}]',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      );
                    }).toList(),
                    DropdownMenuItem<FormatDto>(
                      child: Text('미발매 포맷 [예상 발매 일정]',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      enabled: false,
                    ),
                    ...widget.formatList
                        .where((format) => format.isOnlyEn == true)
                        .toList()
                        .reversed
                        .map((format) {
                      return DropdownMenuItem<FormatDto>(
                        value: format,
                        child: Text(
                          '${format.name} \n['
                          '${DateFormat('yyyy-MM-dd').format(format.startDate)} ~ '
                          '${DateFormat('yyyy-MM-dd').format(format.endDate)}]',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      );
                    }).toList(),
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
}
