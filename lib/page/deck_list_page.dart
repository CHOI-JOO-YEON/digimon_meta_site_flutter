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
          ? SlidingUpPanel(
              renderPanelSheet: false,
              minHeight: 50,
              maxHeight: MediaQuery.of(context).size.height * 0.5,
              panel: Container(
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
                              child: Transform.scale(
                                scaleX: 2,
                                child: Icon(
                                  Icons.drag_handle,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
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
                                            duration: Duration(milliseconds: 500),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                        child: Text('메인덱 보기'
                                          ,style: TextStyle(fontSize: fontSize),

                                        )),
                                    TextButton(onPressed: () {
                                      _scrollController.animateTo(
                                        _scrollController.position.maxScrollExtent,
                                        duration: Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                      );

                                    }, child: Text('타마덱 보기'
                                      ,style: TextStyle(fontSize: fontSize),
                                    ))
                                  ],
                                ))
                          ],
                        ),
                      ),
                      Expanded(
                              child: DeckSearchView(
                                deckUpdate: updateSelectedDeck,
                              ),

                      ),
                    ],
                  ),
                ),
              ),
              body: Padding(
                padding: EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.01),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child:  Column(
                    children: [
                      SizedBox(
                                  height: MediaQuery.sizeOf(context).height *0.9,
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
              )
      )
          // Stack(
          //   children: [
          //     Container(
          //       decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(5),
          //
          //           // color: Colors.blueAccent
          //           color:  Theme.of(context).highlightColor
          //       ),
          //       child: SingleChildScrollView(
          //         child: SizedBox(
          //           height: MediaQuery.sizeOf(context).height *0.9,
          //           child: _selectedDeck == null
          //               ? Container()
          //               : DeckViewerView(
          //             deck: _selectedDeck!,
          //           ),
          //         ),
          //       ),
          //     ),
          //     SlidingUpPanelWidget(
          //       controlHeight: 30.0,
          //       anchor: 0.4,
          //       minimumBound: minBound,
          //       upperBound: upperBound,
          //       panelController: panelController,
          //       enableOnTap: false,
          //       child: Container(
          //         decoration: BoxDecoration(
          //           // border: Border.all(),
          //           borderRadius: BorderRadius.circular(5),
          //           color: Colors.grey[200],
          //         ),
          //         child: Padding(
          //           padding: EdgeInsets.all(MediaQuery.sizeOf(context).width * 0.01),
          //           child: SizedBox(
          //             height: 1000,
          //             child: Column(
          //               children: [
          //                 Text('덱 검색'),
          //                 Expanded(
          //                   child: DeckSearchView(
          //                     deckUpdate: updateSelectedDeck,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //     )
          //   ],
          // )
          : Row(
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
                      padding: EdgeInsets.all(
                          MediaQuery.sizeOf(context).width * 0.01),
                      child: DeckSearchView(
                        deckUpdate: updateSelectedDeck,
                      ),
                    ),
                  ),
                ),
              ],

    );
  }
}
