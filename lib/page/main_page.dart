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
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallHeight = screenHeight < 600; // 세로 높이가 작은 화면 감지
    final isSmallWidth = screenWidth < 400; // 세로 너비가 작은 화면 감지
    final isMobilePortrait = isPortrait && screenWidth < 768; // 모바일/태블릿 세로모드 감지 (768px 미만)
    final isTabletPortrait = isPortrait && screenWidth >= 600 && screenWidth < 1024; // 태블릿 세로모드 감지
    
    return AutoTabsRouter.tabBar(
      physics: const NeverScrollableScrollPhysics(),
      routes: [DeckBuilderRoute(deck: null), DeckListRoute(), CollectRoute(), InfoRoute()],
      builder: (context, child, controller) {
        controller.addListener(() {
          if (controller.indexIsChanging && mounted) {
            _cardOverlayService.removeAllOverlays();
          }
        });

        // 현재 탭이 덱 빌더인지 확인
        bool isDeckBuilderTab = controller.index == 0;

        return Consumer<HeaderToggleProvider>(
          builder: (context, headerProvider, _) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              bottomNavigationBar: isPortrait ? _buildBottomTabBar(context, controller) : null,
              body: SafeArea(
                child: Column(
                  children: [
                    // 메인 헤더 (숨김 상태에서는 최소한의 공간만 표시)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: (isMobilePortrait || isTabletPortrait)
                        ? null // 세로모드에서는 자동 높이로 변경
                        : SizeService.headerHeight(context),
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
                      child: Consumer2<UserProvider, DeckProvider>(
                            builder: (context, userProvider, deckProvider, child) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: (isMobilePortrait || isTabletPortrait)
                                    ? (isSmallWidth ? 8 : (isTabletPortrait ? 16 : 12)) // 태블릿 세로모드에서 적절한 패딩
                                    : SizeService.paddingSize(context) * 2,
                                ),
                                child: isPortrait
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // 세로모드에서 로그인 정보와 설정 버튼
                                          Container(
                                            margin: EdgeInsets.only(
                                              bottom: (isMobilePortrait || isTabletPortrait) 
                                                ? (isTabletPortrait ? 6 : 2) // 태블릿에서 약간 더 많은 마진
                                                : 4,
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
                                                            fontSize: (isMobilePortrait || isTabletPortrait)
                                                              ? (isTabletPortrait ? fontSize * 1.1 : fontSize * 0.9) // 태블릿에서 살짝 크게
                                                              : fontSize,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        Text(
                                                          '#${(userProvider.userNo! - 3).toString().padLeft(4, '0')}',
                                                          style: TextStyle(
                                                            fontSize: (isMobilePortrait || isTabletPortrait)
                                                              ? (isTabletPortrait ? fontSize * 0.9 : fontSize * 0.7) // 태블릿에서 적절한 크기
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
                                                                (isMobilePortrait || isTabletPortrait) 
                                                                  ? (isTabletPortrait ? 18 : 16) // 태블릿에서 적절한 radius
                                                                  : 20,
                                                              ),
                                                              onTap: () {
                                                                userProvider.isLogin
                                                                    ? UserService().logoutWithPopup(context)
                                                                    : openOAuthPopup();
                                                              },
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(
                                                                  horizontal: (isMobilePortrait || isTabletPortrait)
                                                                    ? (isTabletPortrait ? 14 : 10) // 태블릿에서 적절한 패딩
                                                                    : 16,
                                                                  vertical: (isMobilePortrait || isTabletPortrait)
                                                                    ? (isTabletPortrait ? 8 : 6) // 태블릿에서 적절한 패딩
                                                                    : 8,
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
                                                                    (isMobilePortrait || isTabletPortrait)
                                                                      ? (isTabletPortrait ? 18 : 16) // 태블릿에서 적절한 radius
                                                                      : 20,
                                                                  ),
                                                                  // boxShadow: [
                                                                  //   BoxShadow(
                                                                  //     color: (userProvider.isLogin 
                                                                  //         ? const Color(0xFFEF4444) 
                                                                  //         : Theme.of(context).colorScheme.primary)
                                                                  //         .withOpacity(0.3),
                                                                  //     offset: const Offset(0, 4),
                                                                  //     blurRadius: 8,
                                                                  //   ),
                                                                  // ],
                                                                ),
                                                                child: Text(
                                                                  userProvider.isLogin ? '로그아웃' : '로그인',
                                                                  style: TextStyle(
                                                                    fontSize: (isMobilePortrait || isTabletPortrait)
                                                                      ? (isTabletPortrait ? fontSize * 0.95 : fontSize * 0.8) // 태블릿에서 적절한 크기
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
                                                      SizedBox(width: (isMobilePortrait || isTabletPortrait) 
                                                        ? (isTabletPortrait ? 10 : 6) // 태블릿에서 적절한 간격
                                                        : 12),
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
                                                        isMobile: isMobilePortrait || isTabletPortrait,
                                                      ),
                                                    ],
                                                  ),
                                                ),
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
                                                    ],
                                                  )),
                                        ],
                                      ),
                              );
                            },
                          )

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
    return Material(
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

  Widget _buildBottomTabBar(BuildContext context, TabController controller) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobilePortrait = screenWidth < 600;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          child: TabBar(
            controller: controller,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.zero,
            indicatorPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey.shade500,
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                return Colors.transparent;
              },
            ),
            tabs: [
              _buildBottomTabItem(context, Icons.build_outlined, Icons.build, 'Builder', controller.index == 0),
              _buildBottomTabItem(context, Icons.list_outlined, Icons.list, 'List', controller.index == 1),
              _buildBottomTabItem(context, Icons.collections_bookmark_outlined, Icons.collections_bookmark_rounded, 'Collect', controller.index == 2),
              _buildBottomTabItem(context, Icons.info_outline, Icons.info, 'Info', controller.index == 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTabItem(BuildContext context, IconData outlinedIcon, IconData filledIcon, String label, bool isSelected) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isSelected ? filledIcon : outlinedIcon,
              key: ValueKey(isSelected),
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

 
  }
