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
import '../widget/common/deck_menu_dialog.dart';
import '../widget/common/bottom_sheet_header.dart';

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
    // 로딩 중이거나 초기화 중에는 라우팅 변경을 방지
    if (!mounted) return;
    
    // URL 파라미터만 업데이트하고 페이지 리다이렉션은 하지 않음
    // AutoRouter.of(context).navigate(
    //   DeckListRoute(
    //       searchParameterString: json.encode(deckSearchParameter.toJson())),
    // );
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
    if (_selectedDeck != null) {
      DeckMenuDialog.show(
        context: context,
        deck: _selectedDeck!,
        menuType: DeckMenuType.deckList,
        deckViewRowNumber: _deckViewRowNumber,
        onRowNumberChanged: (value) {
          setState(() {
            _deckViewRowNumber = value;
          });
        },
      );
    }
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
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
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
                              physics: AlwaysScrollableScrollPhysics(),
                              child: DeckViewerView(
                                deck: _selectedDeck!,
                                searchWithParameter: searchWithParameter,
                                fixedRowNumber: _deckViewRowNumber,
                                showMenuBar: false, // 세로모드에서는 메뉴바 숨김
                                showSlider: false, // 세로모드에서는 슬라이더 숨김 (메뉴에서 조정)
                                showButtons: false, // 세로모드에서는 버튼 숨김
                                showDeckInfo: true, // 세로모드에서는 덱 정보 표시
                              ),
                            ),
                    ),
                  ),
                ),
                
                // DraggableScrollableSheet으로 검색 패널 구현 - 덱빌더와 동일한 초기 사이즈 사용
                DraggableScrollableSheet(
                  controller: _bottomSheetController,
                  initialChildSize: _calculateMinBottomSheetSize(constraints.maxHeight),
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
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        const Color(0xFFF8FAFC),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: BottomSheetHeader(
                                    deck: _selectedDeck,
                                    onMenuTap: () => _showDeckSearchMenu(context),
                                    showDragHandle: true,
                                    enableMouseDrag: false,
                                    showSaveWarning: false,
                                  ),
                                ),
                              ),
                            ),
                            
                            // 확장 가능한 컨텐츠 영역 (검색 패널) - 항상 표시하여 덱 리스트에 쉽게 접근할 수 있도록 함
                            SliverToBoxAdapter(
                              child: Divider(height: 1, color: Colors.grey[300]),
                            ),
                            
                            // 덱 검색 패널 - 동적 높이 조정
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                // 바텀시트 확장 정도에 따라 동적 높이 계산
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight * 0.6,
                                  maxHeight: constraints.maxHeight * (_currentBottomSheetSize > 0.8 ? 0.95 : 0.8),
                                ),
                                padding: EdgeInsets.all(SizeService.paddingSize(context)),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white,
                                      const Color(0xFFF8FAFC),
                                    ],
                                  ),
                                ),
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
      // 가로 모드 레이아웃 개선 - 모바일 반응형 추가
      final screenWidth = MediaQuery.of(context).size.width;
      final isTablet = screenWidth >= 768 && screenWidth < 1024;
      final isSmallLaptop = screenWidth >= 1024 && screenWidth < 1200;
      final isMobileDesktop = screenWidth < 768;
      
      // 동적 비율 계산
      int deckFlex, searchFlex;
      double spacing;
      
      if (isMobileDesktop) {
        // 모바일 데스크톱에서는 더 균형잡힌 비율
        deckFlex = 1;
        searchFlex = 1;
        spacing = MediaQuery.sizeOf(context).width * 0.005; // 더 작은 간격
      } else if (isTablet) {
        // 태블릿에서는 약간 조정된 비율
        deckFlex = 5;
        searchFlex = 3;
        spacing = MediaQuery.sizeOf(context).width * 0.008;
      } else if (isSmallLaptop) {
        // 작은 노트북에서는 기본 비율에 가깝게
        deckFlex = 3;
        searchFlex = 2;
        spacing = MediaQuery.sizeOf(context).width * 0.01;
      } else {
        // 큰 화면에서는 기존 비율 유지
        deckFlex = 3;
        searchFlex = 2;
        spacing = MediaQuery.sizeOf(context).width * 0.01;
      }
      
      return Padding(
        padding: EdgeInsets.all(
          isMobileDesktop 
            ? SizeService.paddingSize(context) * 0.5 // 모바일에서 패딩 줄임
            : SizeService.paddingSize(context)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: deckFlex,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFF8FAFC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isMobileDesktop ? 16 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: isMobileDesktop ? 12 : 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isMobileDesktop ? 16 : 20),
                  child: SingleChildScrollView(
                    child: _selectedDeck == null
                        ? Container(
                            height: 400,
                            child: Center(
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
                                    '오른쪽 검색 패널에서 덱을 찾아보세요',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _selectedDeck != null 
                            ? DeckViewerView(
                                deck: _selectedDeck!,
                                searchWithParameter: searchWithParameter,
                                fixedRowNumber: null, // 가로모드에서는 슬라이더를 통해 조정 가능
                                showMenuBar: true, // 가로모드에서는 메뉴바 표시
                                showSlider: true, // 가로모드에서는 슬라이더 표시
                                showButtons: true, // 가로모드에서는 버튼 표시
                              )
                            : Container(
                                height: 400,
                                child: Center(
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
                                        '오른쪽 검색 패널에서 덱을 찾아보세요',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                  ),
                ),
              ),
            ),
            SizedBox(width: spacing),
            Expanded(
              flex: searchFlex,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFF8FAFC),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isMobileDesktop ? 16 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: isMobileDesktop ? 12 : 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(
                    isMobileDesktop 
                      ? SizeService.paddingSize(context) * 0.7 // 모바일에서 내부 패딩 줄임
                      : SizeService.paddingSize(context)
                  ),
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
