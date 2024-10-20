import 'dart:convert';
import 'dart:math';

import 'package:auto_route/annotations.dart';
import 'package:digimon_meta_site_flutter/model/deck-view.dart';
import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_search_view.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_view_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../model/deck-build.dart';
import '../router.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class DeckListPage extends StatefulWidget {
  final String? searchParameterString;

  const DeckListPage(
      {super.key, @QueryParam('searchParameter') this.searchParameterString});

  @override
  State<DeckListPage> createState() => _DeckListPageState();
}

class _DeckListPageState extends State<DeckListPage> {
  final ScrollController _scrollController = ScrollController();
  final PanelController _panelController = PanelController();
  DeckSearchParameter deckSearchParameter =
      DeckSearchParameter(isMyDeck: false);
  DeckBuild? _selectedDeck;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.searchParameterString != null) {
      deckSearchParameter = DeckSearchParameter.fromJson(
          json.decode(widget.searchParameterString!));
    }
  }

  void updateSearchParameter() {
    AutoRouter.of(context).navigate(
      DeckListRoute(
          searchParameterString: json.encode(deckSearchParameter.toJson())),
    );
  }

  void updateSelectedDeck(DeckView deckView) {
    _selectedDeck = DeckBuild.deckView(deckView);
    setState(() {});
  }

  @override
  void dispose() {
    if (mounted) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void searchNote(int noteId) {
    SearchParameter searchParameter = SearchParameter();
    searchParameter.noteId = noteId;
    context.navigateTo(DeckBuilderRoute(
        searchParameterString: json.encode(searchParameter.toJson())));
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double fontSize = min(MediaQuery.sizeOf(context).width * 0.012, 15);
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
                panelBuilder: (ScrollController sc) {
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
                                Expanded(flex: 2, child: Container()),
                                Expanded(
                                    flex: 3,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed:
                                              _panelController.panelPosition >
                                                      0.3
                                                  ? () {
                                                      if (_panelController
                                                              .panelPosition >
                                                          0.7) {
                                                        _panelController
                                                            .animatePanelToSnapPoint()
                                                            .then((_) {
                                                          setState(() {});
                                                        });
                                                      } else {
                                                        _panelController
                                                            .close()
                                                            .then((_) {
                                                          setState(() {});
                                                        });
                                                      }
                                                    }
                                                  : null,
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: _panelController
                                                        .panelPosition >
                                                    0.3
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '덱 검색 패널',
                                          style: TextStyle(
                                              fontSize: fontSize,
                                              color: Theme.of(context)
                                                  .primaryColor),
                                        ),
                                        IconButton(
                                          onPressed:
                                              _panelController.panelPosition <
                                                      0.7
                                                  ? () {
                                                      if (_panelController
                                                              .panelPosition <
                                                          0.3) {
                                                        _panelController
                                                            .animatePanelToSnapPoint()
                                                            .then((_) {
                                                          setState(() {});
                                                        });
                                                      } else {
                                                        _panelController
                                                            .open()
                                                            .then((_) {
                                                          setState(() {});
                                                        });
                                                      }
                                                    }
                                                  : null,
                                          icon: Icon(
                                            Icons.arrow_drop_up,
                                            color: _panelController
                                                        .panelPosition <
                                                    0.7
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey,
                                          ),
                                        ),
                                      ],
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: TextButton(
                                              onPressed: () {
                                                _scrollController.animateTo(
                                                  0,
                                                  duration:
                                                      Duration(milliseconds: 500),
                                                  curve: Curves.easeInOut,
                                                );
                                              },
                                              child: Text(
                                                '메인덱',
                                                style:
                                                    TextStyle(fontSize: fontSize),
                                              )),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: TextButton(
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
                                                '타마덱',
                                                style:
                                                    TextStyle(fontSize: fontSize),
                                              )),
                                        )
                                      ],
                                    ))
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: DeckSearchView(
                              deckUpdate: updateSelectedDeck,
                              deckSearchParameter: deckSearchParameter,
                              updateSearchParameter: updateSearchParameter,
                            ),
                          ),
                          Expanded(
                              flex:
                                  _panelController.panelPosition < 0.7 ? 5 : 0,
                              child: Container())
                        ],
                      ),
                    ),
                  );
                },
                body: Container(
                  color: Theme.of(context).highlightColor,
                  padding:
                      EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.01),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: _selectedDeck == null
                        ? Container()
                        : Column(
                          children: [
                            DeckViewerView(
                                deck: _selectedDeck!,
                                searchNote: searchNote,
                              ),
                            SizedBox(height: MediaQuery.sizeOf(context).height*0.2,)
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
                        color: Theme.of(context).highlightColor),
                    child: SingleChildScrollView(
                      child: _selectedDeck == null
                          ? Container()
                          : DeckViewerView(
                              deck: _selectedDeck!,
                              searchNote: searchNote,
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
                        deckSearchParameter: deckSearchParameter,
                        updateSearchParameter: updateSearchParameter,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
