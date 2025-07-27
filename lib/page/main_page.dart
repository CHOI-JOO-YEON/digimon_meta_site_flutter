import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:digimon_meta_site_flutter/service/user_service.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:html' as html;
import '../provider/user_provider.dart';
import '../provider/deck_provider.dart';
import '../provider/header_toggle_provider.dart';
import '../model/deck-build.dart';

@RoutePage()
class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  void openOAuthPopup() {
    String baseUrl = const String.fromEnvironment('SERVER_URL');
    String url = '$baseUrl/oauth2/authorization/kakao';
    String windowName = 'OAuthLogin';
    String windowFeatures = 'width=800,height=600';
    html.window.open(url, windowName, windowFeatures);
  }

    void openLogoutPopup() {
    String baseUrl = const String.fromEnvironment('SERVER_URL');
    String url = '$baseUrl/logout';
    String windowName = 'Logout';
    String windowFeatures = 'width=800,height=600';
    html.window.open(url, windowName, windowFeatures);
  }

  final CardOverlayService _cardOverlayService = CardOverlayService();

  @override
  Widget build(BuildContext context) {
    double fontSize = SizeService.bodyFontSize(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallHeight = screenHeight < 600; // 세로 높이가 작은 화면 감지
    final isSmallWidth = screenWidth < 400; // 세로 너비가 작은 화면 감지
    final isMobilePortrait = isPortrait && screenWidth < 600; // 모바일 세로모드 감지
    
    return AutoTabsRouter.tabBar(
      physics: const NeverScrollableScrollPhysics(),
      routes: [DeckBuilderRoute(deck: null), DeckListRoute(), CollectRoute(), InfoRoute()],
      builder: (context, child, controller) {
        controller.addListener(() {
          if (controller.indexIsChanging) {
            _cardOverlayService.removeAllOverlays();
          }
        });

        // 현재 탭이 덱 빌더인지 확인
        bool isDeckBuilderTab = controller.index == 0;

        return Consumer<HeaderToggleProvider>(
          builder: (context, headerProvider, _) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: Column(
                children: [
                  // 메인 헤더 (숨김 상태에서는 최소한의 공간만 표시)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: headerProvider.isHeaderVisible 
                      ? (isMobilePortrait 
                          ? (isSmallHeight ? 100 : 120) // 모바일 세로모드에서 높이 줄임
                          : SizeService.headerHeight(context))
                      : (isSmallHeight ? 40 : 50), // 최소한의 공간 유지
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          const Color(0xFFF8FAFC),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(0, 4),
                          blurRadius: 12,
                        ),
                      ],
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: ClipRect(
                      child: headerProvider.isHeaderVisible 
                        ? Consumer2<UserProvider, DeckProvider>(
                            builder: (context, userProvider, deckProvider, child) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobilePortrait 
                                    ? (isSmallWidth ? 8 : 12) // 모바일에서 패딩 줄임
                                    : SizeService.paddingSize(context) * 2,
                                ),
                                child: isPortrait
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // 세로모드에서 로그인 정보와 설정 버튼
                                          Container(
                                            margin: EdgeInsets.only(
                                              bottom: isMobilePortrait ? 2 : 4,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                if (userProvider.isLogin)
                                                  Expanded(
                                                    flex: 3,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          '${userProvider.nickname}',
                                                          style: TextStyle(
                                                            fontSize: isMobilePortrait 
                                                              ? fontSize * 0.9 // 모바일에서 폰트 크기 줄임
                                                              : fontSize,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        Text(
                                                          '#${(userProvider.userNo! - 3).toString().padLeft(4, '0')}',
                                                          style: TextStyle(
                                                            fontSize: isMobilePortrait 
                                                              ? fontSize * 0.7 // 모바일에서 작게
                                                              : fontSize * 0.8,
                                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                
                                                Expanded(
                                                  flex: userProvider.isLogin ? 2 : 1,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      // 로그인/로그아웃 버튼
                                                      Flexible(
                                                        child: AnimatedContainer(
                                                          duration: const Duration(milliseconds: 200),
                                                          child: Material(
                                                            color: Colors.transparent,
                                                            child: InkWell(
                                                              borderRadius: BorderRadius.circular(
                                                                isMobilePortrait ? 16 : 20,
                                                              ),
                                                              onTap: () {
                                                                userProvider.isLogin
                                                                    ? UserService().logoutWithPopup(context)
                                                                    : openOAuthPopup();
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(
                                                                  horizontal: isMobilePortrait ? 10 : 16,
                                                                  vertical: isMobilePortrait ? 6 : 8,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  gradient: userProvider.isLogin
                                                                      ? LinearGradient(
                                                                          colors: [
                                                                            const Color(0xFFEF4444),
                                                                            const Color(0xFFDC2626),
                                                                          ],
                                                                        )
                                                                      : LinearGradient(
                                                                          colors: [
                                                                            Theme.of(context).colorScheme.primary,
                                                                            const Color(0xFF1D4ED8),
                                                                          ],
                                                                        ),
                                                                  borderRadius: BorderRadius.circular(
                                                                    isMobilePortrait ? 16 : 20,
                                                                  ),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: (userProvider.isLogin 
                                                                          ? const Color(0xFFEF4444) 
                                                                          : Theme.of(context).colorScheme.primary)
                                                                          .withOpacity(0.3),
                                                                      offset: const Offset(0, 4),
                                                                      blurRadius: 8,
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Text(
                                                                  userProvider.isLogin ? '로그아웃' : '로그인',
                                                                  style: TextStyle(
                                                                    fontSize: isMobilePortrait 
                                                                      ? fontSize * 0.8 // 모바일에서 작게
                                                                      : fontSize * 0.9,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.w600,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: isMobilePortrait ? 6 : 12),
                                                      // 설정 버튼
                                                      _buildIconButton(
                                                        onPressed: () {
                                                          DeckBuild? deck = deckProvider.currentDeck;
                                                          if (deck == null) {
                                                            deck = DeckBuild(context);
                                                          }
                                                          DeckService().showDeckSettings(
                                                              context, deck, () {
                                                            setState(() {});
                                                          });
                                                        },
                                                        icon: Icons.settings,
                                                        tooltip: '덱 설정',
                                                        context: context,
                                                        isMobile: isMobilePortrait,
                                                      ),
                                                      
                                                      SizedBox(width: isMobilePortrait ? 4 : 8),
                                                      // 헤더 접기 버튼
                                                      _buildIconButton(
                                                        onPressed: () => headerProvider.hideHeader(),
                                                        icon: Icons.keyboard_arrow_up,
                                                        tooltip: '메뉴 접기',
                                                        context: context,
                                                        isMobile: isMobilePortrait,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // 세로모드에서 탭바
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                              vertical: isMobilePortrait ? 4 : 8, 
                                              horizontal: isMobilePortrait ? 4 : 8,
                                            ),
                                            padding: EdgeInsets.all(isMobilePortrait ? 2 : 4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white,
                                                  const Color(0xFFF8FAFC),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                isMobilePortrait ? 12 : 16,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.08),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                              border: Border.all(
                                                color: Colors.grey.withOpacity(0.1),
                                                width: 1,
                                              ),
                                            ),
                                            child: TabBar(
                                              controller: controller,
                                              labelStyle: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: isMobilePortrait 
                                                  ? fontSize * 0.8 // 모바일에서 탭 폰트 크기 줄임
                                                  : fontSize * 0.85,
                                              ),
                                              unselectedLabelStyle: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: isMobilePortrait 
                                                  ? fontSize * 0.8
                                                  : fontSize * 0.85,
                                              ),
                                              indicator: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Theme.of(context).colorScheme.primary,
                                                    const Color(0xFF1D4ED8),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(
                                                  isMobilePortrait ? 10 : 12,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              padding: EdgeInsets.zero,
                                              labelPadding: EdgeInsets.zero,
                                              indicatorPadding: EdgeInsets.zero,
                                              labelColor: Colors.white,
                                              unselectedLabelColor: Colors.grey.shade600,
                                              dividerColor: Colors.transparent,
                                              splashFactory: NoSplash.splashFactory,
                                              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                                (Set<MaterialState> states) {
                                                  return Colors.transparent;
                                                },
                                              ),
                                              tabs: [
                                                _buildModernTabItem(context, Icons.build_outlined, Icons.build, 'Builder', isPortrait, controller.index == 0, isMobile: isMobilePortrait),
                                                _buildModernTabItem(context, Icons.list_outlined, Icons.list, 'List', isPortrait, controller.index == 1, isMobile: isMobilePortrait),
                                                _buildModernTabItem(context, Icons.collections_bookmark_outlined, Icons.collections_bookmark_rounded, 'Collect', isPortrait, controller.index == 2, isMobile: isMobilePortrait),
                                                _buildModernTabItem(context, Icons.info_outline, Icons.info, 'Info', isPortrait, controller.index == 3, isMobile: isMobilePortrait),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: ResponsiveRowColumn(
                                              layout: ResponsiveBreakpoints.of(context)
                                                      .smallerThan('4K')
                                                  ? ResponsiveRowColumnType.COLUMN
                                                  : ResponsiveRowColumnType.ROW,
                                              rowMainAxisAlignment: MainAxisAlignment.start,
                                              rowCrossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              columnMainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              columnCrossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (userProvider.isLogin)
                                                  ResponsiveRowColumnItem(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          '${userProvider.nickname}',
                                                          style:
                                                              TextStyle(
                                                                fontSize: fontSize,
                                                                fontWeight: FontWeight.w600,
                                                              ),
                                                        ),
                                                        Text(
                                                          '#${(userProvider.userNo! - 3).toString().padLeft(4, '0')}',
                                                          style:
                                                              TextStyle(
                                                                fontSize: fontSize * 0.8,
                                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ResponsiveRowColumnItem(
                                                  child: SizedBox(
                                                    width: MediaQuery.sizeOf(context).width *
                                                        0.009,
                                                  ),
                                                ),
                                                ResponsiveRowColumnItem(
                                                  child: AnimatedContainer(
                                                    duration: const Duration(milliseconds: 200),
                                                    child: Material(
                                                      color: Colors.transparent,
                                                      child: InkWell(
                                                        borderRadius: BorderRadius.circular(20),
                                                        onTap: () {
                                                          userProvider.isLogin
                                                              ? UserService().logoutWithPopup(context)
                                                              : openOAuthPopup();
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 16,
                                                            vertical: 8,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            gradient: userProvider.isLogin
                                                                ? LinearGradient(
                                                                    colors: [
                                                                      const Color(0xFFEF4444),
                                                                      const Color(0xFFDC2626),
                                                                    ],
                                                                  )
                                                                : LinearGradient(
                                                                    colors: [
                                                                      Theme.of(context).colorScheme.primary,
                                                                      const Color(0xFF1D4ED8),
                                                                    ],
                                                                  ),
                                                            borderRadius: BorderRadius.circular(20),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: (userProvider.isLogin 
                                                                    ? const Color(0xFFEF4444) 
                                                                    : Theme.of(context).colorScheme.primary)
                                                                    .withOpacity(0.3),
                                                                offset: const Offset(0, 4),
                                                                blurRadius: 8,
                                                              ),
                                                            ],
                                                          ),
                                                          child: Text(
                                                            userProvider.isLogin ? '로그아웃' : '로그인',
                                                            style: TextStyle(
                                                              fontSize: fontSize * 0.9,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    const Color(0xFFF8FAFC),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.08),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  width: 1,
                                                ),
                                              ),
                                              child: TabBar(
                                                controller: controller,
                                                labelStyle: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: fontSize * 0.85,
                                                ),
                                                unselectedLabelStyle: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: fontSize * 0.85,
                                                ),
                                                indicator: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Theme.of(context).colorScheme.primary,
                                                      const Color(0xFF1D4ED8),
                                                    ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                padding: EdgeInsets.zero,
                                                labelPadding: EdgeInsets.zero,
                                                indicatorPadding: EdgeInsets.zero,
                                                labelColor: Colors.white,
                                                unselectedLabelColor: Colors.grey.shade600,
                                                dividerColor: Colors.transparent,
                                                splashFactory: NoSplash.splashFactory,
                                                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                                  (Set<MaterialState> states) {
                                                    return Colors.transparent;
                                                  },
                                                ),
                                                tabs: [
                                                  _buildModernTabItem(context, Icons.build_outlined, Icons.build, 'Builder', isPortrait, controller.index == 0),
                                                  _buildModernTabItem(context, Icons.list_outlined, Icons.list, 'List', isPortrait, controller.index == 1),
                                                  _buildModernTabItem(context, Icons.collections_bookmark_outlined, Icons.collections_bookmark_rounded, 'Collect', isPortrait, controller.index == 2),
                                                  _buildModernTabItem(context, Icons.info_outline, Icons.info, 'Info', isPortrait, controller.index == 3),
                                                ],
                                              ),
                                            ),
                                          ),
                                                                                        Expanded(
                                                  flex: 1,
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      _buildIconButton(
                                                        onPressed: () {
                                                          DeckBuild? deck = deckProvider.currentDeck;
                                                          if (deck == null) {
                                                            deck = DeckBuild(context);
                                                          }
                                                          DeckService().showDeckSettings(
                                                              context, deck, () {
                                                            setState(() {});
                                                          });
                                                        },
                                                        icon: Icons.settings,
                                                        tooltip: '덱 설정',
                                                        context: context,
                                                      ),
                                                      
                                                      const SizedBox(width: 12),
                                                      _buildIconButton(
                                                        onPressed: () => headerProvider.hideHeader(),
                                                        icon: Icons.keyboard_arrow_up,
                                                        tooltip: '메뉴 접기',
                                                        context: context,
                                                      ),
                                                    ],
                                                  )),
                                        ],
                                      ),
                              );
                            },
                          )
                        : // 헤더가 숨겨진 상태에서는 최소한의 바만 표시
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeService.paddingSize(context) * 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () => headerProvider.showHeader(),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Theme.of(context).colorScheme.primary,
                                              const Color(0xFF1D4ED8),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                              offset: const Offset(0, 4),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.keyboard_arrow_down,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '메뉴',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
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
                    ),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: child,
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabItem(BuildContext context, IconData icon, String label, bool isPortrait) {
    return Tab(
      height: isPortrait ? 50 : 56,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: isPortrait ? 24 : 22,
          ),
          if (!isPortrait) const SizedBox(height: 4),
          if (!isPortrait)
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String tooltip,
    required BuildContext context,
    bool isMobile = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            child: Icon(
              icon,
              size: isMobile ? SizeService.largeIconSize(context) * 0.8 : SizeService.largeIconSize(context),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTabItem(BuildContext context, IconData outlinedIcon, IconData filledIcon, String label, bool isPortrait, bool isSelected, {bool isMobile = false}) {
    return Tab(
      height: isMobile ? 48 : 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? filledIcon : outlinedIcon,
                key: ValueKey(isSelected),
                size: isMobile ? 22 : 24,
              ),
            ),
            if (!isPortrait) const SizedBox(height: 4),
            if (!isPortrait)
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
