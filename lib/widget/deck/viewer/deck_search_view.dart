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
import '../../../provider/format_deck_count_provider.dart';

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
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {
          widget.deckSearchParameter.isMyDeck = _tabController.index == 1;
          // 로딩이 완료된 후에만 파라미터 업데이트 호출
          if (!isLoading) {
            widget.updateSearchParameter();
          }
        });
      }
    });

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
      
      // Load deck counts when formats are loaded
      Provider.of<FormatDeckCountProvider>(context, listen: false).loadDeckCounts();
      
      isLoading = false;
      setState(() {});
    });
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
                // 모던한 세그먼트 컨트롤
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: SizeService.paddingSize(context),
                    vertical: SizeService.paddingSize(context) * 0.5,
                  ),
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFF1F5F9),
                        const Color(0xFFE2E8F0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                        spreadRadius: 0,
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // 전체 덱 버튼
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _tabController.animateTo(0);
                            widget.deckSearchParameter.isMyDeck = false;
                            widget.updateSearchParameter();
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: _tabController.index == 0
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFF3B82F6),
                                        const Color(0xFF2563EB),
                                      ],
                                    )
                                  : null,
                              color: _tabController.index == 0
                                  ? null
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _tabController.index == 0
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                        spreadRadius: 0,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.public,
                                  size: 18,
                                  color: _tabController.index == 0
                                      ? Colors.white
                                      : const Color(0xFF64748B),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '전체 덱',
                                  style: TextStyle(
                                    fontSize: SizeService.bodyFontSize(context) * 0.9,
                                    fontWeight: _tabController.index == 0
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: _tabController.index == 0
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // 나의 덱 버튼
                      Expanded(
                        child: GestureDetector(
                          onTap: _isDisabled[1]
                              ? null
                              : () {
                                  _tabController.animateTo(1);
                                  widget.deckSearchParameter.isMyDeck = true;
                                  widget.updateSearchParameter();
                                },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: _tabController.index == 1 && !_isDisabled[1]
                                  ? LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFF7C3AED),
                                        const Color(0xFF6D28D9),
                                      ],
                                    )
                                  : null,
                              color: _tabController.index == 1 && !_isDisabled[1]
                                  ? null
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _tabController.index == 1 && !_isDisabled[1]
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF7C3AED).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                        spreadRadius: 0,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isDisabled[1] ? Icons.lock_outline : Icons.person,
                                  size: 18,
                                  color: _isDisabled[1]
                                      ? const Color(0xFFCBD5E1)
                                      : (_tabController.index == 1
                                          ? Colors.white
                                          : const Color(0xFF64748B)),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  '나의 덱',
                                  style: TextStyle(
                                    fontSize: SizeService.bodyFontSize(context) * 0.9,
                                    fontWeight: _tabController.index == 1 && !_isDisabled[1]
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: _isDisabled[1]
                                        ? const Color(0xFFCBD5E1)
                                        : (_tabController.index == 1
                                            ? Colors.white
                                            : const Color(0xFF64748B)),
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
