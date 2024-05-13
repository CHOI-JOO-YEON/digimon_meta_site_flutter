import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/service/color_service.dart';
import 'package:digimon_meta_site_flutter/service/type_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../model/note.dart';
import '../../../model/type.dart';

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
    'red',
    'blue',
    'yellow',
    'green',
    'black',
    'purple',
    'white'
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

  @override
  void initState() {
    super.initState();
    _searchStringEditingController =
        TextEditingController(text: widget.searchParameter.searchString);
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
      case 'red':
        return '적';
      case 'blue':
        return '청';
      case 'yellow':
        return '황';
      case 'green':
        return '녹';
      case 'green':
        return '녹';
      case 'black':
        return '흑';
      case 'purple':
        return '자';
      case 'white':
        return '백';
      default:
        return "에러";
    }
  }


  void _showFilterDialog() {
    List<TypeDto> _searchResults = TypeService().search("");
    Map<int, String> _selectedTypes = widget.searchParameter.types;

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
    int parallelOption = widget.searchParameter.parallelOption;
    bool enCardInclude = widget.searchParameter.isEnglishCardInclude;
    int typeOperation = widget.searchParameter.typeOperation;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("세부 검색 조건"),
              content: SizedBox(
                width: isPortrait
                    ? MediaQuery.sizeOf(context).width * 0.8
                    : MediaQuery.sizeOf(context).width * 0.4,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 컬럼 크기를 내용에 맞게 조절
                    children: [
                      //검색어
                      TextField(
                        controller: _dialogSearchStringEditingController,
                        decoration: InputDecoration(
                          labelText: '검색어',
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: DropdownButton<NoteDto>(
                          value: selectedNote,
                          hint: Text(
                            selectedNote?.name ?? "입수처",
                            overflow: TextOverflow.ellipsis,
                          ),
                          items: dropDownMenuItems,
                          onChanged: (NoteDto? newValue) {
                            setState(() {
                              selectedNote = newValue;
                              if (newValue!.cardOrigin == 'ENGLISH') {
                                print('!');
                                enCardInclude = true;
                              }
                            });
                          },
                        ),
                      ),
                      //lv 고르기
                      Text(
                        'LV',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                              Text(lv == 0 ? '-' : '$lv'),
                            ],
                          );
                        }).toList(),
                      ),
                      Divider(),
                      //색 고르기
                      Text(
                        '컬러',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                              Text(
                                getKorColorStringByEn(color),
                                style: TextStyle(
                                    color: ColorService.getColorFromString(
                                        color.toUpperCase())),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      //색 or/and
                      Divider(),
                      //카드 타입 고르기
                      Text(
                        '카드 타입',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                              Text(getCardTypeByString(cardType)),
                            ],
                          );
                        }).toList(),
                      ),
                      Divider(),
                      //레어도 고르기
                      Text(
                        '레어도',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),

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
                      Divider(),
                      Text(
                        '패럴렐 여부',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                          spacing: 8.0, // 가로 간격
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: parallelOption == 0,
                                  onChanged: (value) {
                                    setState(() {
                                      parallelOption = 0;
                                    });
                                  },
                                ),
                                Text('모두'),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: parallelOption == 1,
                                  onChanged: (value) {
                                    setState(() {
                                      parallelOption = 1;
                                    });
                                  },
                                ),
                                Text('일반 카드만')
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: parallelOption == 2,
                                  onChanged: (value) {
                                    setState(() {
                                      parallelOption = 2;
                                    });
                                  },
                                ),
                                Text('패럴렐 카드만'),
                              ],
                            )
                          ]),
                      Divider(),

                      Text(
                        '영문 카드 포함 여부',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Wrap(
                        spacing: 8.0, // 가로 간격
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: !enCardInclude,
                                onChanged: (value) {
                                  setState(() {
                                    enCardInclude = !value!;
                                  });
                                },
                              ),
                              Text('한글 카드만'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: enCardInclude,
                                onChanged: (value) {
                                  setState(() {
                                    enCardInclude = value!;
                                  });
                                },
                              ),
                              Text('영문 카드 포함')
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                      //dp
                      Text(
                        'DP',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                      Divider(),
                      //play cost
                      Text(
                        '등장/사용 코스트',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                      Divider(),

                      //digivolve cost
                      Text(
                        '진화 코스트',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                      Divider(),
                      Text(
                        '유형',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                            Expanded(
                              flex: 1,
                              child: TextField(
                                controller: _trieSearchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchResults =
                                        TypeService().search(value);
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: '유형 검색',
                                ),
                              ),
                            ),
                        Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Radio(
                                  value: 1,
                                  groupValue: typeOperation,
                                  onChanged: (value) {
                                    setState(() {
                                      typeOperation =
                                      value as int;
                                    });
                                  },
                                ),
                                Text(
                                  'OR',
                                  // style: TextStyle(fontSize: fontSize),
                                ),
                                Radio(
                                  value: 0,
                                  groupValue: typeOperation,
                                  onChanged: (value) {
                                    setState(() {
                                      typeOperation =
                                      value as int;
                                    });
                                  },
                                ),
                                Text(
                                  'AND',
                                  // style: TextStyle(fontSize: fontSize),
                                ),
                              ],

                            )),

                        ],
                      ),
                      SizedBox(height: 20,),
                      // 검색 결과 표시
                      SizedBox(
                        height: 200,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                itemBuilder: (context, index) {
                                  final type = _searchResults[index];
                                  return ListTile(
                                    title: Text(type.name),
                                    onTap: () {
                                      _selectedTypes[type.typeId] = type.name;
                                      setState(() {});
                                    },
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: SingleChildScrollView(
                                child: Wrap(
                                  runSpacing: 4,
                                  spacing: 8,
                                  children: _selectedTypes.entries
                                      .map((type) => Chip(
                                            label: Text(type.value),
                                            deleteButtonTooltipMessage: '제거',
                                            onDeleted: () {
                                              setState(() {
                                                _selectedTypes.remove(type.key);
                                              });
                                            },
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      //
                    ],
                  ),
                ),
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
                    widget.searchParameter.parallelOption = parallelOption;
                    widget.searchParameter.isEnglishCardInclude = enCardInclude;
                    widget.searchParameter.typeOperation = typeOperation;
                    widget.searchParameter.types = _selectedTypes;
                    widget.onSearch();


                    Navigator.pop(context);

                    widget.updateSearchParameter();
                  },
                ),
                TextButton(
                  child: Text("조건 초기화"),
                  onPressed: () {
                    selectedNote = all;
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

                    currentPlayCostRange = RangeValues(0, 20);
                    currentDigivolutionCostRange = RangeValues(0, 8);
                    parallelOption = 0;
                    _dialogSearchStringEditingController =
                        TextEditingController(text: '');
                    enCardInclude = true;
                    _selectedTypes={};
                    typeOperation=1;

                    setState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Comparator<NoteDto> noteDtoComparator = (a, b) {
    // releaseDate가 null인 경우 우선순위에서 뒤로 가도록 처리
    if (a.releaseDate == null && b.releaseDate == null) {
      return a.name.compareTo(b.name);
    } else if (a.releaseDate == null) {
      return 1;
    } else if (b.releaseDate == null) {
      return -1;
    }

    // releaseDate가 내림차순으로 정렬
    int releaseDateComparison = b.releaseDate!.compareTo(a.releaseDate!);
    if (releaseDateComparison != 0) {
      return releaseDateComparison;
    }

    // releaseDate가 같은 경우 name 오름차순으로 정렬
    return a.name.compareTo(b.name);
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
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
    menuItems.add(
      DropdownMenuItem<NoteDto>(
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
    menuItems.addAll(_createMenuItemsWithHeaderAndDivider('영문 카드', enList));

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
          style: TextStyle(fontWeight: FontWeight.bold),
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
        DropdownMenuItem<NoteDto>(
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
                widget.updateSearchParameter();
              },
            )),
        Expanded(
            flex: 1,
            child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  widget.onSearch();
                },
                icon: const Icon(Icons.search))),
        Expanded(
            flex: 1,
            child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: _showFilterDialog,
                icon: Icon(Icons.menu))),
        if (widget.viewMode != null)
          Expanded(
            flex: 1,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                if (widget.onViewModeChanged != null) {
                  widget.onViewModeChanged!(
                    widget.viewMode == 'grid' ? 'list' : 'grid',
                  );
                }
              },
              icon: Icon(
                widget.viewMode == 'grid' ? Icons.view_list : Icons.grid_view,
              ),
            ),
          ),
      ],
    );
  }
}
