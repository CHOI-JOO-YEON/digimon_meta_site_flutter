import 'dart:async';
import 'dart:math';

import 'package:auto_route/annotations.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_search_view.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../model/deck.dart';

@RoutePage()
class DeckListPage extends StatefulWidget {
  const DeckListPage({super.key});

  @override
  State<DeckListPage> createState() => _DeckListPageState();
}

class _DeckListPageState extends State<DeckListPage> {
  final ScrollController _scrollController = ScrollController();
  final PanelController _panelController = PanelController();
  Deck? _selectedDeck;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void updateSelectedDeck(DeckResponseDto deckResponseDto) {
    _selectedDeck = Deck.responseDto(deckResponseDto);
    setState(() {});
  }

  @override
  void dispose() {
    if (mounted) {
      _scrollController.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double fontSize = min(MediaQuery.sizeOf(context).width * 0.009, 15);
    if (isPortrait) {
      fontSize *= 2;
    }
    return isPortrait
        ? LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
            return SlidingUpPanel(
                controller: _panelController,
                renderPanelSheet: false,
                minHeight: 50,
                maxHeight: constraints.maxHeight,
                snapPoint: 0.5,
                isDraggable: false,
                panelBuilder: (ScrollController sc){
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: MediaQuery.sizeOf(context).width * 0.01,
                          right: MediaQuery.sizeOf(context).width * 0.01,
                          bottom: MediaQuery.sizeOf(context).width * 0.01),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Container()),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: _panelController.panelPosition > 0.3
                                            ? () {
                                          if (_panelController.panelPosition > 0.7) {
                                            _panelController.animatePanelToSnapPoint().then((_) {
                                              setState(() {});
                                            });
                                          } else {
                                            _panelController.close().then((_) {
                                              setState(() {});
                                            });
                                          }
                                        }
                                            : null,
                                        icon: Icon(
                                          Icons.arrow_drop_down,
                                          color: _panelController.panelPosition > 0.3
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '검색 패널',
                                        style: TextStyle(fontSize: fontSize, color:  Theme.of(context).primaryColor),
                                      ),
                                      IconButton(
                                        onPressed: _panelController.panelPosition < 0.7
                                            ? () {
                                          if (_panelController.panelPosition < 0.3) {
                                            _panelController.animatePanelToSnapPoint().then((_) {
                                              setState(() {});
                                            });
                                          } else {
                                            _panelController.open().then((_) {
                                              setState(() {});
                                            });
                                          }
                                        }
                                            : null,
                                        icon: Icon(
                                          Icons.arrow_drop_up,
                                          color: _panelController.panelPosition < 0.7
                                              ?  Theme.of(context).primaryColor
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                            onPressed: () {

                                              _scrollController.animateTo(
                                                0,
                                                duration:
                                                Duration(milliseconds: 500),
                                                curve: Curves.easeInOut,
                                              );
                                            },
                                            child: Text(
                                              '메인덱 보기',
                                              style:
                                              TextStyle(fontSize: fontSize),
                                            )),
                                        TextButton(
                                            onPressed: () {

                                              _scrollController.animateTo(
                                                _scrollController
                                                    .position.maxScrollExtent,
                                                duration:
                                                Duration(milliseconds: 500),
                                                curve: Curves.easeInOut,
                                              );
                                            },
                                            child: Text(
                                              '타마덱 보기',
                                              style:
                                              TextStyle(fontSize: fontSize),
                                            ))
                                      ],
                                    ))
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: DeckSearchView(
                              deckUpdate: updateSelectedDeck,
                            ),
                          ),
                          Expanded(
                              flex: _panelController.panelPosition<0.7?5:0,
                              child: Container())
                        ],
                      ),
                    ),
                  );
                },

                body: Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.01),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.9,
                          child: _selectedDeck == null
                              ? Container()
                              : DeckViewerView(
                                  deck: _selectedDeck!,
                                ),
                        ),
                        Container(
                          height: MediaQuery.sizeOf(context).height * 0.6,
                        ),
                      ],
                    ),
                  ),
                ));
          })

        : Padding(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.01),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),

                        // color: Colors.blueAccent
                        color: Theme.of(context).highlightColor),
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.88,
                        // height: 1000,
                        child: _selectedDeck == null
                            ? Container()
                            : DeckViewerView(
                                deck: _selectedDeck!,
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.01,
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).highlightColor,
                      borderRadius: BorderRadius.circular(5),
                      // border: Border.all()
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.all(MediaQuery.sizeOf(context).width * 0.01),
                      child: DeckSearchView(
                        deckUpdate: updateSelectedDeck,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        );
  }
}
