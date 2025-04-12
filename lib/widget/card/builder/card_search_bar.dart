import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/service/card_data_service.dart';
import 'package:digimon_meta_site_flutter/service/color_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../model/note.dart';
import '../../../provider/text_simplify_provider.dart';
import '../../../service/card_overlay_service.dart';
import '../../../service/size_service.dart';
import '../../common/toast_overlay.dart';

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
        return '적';
      case 'BLUE':
        return '청';
      case 'YELLOW':
        return '황';
      case 'GREEN':
        return '녹';
      case 'BLACK':
        return '흑';
      case 'PURPLE':
        return '자';
      case 'WHITE':
        return '백';
      default:
        return "에러";
    }
  }


  void _showFilterDialog() {
    CardOverlayService().removeAllOverlays();
    Set<String> _searchResults = CardDataService().searchTypes("");
    Set<String> _selectedTypes = widget.searchParameter.types;
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
              titlePadding: const EdgeInsets.all(16),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.filter_list, size: 24, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  const Text("세부 검색 조건"),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              content: SizedBox(
                width: isPortrait
                    ? MediaQuery.sizeOf(context).width * 0.8
                    : MediaQuery.sizeOf(context).width * 0.4,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      TextField(
                        controller: _dialogSearchStringEditingController,
                        decoration: InputDecoration(
                          labelText: '검색어',
                          labelStyle: TextStyle(
                            color: Theme.of(context).primaryColor.withOpacity(0.7),
                          ),
                          hintText: '카드명/효과',
                          hintStyle: TextStyle(
                            color: Theme.of(context).primaryColor.withOpacity(0.6),
                          ),
                          prefixIcon: Icon(Icons.search, size: 20, color: Theme.of(context).primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Theme.of(context).primaryColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                enCardInclude = true;
                              }
                            });
                          },
                        ),
                      ),
                      const Text(
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
                      const Divider(),
                      //색 고르기
                      const Text(
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
                      const Divider(),
                      //카드 타입 고르기
                      const Text(
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
                      const Divider(),
                      //레어도 고르기
                      const Text(
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
                      const Divider(),
                      const Text(
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
                                const Text('모두'),
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
                                const Text('일반 카드만')
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
                                const Text('패럴렐 카드만'),
                              ],
                            )
                          ]),
                      const Divider(),

                      const Text(
                        '미발매 카드 포함 여부',
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
                              const Text('한국 발매카드만'),
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
                              const Text('미발매 카드 포함')
                            ],
                          ),
                        ],
                      ),
                      const Divider(),
                      //dp
                      const Text(
                        'DP',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RangeSlider(
                        values: currentDpRange,
                        min: 1000,
                        max: 17000,
                        divisions: 16,
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
                      const Divider(),
                      //play cost
                      const Text(
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
                      const Divider(),

                      //digivolve cost
                      const Text(
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
                      const Divider(),
                      const Text(
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
                                        CardDataService().searchTypes(value);
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: '유형 검색',
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColor.withOpacity(0.7),
                                  ),
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                                  ),
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
                                const Text(
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
                                const Text(
                                  'AND',
                                  // style: TextStyle(fontSize: fontSize),
                                ),
                              ],

                            )),

                        ],
                      ),
                      const SizedBox(height: 20,),
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
                                  final type = _searchResults.elementAt(index);
                                  return ListTile(
                                    title: Text(type),
                                    onTap: () {
                                      _selectedTypes.add(type);
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
                                  children: _selectedTypes
                                      .map((type) => Chip(
                                            label: Text(type),
                                            deleteButtonTooltipMessage: '제거',
                                            onDeleted: () {
                                              setState(() {
                                                _selectedTypes.remove(type);
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
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("조건 초기화", style: TextStyle(fontWeight: FontWeight.w500)),
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

                    currentDpRange = const RangeValues(1000, 17000);

                    currentPlayCostRange = const RangeValues(0, 20);
                    currentDigivolutionCostRange = const RangeValues(0, 8);
                    parallelOption = 0;
                    _dialogSearchStringEditingController =
                        TextEditingController(text: '');
                    enCardInclude = true;
                    _selectedTypes={};
                    typeOperation=1;

                    setState(() {});
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("적용", style: TextStyle(fontWeight: FontWeight.w500)),
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


                    Navigator.pop(context);

                    widget.updateSearchParameter();

                    ToastOverlay.show(
                      context,
                      '검색 조건이 적용되었습니다.',
                      type: ToastType.info
                    );
                  },
                ),
              ],
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

    return Row(
      children: [
        Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: TextField(
                controller: _searchStringEditingController,
                onChanged: (value) {
                  widget.searchParameter.searchString = value;
                },
                onSubmitted: (value) {
                  widget.updateSearchParameter();
                },
                decoration: InputDecoration(
                  hintText: '카드명/효과',
                  hintStyle: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: Theme.of(context).primaryColor,
                  ),
                  suffixIcon: _searchStringEditingController?.text.isNotEmpty ?? false
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          _searchStringEditingController?.clear();
                          widget.searchParameter.searchString = '';
                        },
                      )
                    : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                ),
              ),
            )),
        Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                onPressed: () {
                  widget.updateSearchParameter();
                },
                icon: const Icon(Icons.search, size: 20),
                padding: EdgeInsets.zero,
                tooltip: '검색',
              ),
            )),
        Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  onPressed: () {
                    _showFilterDialog();
                  },
                  tooltip: '필터',
                  icon: const Icon(Icons.menu)),
            )),
        Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  tooltip: '초기화',
                  onPressed: () {
                    resetSearchCondition();
                    ToastOverlay.show(
                      context,
                      '검색 조건이 초기화되었습니다.',
                      type: ToastType.warning
                    );
                  },
                  icon: const Icon(Icons.refresh)),
            )),
        if (widget.viewMode != null)
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
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
          ),
      ],
    );
  }
}
