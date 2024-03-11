import 'package:auto_route/annotations.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_search_view.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_view_widget.dart';
import 'package:flutter/material.dart';

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
    super.initState();
  }

  void updateSelectedDeck(DeckResponseDto deckResponseDto){
    _selectedDeck = Deck.responseDto(deckResponseDto);
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.01),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.blueAccent),
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
                // color: Colors.blueAccent,
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
