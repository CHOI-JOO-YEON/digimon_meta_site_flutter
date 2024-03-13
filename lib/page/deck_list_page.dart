import 'package:auto_route/annotations.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_search_view.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/flutter_sliding_up_panel.dart';

import '../model/deck.dart';

@RoutePage()
class DeckListPage extends StatefulWidget {
  const DeckListPage({super.key});

  @override
  State<DeckListPage> createState() => _DeckListPageState();
}

class _DeckListPageState extends State<DeckListPage> {
  Deck? _selectedDeck;

  @override
  void initState() {
    // TODO: implement initState
    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.offset >=
          scrollController.position.maxScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.expand();
      } else if (scrollController.offset <=
          scrollController.position.minScrollExtent &&
          !scrollController.position.outOfRange) {
        panelController.anchor();
      } else {}
    });
    super.initState();
  }

  void updateSelectedDeck(DeckResponseDto deckResponseDto){
    _selectedDeck = Deck.responseDto(deckResponseDto);
    setState(() {

    });
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Padding(
  //     padding: EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.01),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Expanded(
  //           flex: 3,
  //           child: Container(
  //             decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(5),
  //
  //                 // color: Colors.blueAccent
  //                 color:  Theme.of(context).highlightColor
  //             ),
  //             child: SingleChildScrollView(
  //               child: SizedBox(
  //                 height: MediaQuery.sizeOf(context).height * 0.88,
  //                 // height: 1000,
  //                 child: _selectedDeck == null
  //                     ? Container()
  //                     : DeckViewerView(
  //                         deck: _selectedDeck!,
  //                       ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         SizedBox(
  //           width: MediaQuery.sizeOf(context).width * 0.01,
  //         ),
  //         Expanded(
  //           flex: 2,
  //           child: Container(
  //             decoration: BoxDecoration(
  //               color:  Theme.of(context).highlightColor,
  //               borderRadius: BorderRadius.circular(5),
  //               // border: Border.all()
  //             ),
  //             child: Padding(
  //               padding:
  //                   EdgeInsets.all(MediaQuery.sizeOf(context).width * 0.01),
  //               child: DeckSearchView(
  //                 deckUpdate: updateSelectedDeck,
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  late ScrollController scrollController;

  ///The controller of sliding up panel
  SlidingUpPanelController panelController = SlidingUpPanelController();

  double minBound = 0;

  double upperBound = 1.0;

  @override
  Widget build(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Padding(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.01),
      child: isPortrait?
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),

                    // color: Colors.blueAccent
                    color:  Theme.of(context).highlightColor
                ),
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.sizeOf(context).height *0.9,
                    child: _selectedDeck == null
                        ? Container()
                        : DeckViewerView(
                      deck: _selectedDeck!,
                    ),
                  ),
                ),
              ),
              SlidingUpPanelWidget(
                controlHeight: 30.0,
                anchor: 0.4,
                minimumBound: minBound,
                upperBound: upperBound,
                panelController: panelController,
                enableOnTap: false,
                child: Container(
                  decoration: BoxDecoration(
                    // border: Border.all(),
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[200],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(MediaQuery.sizeOf(context).width * 0.01),
                    child: SizedBox(
                      height: 1000,
                      child: Column(
                        children: [
                          Text('덱 검색'),
                          Expanded(
                            child: DeckSearchView(
                              deckUpdate: updateSelectedDeck,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
          : Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),

                  // color: Colors.blueAccent
                  color:  Theme.of(context).highlightColor
              ),
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
                color:  Theme.of(context).highlightColor,
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
