import 'dart:convert';

import 'package:auto_route/annotations.dart';
import 'package:digimon_meta_site_flutter/model/deck-view.dart';
import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/provider/deck_provider.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_search_view.dart';
import 'package:digimon_meta_site_flutter/widget/deck/viewer/deck_view_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../model/deck-build.dart';
import '../router.dart';
import 'package:auto_route/auto_route.dart';

import '../service/size_service.dart';
import '../provider/format_deck_count_provider.dart';
import '../provider/user_provider.dart';
import '../service/deck_service.dart';

@RoutePage()
class DeckListPage extends StatefulWidget {
  final String? searchParameterString;

  const DeckListPage({
    super.key,
    @QueryParam('searchParameter') this.searchParameterString,
  });

  @override
  State<DeckListPage> createState() => _DeckListPageState();
}

class _DeckListPageState extends State<DeckListPage> {
  final ScrollController _scrollController = ScrollController();
  DeckSearchParameter deckSearchParameter =
      DeckSearchParameter(isMyDeck: false);
  DeckBuild? _selectedDeck;
  DeckView? selectedDeck;
  late FormatDeckCountProvider formatDeckCountProvider;
  late UserProvider userProvider;

  // DraggableScrollableSheet 관련 변수들
  final DraggableScrollableController _bottomSheetController = DraggableScrollableController();
  double _currentBottomSheetSize = 0.08;
  bool _isBottomSheetExpanded = false;
  
  // 덱 뷰 설정
  int _deckViewRowNumber = 4; // 덱 뷰의 행 수

