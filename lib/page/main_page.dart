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
    final isSmallHeight = screenHeight < 600; // 세로 높이가 작은 화면 감지
    
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
                      ? SizeService.headerHeight(context) 
                      : (isSmallHeight ? 40 : 50), // 최소한의 공간 유지
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRect(
                      child: headerProvider.isHeaderVisible 
                        ? Consumer2<UserProvider, DeckProvider>(
                            builder: (context, userProvider, deckProvider, child) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeService.paddingSize(context) * 2,
                                ),
                                child: isPortrait
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // 세로모드에서 로그인 정보와 설정 버튼
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                if (userProvider.isLogin)
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        '${userProvider.nickname}',
                                                        style: TextStyle(
                                                          fontSize: fontSize,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      Text(
                                                        '#${(userProvider.userNo! - 3).toString().padLeft(4, '0')}',
                                                        style: TextStyle(
                                                          fontSize: fontSize * 0.8,
                                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                
                                                Expanded(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      GestureDetector(
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: userProvider.isLogin
                                                                ? Colors.red.withOpacity(0.1)
                                                                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                            borderRadius: BorderRadius.circular(16),
                                                          ),
                                                          child: Text(
                                                            userProvider.isLogin ? '로그아웃' : '로그인',
                                                            style: TextStyle(
                                                              fontSize: fontSize,
                                                              color: userProvider.isLogin
                                                                  ? Colors.red
                                                                  : Theme.of(context).primaryColor,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          userProvider.isLogin
                                                              ? UserService().logoutWithPopup(context)
                                                              : openOAuthPopup();
                                                        },
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 8.0),
                                                        child: IconButton(
                                                          padding: EdgeInsets.zero,
                                                          onPressed: () {
                                                            DeckBuild? deck = deckProvider.currentDeck;
                                                            if (deck == null) {
                                                              deck = DeckBuild(context);
                                                            }
                                                            DeckService().showDeckSettingDialog(
                                                                context, deck, () {
                                                              setState(() {});
                                                            });
                                                          },
                                                          iconSize: SizeService.largeIconSize(context),
                                                          icon: const Icon(Icons.settings),
                                                          tooltip: '덱 설정',
                                                        ),
                                                      ),
                                                      
                                                      // 헤더 토글 버튼 - 가장 오른쪽
                                                      Padding(
                                                        padding: const EdgeInsets.only(left: 8.0),
                                                        child: IconButton(
                                                          onPressed: () => headerProvider.hideHeader(),
                                                          icon: Icon(
                                                            Icons.keyboard_arrow_up,
                                                            size: SizeService.largeIconSize(context),
                                                          ),
                                                          tooltip: '메뉴 접기',
                                                          padding: EdgeInsets.zero,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // 세로모드에서 탭바
                                          Container(
                                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: TabBar(
                                              controller: controller,
                                              labelStyle: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: fontSize * 0.85,
                                              ),
                                              unselectedLabelStyle: TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: fontSize * 0.85,
                                              ),
                                              indicator: const UnderlineTabIndicator(
                                                borderSide: BorderSide.none,
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                                              labelPadding: EdgeInsets.zero,
                                              indicatorPadding: const EdgeInsets.all(4),
                                              labelColor: Theme.of(context).primaryColor,
                                              unselectedLabelColor: Colors.grey.shade600,
                                              dividerColor: Colors.transparent,
                                              splashFactory: NoSplash.splashFactory,
                                              overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                                (Set<MaterialState> states) {
                                                  return states.contains(MaterialState.focused)
                                                      ? null
                                                      : Colors.transparent;
                                                },
                                              ),
                                              tabs: [
                                                _buildTabItem(context, Icons.build, 'Builder', isPortrait),
                                                _buildTabItem(context, Icons.list, 'List', isPortrait),
                                                _buildTabItem(context, Icons.collections_bookmark_rounded, 'Collect', isPortrait),
                                                _buildTabItem(context, Icons.info_outline, 'Info', isPortrait),
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
                                                  child: GestureDetector(
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: userProvider.isLogin
                                                            ? Colors.red.withOpacity(0.1)
                                                            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: Text(
                                                        userProvider.isLogin ? '로그아웃' : '로그인',
                                                        style: TextStyle(
                                                          fontSize: fontSize,
                                                          color: userProvider.isLogin
                                                              ? Colors.red
                                                              : Theme.of(context).primaryColor,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      userProvider.isLogin
                                                          ? UserService().logoutWithPopup(context)
                                                          : openOAuthPopup();
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade50,
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.05),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: TabBar(
                                                controller: controller,
                                                labelStyle: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: fontSize * 0.85,
                                                ),
                                                unselectedLabelStyle: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: fontSize * 0.85,
                                                ),
                                                indicator: const UnderlineTabIndicator(
                                                  borderSide: BorderSide.none,
                                                ),
                                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                labelPadding: EdgeInsets.zero,
                                                indicatorPadding: const EdgeInsets.all(4),
                                                labelColor: Theme.of(context).primaryColor,
                                                unselectedLabelColor: Colors.grey.shade600,
                                                dividerColor: Colors.transparent,
                                                splashFactory: NoSplash.splashFactory,
                                                overlayColor: MaterialStateProperty.resolveWith<Color?>(
                                                  (Set<MaterialState> states) {
                                                    return states.contains(MaterialState.focused)
                                                        ? null
                                                        : Colors.transparent;
                                                  },
                                                ),
                                                tabs: [
                                                  _buildTabItem(context, Icons.build, 'Builder', isPortrait),
                                                  _buildTabItem(context, Icons.list, 'List', isPortrait),
                                                  _buildTabItem(context, Icons.collections_bookmark_rounded, 'Collect', isPortrait),
                                                  _buildTabItem(context, Icons.info_outline, 'Info', isPortrait),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                              flex: 1,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    padding: EdgeInsets.zero,
                                                    onPressed: () {
                                                      DeckBuild? deck = deckProvider.currentDeck;
                                                      if (deck == null) {
                                                        deck = DeckBuild(context);
                                                      }
                                                      DeckService().showDeckSettingDialog(
                                                          context, deck, () {
                                                        setState(() {});
                                                      });
                                                    },
                                                    iconSize: SizeService.largeIconSize(context),
                                                    icon: const Icon(Icons.settings),
                                                    tooltip: '덱 설정',
                                                  ),
                                                  
                                                  // 헤더 토글 버튼 (가로 모드) - 가장 오른쪽
                                                  SizedBox(width: 8),
                                                  IconButton(
                                                    onPressed: () => headerProvider.hideHeader(),
                                                    icon: Icon(
                                                      Icons.keyboard_arrow_up,
                                                      size: SizeService.largeIconSize(context),
                                                    ),
                                                    tooltip: '메뉴 접기',
                                                    padding: EdgeInsets.zero,
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
                                IconButton(
                                  onPressed: () => headerProvider.showHeader(),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: SizeService.largeIconSize(context),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  tooltip: '메뉴 펼치기',
                                  padding: EdgeInsets.zero,
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
}
