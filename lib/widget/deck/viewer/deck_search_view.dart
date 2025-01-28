import 'dart:math';

import 'package:digimon_meta_site_flutter/model/deck-view.dart';
import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_list_viewer.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/my_deck_list_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/format.dart';
import '../../../provider/user_provider.dart';

class DeckSearchView extends StatefulWidget {
  final Function(DeckView) deckUpdate;
  final DeckSearchParameter deckSearchParameter;
  final VoidCallback updateSearchParameter;

  const DeckSearchView(
      {super.key,
      required this.deckUpdate,
      required this.deckSearchParameter,
      required this.updateSearchParameter});

  @override
  State<DeckSearchView> createState() => _DeckSearchViewState();
}

class _DeckSearchViewState extends State<DeckSearchView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FormatDto> formats = [];
  FormatDto? selectedFormat;
  bool isLoading = true;
  List<bool> _isDisabled = [false, false];

  void updateSelectFormat(FormatDto formatDto) {
    selectedFormat = formatDto;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(onTap);

    Future.delayed(const Duration(seconds: 0), () async {
      formats = await DeckService().getAllFormat();
      if (formats.isEmpty) {
        formats.add(new FormatDto(
            formatId: 1,
            name: '테스트',
            startDate: DateTime.now(),
            endDate: DateTime.now(),
            isOnlyEn: false));
      }
      selectedFormat = formats.first;
      for (var format in formats) {
        if (!format.isOnlyEn!) {
          selectedFormat = format;
          break;
        }
      }
      isLoading = false;

      setState(() {});
    });
  }

  onTap() {
    if (_isDisabled[_tabController.index]) {
      int index = _tabController.previousIndex;
      setState(() {
        _tabController.index = index;
      });
    }
  }

  @override
  void dispose() {
    if (mounted) {
      _tabController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final isPortrait =
    //     MediaQuery.of(context).orientation == Orientation.portrait;
    // double fontSize = min(MediaQuery.sizeOf(context).width * 0.009, 15);
    // if (isPortrait) {
    //   fontSize *= 2;
    // }
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Consumer<UserProvider>(builder: (context, userProvider, child) {
            _isDisabled[1] = !userProvider.isLogin;
            _tabController.index=widget.deckSearchParameter.isMyDeck?1:0;
            if (!userProvider.isLogin) {
              _tabController.index = 0;
            }

            return Column(
              children: [
                TabBar(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Text(
                        '전체 덱',
                        style: TextStyle(fontSize: SizeService.bodyFontSize(context)),
                      ),
                      
                    ),
                    Tab(
                      child: Text(
                        '나의 덱',
                        style: TextStyle(
                            fontSize: SizeService.bodyFontSize(context),
                            color: _isDisabled[1] ? Colors.grey : Colors.black),
                      ),
                    ),
                    
                  ],
                  onTap: (index) {
                    widget.deckSearchParameter.isMyDeck = index == 1;
                    widget.updateSearchParameter();
                  },
                ),
                Expanded(
                  child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController, children: [
                    DeckListViewer(
                      formatList: formats,
                      deckUpdate: widget.deckUpdate,
                      selectedFormat: selectedFormat!,
                      updateSelectFormat: updateSelectFormat,
                      deckSearchParameter: widget.deckSearchParameter,
                      updateSearchParameter: widget.updateSearchParameter,
                    ),
                    MyDeckListViewer(
                      formatList: formats,
                      deckUpdate: widget.deckUpdate,
                      selectedFormat: selectedFormat!,
                      updateSelectFormat: updateSelectFormat,
                      deckSearchParameter: widget.deckSearchParameter,
                      updateSearchParameter: widget.updateSearchParameter,
                    )
                  ]),
                )
              ],
            );
          });
  }
}