  @override
  void initState() {
    super.initState();
    if (widget.searchParameterString != null) {
      try {
        Map<String, dynamic> searchMapData = jsonDecode(widget.searchParameterString!);
        deckSearchParameter = DeckSearchParameter(isMyDeck: searchMapData['isMyDeck'] ?? false);
      } catch (e) {
      }
    }
    
    Future.microtask(() {
      formatDeckCountProvider = Provider.of<FormatDeckCountProvider>(context, listen: false);
      userProvider = Provider.of<UserProvider>(context, listen: false);
      
      formatDeckCountProvider.loadDeckCounts();
      
      userProvider.addListener(_onUserLoginStateChanged);
    });

    // 세로 모드에서 초기 위치는 initialChildSize로 설정되므로 별도 애니메이션 불필요
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (MediaQuery.of(context).orientation == Orientation.portrait &&
    //       _bottomSheetController.isAttached) {
    //     _bottomSheetController.animateTo(
    //       0.3,
    //       duration: Duration(milliseconds: 300),
    //       curve: Curves.easeInOut,
    //     );
    //   }
    // });
  }

  void _onUserLoginStateChanged() {
    formatDeckCountProvider.loadDeckCounts();
  }

  void updateSearchParameter() {
    AutoRouter.of(context).navigate(
      DeckListRoute(
          searchParameterString: json.encode(deckSearchParameter.toJson())),
    );
  }

  void updateSelectedDeck(DeckView deckView) {
    _selectedDeck = DeckBuild.deckView(deckView, context);
    setState(() {});
  }

  @override
  void dispose() {
    if (mounted) {
      _scrollController.dispose();
      _bottomSheetController.dispose();
    }
    userProvider.removeListener(_onUserLoginStateChanged);
    super.dispose();
  }

  void searchWithParameter(SearchParameter parameter) {
    final deckProvider = Provider.of<DeckProvider>(context, listen: false);
    final currentDeck = deckProvider.currentDeck;
    
    context.navigateTo(DeckBuilderRoute(
        deck: currentDeck,
        searchParameterString: json.encode(parameter.toJson())));
  }

  // 바텀시트 최소 크기 계산 (헤더가 완전히 보이도록)
  double _calculateMinBottomSheetSize(double screenHeight) {
    const double headerHeight = 80.0; // 헤더 고정 높이
    const double minRatio = 0.08; // 최소 8%
    const double maxRatio = 0.15; // 최대 15%
    
    double calculatedRatio = headerHeight / screenHeight;
    
    // 최소값과 최대값 사이로 제한
    return calculatedRatio.clamp(minRatio, maxRatio);
  }

  void _onBottomSheetChanged(double size) {
    setState(() {
      _currentBottomSheetSize = size;
      _isBottomSheetExpanded = size > 0.8;
    });
  }

  // 덱 검색 메뉴 다이얼로그
  void _showDeckSearchMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 고정 헤더 (드래그 핸들 + 제목)
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 드래그 핸들
                        Center(
                          child: Container(
                            width: 50,
                            height: 5,
                            margin: EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),
                        
                        Row(
                          children: [
                            Icon(Icons.tune, color: Colors.grey[700]),
                            SizedBox(width: 8),
                            Text(
                              '메뉴',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 스크롤 가능한 메뉴 리스트
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 덱 뷰 행 수 조정
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.view_column, color: Colors.purple[600], size: 24),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '한 줄에 표시할 카드 장수',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${_deckViewRowNumber}장',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // 복사해서 새로운 덱 만들기
                          ListTile(
                            leading: Icon(Icons.copy_outlined, color: Colors.blue[600]),
                            title: Text('덱 복사하기'),
                            subtitle: Text('이 덱을 복사해서 새로운 덱 만들기'),
                            onTap: () {
                              Navigator.pop(context);
                              if (_selectedDeck != null) {
                                DeckService().copyDeck(context, _selectedDeck!);
                              }
                            },
                          ),
                          
                          // 덱 내보내기
                          ListTile(
                            leading: Icon(Icons.upload_outlined, color: Colors.purple[600]),
                            title: Text('덱 내보내기'),
                            subtitle: Text('파일로 내보내기'),
                            onTap: () {
                              Navigator.pop(context);
                              if (_selectedDeck != null) {
                                DeckService().showExportDialog(context, _selectedDeck!);
                              }
                            },
                          ),
                          
                          // 이미지 저장
                          ListTile(
                            leading: Icon(Icons.image_outlined, color: Colors.pink[600]),
                            title: Text('덱 이미지 저장'),
                            subtitle: Text('덱을 이미지로 저장'),
                            onTap: () {
                              Navigator.pop(context);
                              if (_selectedDeck != null) {
                                context.navigateTo(DeckImageRoute(deck: _selectedDeck!));
                              }
                            },
                          ),
                          
                          // 플레이그라운드
                          ListTile(
                            leading: Icon(Icons.gamepad_outlined, color: Colors.green[600]),
                            title: Text('플레이그라운드'),
                            subtitle: Text('게임 시뮬레이션으로 테스트'),
                            onTap: () {
                              Navigator.pop(context);
                              if (_selectedDeck != null) {
                                context.navigateTo(GamePlayGroundRoute(deckBuild: _selectedDeck!));
                              }
                            },
                          ),
                          
                          // 대회 제출용 레시피
                          ListTile(
                            leading: Icon(Icons.receipt_long_outlined, color: Colors.teal[600]),
                            title: Text('대회 제출용 레시피'),
                            subtitle: Text('대회용 덱리스트 다운로드'),
                            onTap: () {
                              Navigator.pop(context);
                              if (_selectedDeck != null) {
                                DeckService().downloadDeckReceipt(context, _selectedDeck!);
                              }
                            },
                          ),
                          
                          // TTS 파일 내보내기 (관리자만)
                          if (userProvider.hasManagerRole())
                            ListTile(
                              leading: Icon(Icons.videogame_asset_outlined, color: Colors.indigo[600]),
                              title: Text('TTS 파일 내보내기'),
                              subtitle: Text('Table Top Simulator용 파일'),
                              onTap: () async {
                                Navigator.pop(context);
                                if (_selectedDeck != null) {
                                  await DeckService().exportToTTSFile(_selectedDeck!);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isPortrait) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: Stack(
              children: [
                // 메인 컨텐츠 영역 (선택된 덱 표시)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: constraints.maxHeight * _currentBottomSheetSize,
                  child: SafeArea(
                    child: Container(
                      color: Colors.grey[50],
                      padding: EdgeInsets.all(SizeService.paddingSize(context)),
                      child: _selectedDeck == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.style,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '덱을 선택해주세요',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '아래 검색 패널에서 덱을 찾아보세요',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                children: [
                                  DeckViewerView(
                                    deck: _selectedDeck!,
                                    searchWithParameter: searchWithParameter,
                                    fixedRowNumber: _deckViewRowNumber,
                                  ),
                                  SizedBox(
                                    height: MediaQuery.sizeOf(context).height * 0.2,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
                
                // DraggableScrollableSheet으로 검색 패널 구현 - 초기 크기를 크게 하여 덱 리스트가 바로 보이도록 함
                DraggableScrollableSheet(
                  controller: _bottomSheetController,
                  initialChildSize: 0.3,
                  minChildSize: _calculateMinBottomSheetSize(constraints.maxHeight),
                  maxChildSize: 1.0,
                  snap: false,
                  builder: (context, scrollController) {
                    return NotificationListener<DraggableScrollableNotification>(
                      onNotification: (notification) {
                        _onBottomSheetChanged(notification.extent);
                        return true;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: CustomScrollView(
                          controller: scrollController,
                          physics: ClampingScrollPhysics(),
                          slivers: [
                            // 고정된 헤더 영역 (항상 표시)
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _BottomSheetHeaderDelegate(
                                minHeight: 80,
                                maxHeight: 80,
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  ),
                                  child: Column(
                                    children: [
                                      // 드래그 핸들
                                      Container(
                                        width: 50,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[400],
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      
                                      // 덱 정보 요약 및 메뉴
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                             // 덱 카운트 요약 (덱빌더와 동일)
                                             Row(
                                               children: [
                                                 Container(
                                                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                   decoration: BoxDecoration(
                                                     color: Colors.blue[50],
                                                     borderRadius: BorderRadius.circular(12),
                                                   ),
                                                   child: Text(
                                                     '메인: ${_selectedDeck?.deckCount ?? 0}장',
                                                     style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                                                   ),
                                                 ),
                                                 SizedBox(width: 8),
                                                 Container(
                                                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                   decoration: BoxDecoration(
                                                     color: Colors.orange[50],
                                                     borderRadius: BorderRadius.circular(12),
                                                   ),
                                                   child: Text(
                                                     '디지타마: ${_selectedDeck?.tamaCount ?? 0}장',
                                                     style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                                                   ),
                                                 ),
                                               ],
                                             ),
                                             
                                             // 메뉴 버튼 (덱빌더와 동일)
                                             Tooltip(
                                               message: '덱 메뉴',
                                               child: Material(
                                                 color: Colors.transparent,
                                                 child: InkWell(
                                                   borderRadius: BorderRadius.circular(12),
                                                   onTap: () => _showDeckSearchMenu(context),
                                                   child: Container(
                                                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                     decoration: BoxDecoration(
                                                       color: Theme.of(context).primaryColor.withOpacity(0.1),
                                                       borderRadius: BorderRadius.circular(12),
                                                       border: Border.all(
                                                         color: Theme.of(context).primaryColor.withOpacity(0.2),
                                                         width: 1,
                                                       ),
                                                     ),
                                                     child: Row(
                                                       mainAxisSize: MainAxisSize.min,
                                                       children: [
                                                         Icon(
                                                           Icons.menu,
                                                           color: Theme.of(context).primaryColor,
                                                           size: 16,
                                                         ),
                                                         SizedBox(width: 4),
                                                         Text(
                                                           '메뉴',
                                                           style: TextStyle(
                                                             fontSize: 12,
                                                             color: Theme.of(context).primaryColor,
                                                             fontWeight: FontWeight.w500,
                                                           ),
                                                         ),
                                                       ],
                                                     ),
                                                   ),
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ),
                                       ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            // 확장 가능한 컨텐츠 영역 (검색 패널) - 항상 표시하여 덱 리스트에 쉽게 접근할 수 있도록 함
                            SliverToBoxAdapter(
                              child: Divider(height: 1, color: Colors.grey[300]),
                            ),
                            
                            // 덱 검색 패널 - 명확한 높이 제약을 주어 무한 영역 사이즈 문제 해결
                            SliverToBoxAdapter(
                              child: Container(
                                height: constraints.maxHeight * 0.6, // 바텀시트 높이의 60%
                                padding: EdgeInsets.all(SizeService.paddingSize(context)),
                                child: DeckSearchView(
                                  deckUpdate: updateSelectedDeck,
                                  deckSearchParameter: deckSearchParameter,
                                  updateSearchParameter: updateSearchParameter,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      );
    } else {
      // 가로 모드 (기존 코드 유지, 나중에 개선)
      return Padding(
        padding: EdgeInsets.all(SizeService.paddingSize(context)),
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
                          searchWithParameter: searchWithParameter,
                          fixedRowNumber: _deckViewRowNumber,
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
}

// SliverPersistentHeader를 위한 헤더 델리게이트
class _BottomSheetHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _BottomSheetHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_BottomSheetHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
