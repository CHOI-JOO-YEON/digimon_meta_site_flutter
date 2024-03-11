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
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<FormatDto>(
                  isExpanded: true,
                  hint: Text(_selectedFormat == null
                      ? '포맷'
                      : '${_selectedFormat!.name} ['
                      '${DateFormat('yyyy-MM-dd').format(_selectedFormat!.startDate)} ~ '
                      '${DateFormat('yyyy-MM-dd').format(_selectedFormat!.endDate)}]'),
                  value: _selectedFormat,
                  items: widget.formatList.map((FormatDto format) {
                    return DropdownMenuItem<FormatDto>(
                      value: format,
                      child: Text('${format!.name} ['
                          '${DateFormat('yyyy-MM-dd').format(format!.startDate)} ~ '
                          '${DateFormat('yyyy-MM-dd').format(format!.endDate)}]'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value;
                      widget.searchParameter.formatId = value?.formatId;
                    });
                  },
                ),
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  labelText: '검색어',
                ),
                onChanged: (value) {
                  setState(() {
                    widget.searchParameter.searchString = value;
                  });
                },
              ),
            ),
            ElevatedButton(onPressed: (){
              widget.search(1);
            }, child: Text('검색'))
          ],
        ),
        SizedBox(height: 10,),
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
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.searchParameter.colors.contains(color)
                          ? buttonColor
                          : buttonColor.withOpacity(0.3),
                      border: Border.all(
                        color: widget.searchParameter.colors.contains(color)
                            ? Colors.black
                            : buttonColor.withOpacity(0.3),
                        width: 2.0,
                      ),
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
              Text('OR'),
              SizedBox(width: 16.0),
              Radio(
                value: 1,
                groupValue: widget.searchParameter.colorOperation,
                onChanged: (value) {
                  setState(() {
                    widget.searchParameter.colorOperation = value as int;
                  });
                },
              ),
              Text('AND'),
            ]
        ),
      ],
    );
  }
}
