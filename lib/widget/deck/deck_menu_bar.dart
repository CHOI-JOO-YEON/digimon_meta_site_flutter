import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/page/deck_image_page.dart';
import 'package:digimon_meta_site_flutter/provider/user_provider.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/deck.dart';

class DeckMenuBar extends StatefulWidget {
  final Deck deck;
  final Function() clear;

  const DeckMenuBar({super.key, required this.deck, required this.clear});

  @override
  State<DeckMenuBar> createState() => _DeckMenuBarState();
}

class _DeckMenuBarState extends State<DeckMenuBar> {
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
        return AlertDialog(
          content: Text('로그인이 필요합니다.'),
        );
      },
    );
  }

  void _showSaveSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('저장 성공'),
        );
      },
    );
  }

  void _showSaveFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('저장 실패'),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double iconButtonSize =
          min(constraints.maxWidth / 10, constraints.maxHeight / 2);
      double iconSize = iconButtonSize; // IconButton 내부의 Icon 크기
      return Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      style: TextStyle(fontFamily: 'JalnanGothic'),
                      controller: _deckNameController,
                      readOnly: !_isEditing, // 읽기 전용 상태에 따라 설정
                      decoration: InputDecoration(
                        hintText: "덱 이름",
                        border: !_isEditing ? InputBorder.none : UnderlineInputBorder(), // 읽기 전용 상태에 따라 테두리 설정
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
                            widget.deck.deckName = _deckNameController.text; // 덱 이름 업데이트
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
            )
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                      width: iconButtonSize, height: iconButtonSize),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      widget.clear();
                    },
                    iconSize: iconSize,
                    icon: const Icon(Icons.delete_forever),
                    tooltip: '초기화',
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                      width: iconButtonSize, height: iconButtonSize),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      if(userProvider.isLogin()) {
                        Deck? deck = await DeckService().save(widget.deck);
                        if(deck!=null) {
                          widget.deck.deckId=deck.deckId;
                          _showSaveSuccessDialog(context);
                        }else{
                          // _showSaveFailedDialog(context);
                        }
                      }else{
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
                    onPressed: () {},
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
                    onPressed: () {},
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
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                      width: iconButtonSize, height: iconButtonSize),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {},
                    iconSize: iconSize,
                    icon: const Icon(Icons.back_hand),
                    tooltip: '랜덤패',
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
