import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:flutter/material.dart';

import '../../model/note.dart';

class CardSearchBar extends StatefulWidget {
  final SearchParameter searchParameter;
  final List<NoteDto> notes;
  final VoidCallback onSearch;

  const CardSearchBar(
      {super.key,
      required this.onSearch,
      required this.searchParameter,
      required this.notes});

  @override
  State<CardSearchBar> createState() => _CardSearchBarState();
}

class _CardSearchBarState extends State<CardSearchBar> {
  TextEditingController? _searchStringEditingController;
  TextEditingController? _dialogSearchStringEditingController;
  final List<String> colors = [
    'red',
    'blue',
    'yellow',
    'green',
    'black',
    'purple',
    'white'
  ];
  final List<String> cardTypes = ['TAMER', 'OPTION', 'DIGIMON', 'DIGITAMA'];
  final List<String> rarities = ['C', 'U', 'R', 'SR', 'SEC', 'P'];
  final List<int> levels = [0, 2, 3, 4, 5, 6, 7];


  @override
  void initState() {
    super.initState();
    _searchStringEditingController =
        TextEditingController(text: widget.searchParameter.searchString);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (_searchStringEditingController != null) {
      _searchStringEditingController!.dispose();
    }
    if(_dialogSearchStringEditingController!=null) {
      _dialogSearchStringEditingController!.dispose();
    }

    super.dispose();
  }

