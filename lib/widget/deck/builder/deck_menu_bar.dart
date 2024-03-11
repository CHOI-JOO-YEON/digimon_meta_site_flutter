import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/format.dart';
import 'package:digimon_meta_site_flutter/model/note.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/widget/random_hand_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../enums/site_enum.dart';
import '../../../model/deck.dart';

class DeckBuilderMenuBar extends StatefulWidget {
  final Deck deck;
  final Function() clear;
  final Function() init;
  final Function(DeckResponseDto) import;

  const DeckBuilderMenuBar(
      {super.key,
      required this.deck,
      required this.clear,
      required this.import, required this.init});

  @override
  State<DeckBuilderMenuBar> createState() => _DeckBuilderMenuBarState();
}

class _DeckBuilderMenuBarState extends State<DeckBuilderMenuBar> {
  bool _isEditing = false;
  final TextEditingController _deckNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _deckNameController.text = widget.deck.deckName; // 덱 이름 초기 설정
  }

  @override
  void dispose() {
    _deckNameController.dispose();
    super.dispose();
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Text('로그인이 필요합니다.'),
        );
      },
    );
  }

  Color _getColorFromString(String colorString) {
    switch (colorString) {
      case 'RED':
        return Colors.red;
      case 'BLUE':
        return Colors.blue;
      case 'YELLOW':
        return Colors.yellow;
      case 'GREEN':
        return Colors.green;
      case 'BLACK':
        return Colors.black;
      case 'PURPLE':
        return Colors.purple;
      case 'WHITE':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  Widget _colorSelectionWidget(Deck deck) {
    List<String> cardColorList = deck.getOrderedCardColorList();
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          children: [
            Text('덱 컬러 선택'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                cardColorList.length,
                (index) {
                  String color = cardColorList[index];
                  Color buttonColor = _getColorFromString(color);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (deck.colors.contains(color)) {
                          deck.colors.remove(color);
                        } else {
                          deck.colors.add(color);
                        }
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: deck.colors.contains(color)
                                ? buttonColor
                                : buttonColor.withOpacity(0.3),
                            border: Border.all(
                              color: deck.colors.contains(color)
                                  ? Colors.black
                                  : buttonColor.withOpacity(0.3),
                              width: 2.0,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          color,
                          style: TextStyle(
                              fontSize: 12.0,
                              color: deck.colors.contains(color)
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSaveDialog(BuildContext context, Map<int, FormatDto> formats) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              content: SizedBox(
                width: MediaQuery.sizeOf(context).width / 3,
                height: MediaQuery.sizeOf(context).height / 2,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(widget.deck.isPublic ? '전체 공개' : '비공개'),
                        Switch(
                          value: widget.deck.isPublic,
                          onChanged: (bool v) {
                            setState(() {
                              widget.deck.isPublic = v;
                            });
                          },
                        ),
                      ],
                    ),
                    _colorSelectionWidget(widget.deck),
                    DropdownButton<int>(
                      value: widget.deck.formatId,
                      hint: Text(formats[widget.deck.formatId]?.name ?? "포맷 "),
                      items: formats.keys.map((int idx) {
                        return DropdownMenuItem<int>(
                          value: idx,
                          child: Text(
                              '${formats[idx]!.name} ['
                                  '${DateFormat('yyyy-MM-dd').format(formats[idx]!.startDate)} ~ '
                                  '${DateFormat('yyyy-MM-dd').format(formats[idx]!.endDate)}]'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          widget.deck.formatId = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    List<String> cardColorList = widget.deck.getOrderedCardColorList();
                    Set<String> set = cardColorList.toSet();
                    widget.deck.colorArrange(set);
                    Deck? deck = await DeckService().save(widget.deck);
                    if (deck != null) {
                      widget.deck.deckId = deck.deckId;
                      _showSaveSuccessDialog(context);
                    } else {
                      _showSaveFailedDialog(context);
                    }
                  },
                  child: Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSaveSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Text('저장 성공'),
        );
      },
    );
  }

  void _showSaveFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Text('저장 실패'),
        );
      },
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        SiteName _selectedButton = SiteName.values.first;
        TextEditingController _textEditingController = TextEditingController();
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Import from'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: SiteName.values.map((siteName) {
                        String name = siteName.toString().split('.').last;
                        return Expanded(
                          child: ListTile(
                            title: Text(name),
                            leading: Radio<SiteName>(
                              value: siteName,
                              groupValue: _selectedButton,
                              onChanged: (value) {
                                setState(() {
                                  _selectedButton = value!;
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    TextField(
                      controller: _textEditingController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Paste your deck.',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                if (isLoading) CircularProgressIndicator(),
                ElevatedButton(
                  child: Text('Submit'),
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            var deckResponseDto = await DeckService().import(
                                _selectedButton.convertStringToMap(
                                    _textEditingController.value.text));
                            if (deckResponseDto != null) {
                              widget.import(deckResponseDto);
                            }
                            setState(() {
                              isLoading = false;
                            });
                            Navigator.of(context).pop();
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        SiteName _selectedButton = SiteName.values.first;
        TextEditingController _textEditingController = TextEditingController(
          text: _selectedButton.ExportToSiteDeckCode(widget.deck), // 초기값 설정
        );

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Export to'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: SiteName.values.map((siteName) {
                        String name = siteName.toString().split('.').last;
                        return Expanded(
                          child: ListTile(
                            title: Text(name),
                            leading: Radio<SiteName>(
                              value: siteName,
                              groupValue: _selectedButton,
                              onChanged: (SiteName? value) {
                                setState(() {
                                  _selectedButton = value!;
                                  // 선택 상태가 바뀔 때마다 텍스트 필드 업데이트
                                  _textEditingController.text =
                                      _selectedButton.ExportToSiteDeckCode(
                                          widget.deck);
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    TextField(
                      controller: _textEditingController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Paste your deck.',
                      ),
                      enabled: false, // 수정 불가능하게 설정
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text: _textEditingController.text))
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied to clipboard'),
                                ),
                              );
                            });
                          },
                        ),
                      ],
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

  void _showRandomHandDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.8,
              child: RandomHandWidget(
                deck: widget.deck,
              )),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double iconButtonSize =
          min(constraints.maxWidth / 10, constraints.maxHeight / 2);
      double iconSize = iconButtonSize;
      return Column(
        children: [
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          style: const TextStyle(fontFamily: 'JalnanGothic'),
                          controller: _deckNameController,
                          readOnly: !_isEditing,
                          decoration: InputDecoration(
                            hintText: "덱 이름",
                            border: !_isEditing
                                ? InputBorder.none
                                : const UnderlineInputBorder(),
                          ),
                        ),
                      ),
                      if (_isEditing)
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              setState(() {
                                _isEditing = false;
                                widget.deck.deckName =
                                    _deckNameController.text; // 덱 이름 업데이트
                              });
                            },
                          ),
                        )
                      else
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              )),
          Expanded(
            flex: 1,
            child: Consumer<UserProvider>(builder: (BuildContext context,
                UserProvider userProvider, Widget? child) {
              bool hasManagerRole = userProvider.hasManagerRole(); // 권한 확인
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconButtonSize, height: iconButtonSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {

                        _deckNameController.text='My Deck';
                        widget.init();
                      },
                      iconSize: iconSize,
                      icon: const Icon(Icons.add_box),
                      tooltip: '새로 만들기',
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconButtonSize, height: iconButtonSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        widget.clear();
                      },
                      iconSize: iconSize,
                      icon: const Icon(Icons.clear),
                      tooltip: '초기화',
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconButtonSize, height: iconButtonSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        if (userProvider.isLogin()) {
                          Map<int, FormatDto> formats =
                              await DeckService().getFormats(widget.deck);
                          _showSaveDialog(context, formats);
                        } else {
                          _showLoginDialog(context);
                        }
                      },
                      iconSize: iconSize,
                      icon: const Icon(Icons.save),
                      tooltip: '저장',
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconButtonSize, height: iconButtonSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showImportDialog(context),
                      iconSize: iconSize,
                      icon: const Icon(Icons.download),
                      tooltip: '가져오기',
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconButtonSize, height: iconButtonSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showExportDialog(context),
                      iconSize: iconSize,
                      icon: const Icon(Icons.upload),
                      tooltip: '내보내기',
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconButtonSize, height: iconButtonSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        context.router.push(DeckImageRoute(deck: widget.deck));
                      },
                      iconSize: iconSize,
                      icon: const Icon(Icons.image),
                      tooltip: '이미지 저장',
                    ),
                  ),
                  if (hasManagerRole) // 권한 체크 조건
                    ConstrainedBox(
                      constraints: BoxConstraints.tightFor(
                          width: iconButtonSize, height: iconButtonSize),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          await DeckService().exportToTTSFile(widget.deck);
                        },
                        iconSize: iconSize,
                        icon: const Icon(Icons.videogame_asset_outlined),
                        // 예시 아이콘, 실제 사용할 아이콘으로 변경
                        tooltip: 'TTS 파일 내보내기', // 툴팁 내용도 상황에 맞게 변경
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      );
    });
  }
}
