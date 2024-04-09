import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/format.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/widget/random_hand_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../enums/site_enum.dart';
import '../../../model/deck.dart';
import '../../../model/limit_dto.dart';
import '../../../provider/limit_provider.dart';

class DeckBuilderMenuBar extends StatefulWidget {
  final Deck deck;
  final Function() clear;
  final Function() init;
  final Function(DeckResponseDto) import;

  const DeckBuilderMenuBar(
      {super.key,
      required this.deck,
      required this.clear,
      required this.import,
      required this.init});

  @override
  State<DeckBuilderMenuBar> createState() => _DeckBuilderMenuBarState();
}

class _DeckBuilderMenuBarState extends State<DeckBuilderMenuBar> {
  final TextEditingController _deckNameController = TextEditingController();

  @override
  void didUpdateWidget(covariant DeckBuilderMenuBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.deck != oldWidget.deck) {
      setState(() {
        _deckNameController.text = widget.deck.deckName ?? 'My Deck';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _deckNameController.text = widget.deck.deckName;
  }

  @override
  void dispose() {
    if (mounted) {
      _deckNameController.dispose();
    }
    super.dispose();
  }

  void _showRenameDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('덱 이름 수정'),
            content: TextField(
              controller: _deckNameController,
              autofocus: true,
              decoration: const InputDecoration(hintText: '덱 이름을 입력하세요'),
            ),
            actions: [
              TextButton(
                child: const Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('완료'),
                onPressed: () {
                  setState(() {
                    widget.deck.deckName = _deckNameController.text;
                  });
                  // FocusScope.of(context).unfocus(); // 키보드 숨기기
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
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
            const Text('덱 컬러 선택', style: TextStyle(fontSize: 25)),
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
                          ),
                        ),
                        const SizedBox(height: 4.0),
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
    LimitProvider limitProvider = Provider.of(context, listen: false);

    var korFormats = formats.entries
        .where((entry) => entry.value.isOnlyEn == false)
        .toList();
    if (!korFormats.isEmpty) {
      widget.deck.formatId = korFormats.first.key;
    } else {
      var enFormats = formats.entries
          .where((entry) => entry.value.isOnlyEn == true)
          .toList()
          .reversed;
      widget.deck.formatId = enFormats.first.key;
    }

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          widget.deck.isPublic ? '전체 공개' : '비공개',
                          style: const TextStyle(fontSize: 25),
                        ),
                        Switch(
                          inactiveThumbColor: Colors.red,
                          value: widget.deck.isPublic,
                          onChanged: (bool v) {
                            setState(() {
                              widget.deck.isPublic = v;
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    _colorSelectionWidget(widget.deck),
                    const Divider(),
                    const Text('포맷', style: TextStyle(fontSize: 25)),
                    DropdownButton<int>(
                      value: widget.deck.formatId,
                      hint: Text(formats[widget.deck.formatId]?.name ?? "포맷 "),
                      items: [
                        const DropdownMenuItem<int>(
                          child: Text(
                            '일반 포맷',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          enabled: false,
                        ),
                        ...formats.entries
                            .where((entry) => entry.value.isOnlyEn == false)
                            .map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(
                              '${entry.value.name} ['
                              '${DateFormat('yyyy-MM-dd').format(entry.value.startDate)} ~ '
                              '${DateFormat('yyyy-MM-dd').format(entry.value.endDate)}]',
                              // overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        const DropdownMenuItem<int>(
                          child: Text('미발매 포맷 [예상 발매 일정]',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          enabled: false,
                        ),
                        ...formats.entries
                            .where((entry) => entry.value.isOnlyEn == true)
                            .toList()
                            .reversed
                            .map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text('${entry.value.name} ['
                                '${DateFormat('yyyy-MM-dd').format(entry.value.startDate)} ~ '
                                '${DateFormat('yyyy-MM-dd').format(entry.value.endDate)}]'),
                          );
                        }).toList(),
                      ],
                      onChanged: (int? newValue) {
                        setState(() {
                          widget.deck.formatId = newValue!;
                        });
                      },
                    ),
                    const Divider(),
                    const Text('선택된 금지/제한', style: TextStyle(fontSize: 25)),
                    Text(
                        '${DateFormat('yyyy-MM-dd').format(limitProvider.selectedLimit!.restrictionBeginDate)}',
                        style: const TextStyle(fontSize: 20))
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    List<String> cardColorList =
                        widget.deck.getOrderedCardColorList();
                    Set<String> set = cardColorList.toSet();
                    widget.deck.colorArrange(set);
                    if (widget.deck.colors.isEmpty) {
                      _showShortDialog(context, "색을 하나 이상 골라야 합니다.");
                      return;
                    }
                    if (widget.deck.formatId == null) {
                      _showShortDialog(context, "포맷을 골라야 합니다.");
                      return;
                    }
                    Deck? deck = await DeckService().save(widget.deck);
                    if (deck != null) {
                      widget.deck.deckId = deck.deckId;
                      _showShortDialog(context, "저장 성공");
                    } else {
                      _showShortDialog(context, "저장 실패");
                    }
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showShortDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(text),
        );
      },
    );
  }

  void showDeckResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('새로 만들기'),
          content: const Text('새로운 덱을 작성하시겠습니까? \n저장되지 않은 변경사항은 사라집니다.'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            ElevatedButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(
                '예',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _deckNameController.text = 'My Deck';
                widget.init();
              },
            ),
          ],
        );
      },
    );
  }

  void showDeckClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('덱 비우기'),
          content: const Text('덱을 비우시겠습니까?'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            ElevatedButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(
                '예',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                widget.clear();
              },
            ),
          ],
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
              title: const Text('Import from'),
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
                      decoration: const InputDecoration(
                        hintText: '여기에 덱 코드를 붙여넣으세요',
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                if (isLoading) const CircularProgressIndicator(),
                ElevatedButton(
                  child: const Text('가져오기'),
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
              title: const Text('Export to'),
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
                      decoration: const InputDecoration(
                        // hintText: 'Paste your deck.',
                      ),
                      enabled: false, // 수정 불가능하게 설정
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text: _textEditingController.text))
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double maxWidth = screenWidth * 0.9;
    final double maxHeight = screenHeight * 0.9;

    final double aspectRatio = 6 / 4;

    double width = maxWidth;
    double height = width / aspectRatio;

    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspectRatio;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double dialogWidth = constraints.maxWidth * 0.9;
            final double dialogHeight = dialogWidth / aspectRatio;

            return AlertDialog(
              content: AspectRatio(
                aspectRatio: aspectRatio,
                child: SizedBox(
                  width: dialogWidth,
                  height: dialogHeight,
                  child: RandomHandWidget(
                    deck: widget.deck,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeckSettingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<LimitProvider>(
          builder: (context, limitProvider, child) {
            LimitDto? selectedLimit = limitProvider.selectedLimit;

            return AlertDialog(
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedLimit != null) {
                          limitProvider.updateSelectLimit(
                              selectedLimit!.restrictionBeginDate);
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('확인'),
                    ),
                  ],
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
                          items: limitProvider.limits.values.map((limitDto) {
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showDeckReceiptDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('대회 제출용 레시피 다운로드'),
          content:const SizedBox(
            width: 300,
            child: Text(
              '* 덱은 31종, 디지타마는 5종까지만 레시피에 기입되며, 이를 넘는 카드 종류는 레시피에 반영되지 않습니다.\n* 레시피 불일치로 발생하는 문제는 책임지지 않으며, 제출 전 꼭 확인 바랍니다.',
              softWrap: true,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            ElevatedButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(
                '다운로드',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await DeckService().generateDeckRecipePDF(widget.deck);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double fontSize = min(MediaQuery.sizeOf(context).width * 0.015, 20);
    double iconSize = min(MediaQuery.sizeOf(context).width * 0.03, 25);
    if (isPortrait) {
      fontSize *= 1.7;
      iconSize *= 1.1;
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Column(
        children: [
          Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: TextField(
                        controller: _deckNameController,
                        onChanged: (v) {
                          widget.deck.deckName = v;
                        },
                      ))
                    ],
                  ),
                ),
              )),
          Expanded(
            flex: 1,
            child: Consumer<UserProvider>(builder: (BuildContext context,
                UserProvider userProvider, Widget? child) {
              bool hasManagerRole = userProvider.hasManagerRole(); // 권한 확인
              // bool isLogin = userProvider.isLogin; // 권한 확인
              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconSize, height: iconSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showDeckResetDialog(context);
                      },
                      iconSize: iconSize,
                      icon: const Icon(Icons.add_box),
                      tooltip: '새로 만들기',
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconSize, height: iconSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showDeckClearDialog(context);
                      },
                      iconSize: iconSize,
                      icon: const Icon(Icons.clear),
                      tooltip: '비우기',
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconSize, height: iconSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () async {
                        if (userProvider.isLogin) {
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
                        width: iconSize, height: iconSize),
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
                        width: iconSize, height: iconSize),
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
                        width: iconSize, height: iconSize),
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
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconSize, height: iconSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _showDeckSettingDialog(context),
                      iconSize: iconSize,
                      icon: const Icon(Icons.settings),
                      tooltip: '덱 설정',
                    ),
                  ),
                  // ConstrainedBox(
                  //   constraints: BoxConstraints.tightFor(
                  //       width: iconSize, height: iconSize),
                  //   child: IconButton(
                  //     padding: EdgeInsets.zero,
                  //     onPressed: () => _showRandomHandDialog(context),
                  //     iconSize: iconSize,
                  //     icon: const Icon(Icons.back_hand_rounded),
                  //     tooltip: '랜덤 핸드',
                  //   ),
                  // ),
                  ConstrainedBox(
                    constraints: BoxConstraints.tightFor(
                        width: iconSize, height: iconSize),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => showDeckReceiptDialog(context),
                      iconSize: iconSize,
                      icon: const Icon(Icons.receipt_long),
                      tooltip: '대회 제출용 레시피',
                    ),
                  ),
                  if (hasManagerRole) // 권한 체크 조건
                    ConstrainedBox(
                      constraints: BoxConstraints.tightFor(
                          width: iconSize, height: iconSize),
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