  void _showFilterDialog() {
    NoteDto? selectedNote;
    for (var note in widget.notes) {
      if (note.noteId == widget.searchParameter.noteId) {
        selectedNote = note;
        break;
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

    RangeValues currentDpRange = RangeValues(widget.searchParameter.minDp as double, widget.searchParameter.maxDp as double);

    RangeValues currentPlayCostRange = RangeValues(widget.searchParameter.minPlayCost as double, widget.searchParameter.maxPlayCost as double);
    RangeValues currentDigivolutionCostRange = RangeValues(widget.searchParameter.minDigivolutionCost as double, widget.searchParameter.maxDigivolutionCost as double);

    _dialogSearchStringEditingController = TextEditingController(text: _searchStringEditingController?.value.text);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("세부 검색 조건"),
              content: Column(
                mainAxisSize: MainAxisSize.min, // 컬럼 크기를 내용에 맞게 조절
                children: [
                  DropdownButton<NoteDto>(
                    value: selectedNote,
                    hint: Text(selectedNote?.name ?? "입수처"),
                    items: widget.notes.map((NoteDto note) {
                      return DropdownMenuItem<NoteDto>(
                        value: note,
                        child: Text(note.name),
                      );
                    }).toList(),
                    onChanged: (NoteDto? newValue) {
                      setState(() {
                        selectedNote = newValue;
                      });
                    },
                  ),
                  //lv 고르기
                  Text('LV'),
                  Wrap(
                    spacing: 8.0, // 가로 간격
                    children: selectedLvMap.keys.map((lv) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: selectedLvMap[lv] ?? false,
                            onChanged: (bool? newValue) {
                              setState(() {
                                selectedLvMap[lv] = newValue!;
                              });
                            },
                          ),
                          Text('$lv'),
                        ],
                      );
                    }).toList(),
                  ),
                  //색 고르기
                  Text('color'),
                  Wrap(
                    spacing: 8.0, // 가로 간격
                    children: selectedColorMap.keys.map((color) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: selectedColorMap[color] ?? false,
                            onChanged: (bool? newValue) {
                              setState(() {
                                selectedColorMap[color] = newValue!;
                              });
                            },
                          ),
                          Text(color),
                        ],
                      );
                    }).toList(),
                  ),
                  //색 or/and

                  //카드 타입 고르기
                  Text('Card Type'),
                  Wrap(
                    spacing: 8.0, // 가로 간격
                    children: selectedCardTypeMap.keys.map((cardType) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: selectedCardTypeMap[cardType] ?? false,
                            onChanged: (bool? newValue) {
                              setState(() {
                                selectedCardTypeMap[cardType] = newValue!;
                              });
                            },
                          ),
                          Text(cardType),
                        ],
                      );
                    }).toList(),
                  ),
                  //레어도 고르기
                  Text('Rarity'),
                  Wrap(
                    spacing: 8.0, // 가로 간격
                    children: selectedRarityMap.keys.map((rarity) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: selectedRarityMap[rarity] ?? false,
                            onChanged: (bool? newValue) {
                              setState(() {
                                selectedRarityMap[rarity] = newValue!;
                              });
                            },
                          ),
                          Text(rarity),
                        ],
                      );
                    }).toList(),
                  ),
                  //dp
                  Text('DP'),
                  RangeSlider(
                    values: currentDpRange,
                    min: 1000,
                    max: 16000,
                    divisions: 15,
                    labels: RangeLabels(
                      currentDpRange.start.round().toString(),
                      currentDpRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        currentDpRange = values;
                      });
                    },
                  ),
                  //play cost
                  Text('Play Cost'),
                  RangeSlider(
                    values: currentPlayCostRange,
                    min: 0,
                    max: 20,
                    divisions: 20,
                    labels: RangeLabels(
                      currentPlayCostRange.start.round().toString(),
                      currentPlayCostRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        currentPlayCostRange = values;
                      });
                    },
                  ),
                  
                  //digivolve cost
                  Text('Digivolve Cost'),
                  RangeSlider(
                    values: currentDigivolutionCostRange,
                    min: 0,
                    max: 8,
                    divisions: 8,
                    labels: RangeLabels(
                      currentDigivolutionCostRange.start.round().toString(),
                      currentDigivolutionCostRange.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        currentDigivolutionCostRange = values;
                      });
                    },
                  ),
                  
                  
                  //특일 여부

                  //검색어
                  TextField(
                    controller: _dialogSearchStringEditingController,
                  )

                  //
                ],
              ),
              actions: [
                TextButton(
                  child: Text("적용"),
                  onPressed: () {
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

                    widget.searchParameter.minDp =  currentDpRange.start.round();
                    widget.searchParameter.maxDp =  currentDpRange.end.round();
                    widget.searchParameter.minPlayCost = currentPlayCostRange.start.round();
                    widget.searchParameter.maxPlayCost = currentPlayCostRange.end.round();
                    widget.searchParameter.minDigivolutionCost = currentDigivolutionCostRange.start.round();
                    widget.searchParameter.maxDigivolutionCost= currentDigivolutionCostRange.end.round();
                    widget.searchParameter.searchString = _dialogSearchStringEditingController?.value.text;
                    _searchStringEditingController?.text =_dialogSearchStringEditingController!.value.text;

                    widget.onSearch();

                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text("조건 초기화"),
                  onPressed: () {
                    selectedNote=widget.notes.first;
                    for (var color in colors) {
                      selectedColorMap[color] = false;
                    }

                    for (var cardType in cardTypes) {
                      selectedCardTypeMap[cardType] = false;
                    }

                    for (var lv in levels) {
                      selectedLvMap[lv] = false;
                    }

                    for (var rarity in rarities) {
                      selectedRarityMap[rarity] = false;
                    }

                    currentDpRange = RangeValues(1000, 16000);

                    currentPlayCostRange = RangeValues(0,20);
                   currentDigivolutionCostRange = RangeValues(0,8);

                    _dialogSearchStringEditingController = TextEditingController(text: _searchStringEditingController?.value.text);
                    setState(() {
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 8,
            child: TextField(
              controller: _searchStringEditingController,
              onChanged: (value) {
                widget.searchParameter.searchString = value;
              },
              onSubmitted: (value) {
                widget.onSearch();
              },
            )),
        Expanded(
            flex: 1,
            child: IconButton(
                onPressed: () {
                  widget.onSearch();
                },
                icon: const Icon(Icons.search))),
        Expanded(
            flex: 1,
            child: IconButton(
                onPressed: _showFilterDialog, icon: Icon(Icons.menu)))
      ],
    );
  }
}
