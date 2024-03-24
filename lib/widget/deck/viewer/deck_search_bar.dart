import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/deck_search_parameter.dart';
import '../../../model/format.dart';
import '../../../service/color_service.dart';

class DeckSearchBar extends StatefulWidget {
  final List<FormatDto> formatList;
  final DeckSearchParameter searchParameter;
  final Function(int) search;
  const DeckSearchBar({super.key, required this.formatList, required this.searchParameter, required this.search});

  @override
  State<DeckSearchBar> createState() => _DeckSearchBarState();
}

class _DeckSearchBarState extends State<DeckSearchBar> {
  FormatDto? _selectedFormat;


  List<String> colors = ["RED","BLUE","YELLOW","GREEN","BLACK","PURPLE","WHITE"];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedFormat=widget.formatList.first;
    for (var format in widget.formatList) {
      if(!format.isOnlyEn!) {
        _selectedFormat =format;
        break;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    double fontSize = min(MediaQuery.sizeOf(context).width*0.009,15);
    if(isPortrait) {
      fontSize*=2;
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
                  hint: Text(_selectedFormat == null
                      ? '포맷'
                      : '${_selectedFormat!.name} ['
                      '${DateFormat('yyyy-MM-dd').format(_selectedFormat!.startDate)} ~ '
                      '${DateFormat('yyyy-MM-dd').format(_selectedFormat!.endDate)}]',
                    style: TextStyle(fontSize:fontSize),
                  ),
                  value: _selectedFormat,
                  items: [
                    DropdownMenuItem<FormatDto>(
                      child: Text('일반 포맷', style: TextStyle(fontWeight: FontWeight.bold)),
                      enabled: false,
                    ),
                    ...widget.formatList
                        .where((format) => format.isOnlyEn == false)
                        .map((format) {
                      return DropdownMenuItem<FormatDto>(
                        value: format,
                        child: Text(
                          '${format.name} ['
                              '${DateFormat('yyyy-MM-dd').format(format.startDate)} ~ '
                              '${DateFormat('yyyy-MM-dd').format(format.endDate)}]',
                          style: TextStyle(fontSize: fontSize),
                        ),
                      );
                    }).toList(),
                    DropdownMenuItem<FormatDto>(
                      child: Text('영어 전용 포맷', style: TextStyle(fontWeight: FontWeight.bold)),
                      enabled: false,
                    ),
                    ...widget.formatList
                        .where((format) => format.isOnlyEn == true)
                        .map((format) {
                      return DropdownMenuItem<FormatDto>(
                        value: format,
                        child: Text(
                          '${format.name} ['
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
                      widget.search(1);
                    });
                  },
                ),
              ),
            ),
            Expanded(flex: 1, child: Container()),
            Expanded(
              flex: 3,
              child: TextField(
                style: TextStyle(fontSize: fontSize),
                decoration:InputDecoration(
                  labelText: '검색어',
                  labelStyle:  TextStyle(fontSize: fontSize),
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
              child: TextButton(onPressed: (){
                widget.search(1);
              }, child: Text('검색',
                style: TextStyle(fontSize: fontSize),

              )),
            )
          ],
        ),
        SizedBox(height:fontSize),
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [...List.generate(
              colors.length,
                  (index) {
                String color = colors[index];
                Color buttonColor = ColorService().getColorFromString(color);

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
                    width: MediaQuery.sizeOf(context).width*0.02,
                    height: MediaQuery.sizeOf(context).width*0.02,
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
              Text('OR',
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
              Text('AND',
                style: TextStyle(fontSize: fontSize),
              ),
            ]
        ),
      ],
    );
  }
}
