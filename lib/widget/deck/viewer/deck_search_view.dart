import 'package:digimon_meta_site_flutter/model/deck.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/page/deck_list_page.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_list_viewer.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/my_deck_list_viewer.dart';
import 'package:flutter/material.dart';

import '../../../model/format.dart';

class DeckSearchView extends StatefulWidget {
  final Function(DeckResponseDto) deckUpdate;

  const DeckSearchView({super.key, required this.deckUpdate});

  @override
  State<DeckSearchView> createState() => _DeckSearchViewState();
}

class _DeckSearchViewState extends State<DeckSearchView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FormatDto> formats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Future.delayed(const Duration(seconds: 0), () async {
      formats = await DeckService().getAllFormat();
      isLoading = false;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '전체 덱'),
                  Tab(text: '나의 덱'),
                ],
              ),
              Expanded(
                child: TabBarView(controller: _tabController, children: [
                 DeckListViewer(formatList: formats, deckUpdate: widget.deckUpdate),
                  MyDeckListViewer(formatList: formats, deckUpdate: widget.deckUpdate,)
                  // Center(child: Text('Content of Tab 2')),
                ]),
              )
            ],
          );
  }
}
