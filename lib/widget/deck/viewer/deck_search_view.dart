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
  
  // 각 탭별 선택된 덱 저장
  DeckView? _selectedAllDeck;
  DeckView? _selectedMyDeck;
  
  // 각 탭별 검색 파라미터 분리
  late DeckSearchParameter _allDeckSearchParameter;
  late DeckSearchParameter _myDeckSearchParameter;

  void updateSelectFormat(FormatDto formatDto) {
    selectedFormat = formatDto;
    _allDeckSearchParameter.formatId = formatDto.formatId;
    _myDeckSearchParameter.formatId = formatDto.formatId;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    
    // 검색 파라미터 초기화
    _allDeckSearchParameter = DeckSearchParameter(isMyDeck: false);
    _myDeckSearchParameter = DeckSearchParameter(isMyDeck: true);
    
    // 초기 탭 설정
    final initialIndex = widget.deckSearchParameter.isMyDeck ? 1 : 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {
          // 탭 전환 시 선택된 덱 복원
          if (_tabController.index == 0 && _selectedAllDeck != null) {
            widget.deckUpdate(_selectedAllDeck!);
          } else if (_tabController.index == 1 && _selectedMyDeck != null) {
            widget.deckUpdate(_selectedMyDeck!);
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
      
      // 각 검색 파라미터에 formatId 설정
      _allDeckSearchParameter.formatId = selectedFormat!.formatId;
      _myDeckSearchParameter.formatId = selectedFormat!.formatId;
      
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
    //     MediaQuery.orientationOf(context) == Orientation.portrait;
    // double fontSize = min(MediaQuery.sizeOf(context).width * 0.009, 15);
    // if (isPortrait) {
    //   fontSize *= 2;
    // }
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Consumer<UserProvider>(builder: (context, userProvider, child) {
            _isDisabled[1] = !userProvider.isLogin;
            // 로그인하지 않은 경우 전체 덱 탭으로 강제 이동
            if (!userProvider.isLogin && _tabController.index == 1) {
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
                      deckUpdate: (deck) {
                        _selectedAllDeck = deck;
                        widget.deckUpdate(deck);
                      },
                      selectedFormat: selectedFormat!,
                      updateSelectFormat: updateSelectFormat,
                      deckSearchParameter: _allDeckSearchParameter,
                      updateSearchParameter: () {},
                    ),
                    MyDeckListViewer(
                      formatList: formats,
                      deckUpdate: (deck) {
                        _selectedMyDeck = deck;
                        widget.deckUpdate(deck);
                      },
                      selectedFormat: selectedFormat!,
                      updateSelectFormat: updateSelectFormat,
                      deckSearchParameter: _myDeckSearchParameter,
                      updateSearchParameter: () {},
                    )
                  ]),
                )
              ],
            );
          });
  }
}
