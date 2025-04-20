import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:html' as html;
import '../provider/user_provider.dart';

@RoutePage()
class MainPage extends StatelessWidget {
  void openOAuthPopup() {
    String baseUrl = const String.fromEnvironment('SERVER_URL');
    String url = '$baseUrl/oauth2/authorization/kakao?prompt=login';
    String windowName = 'OAuthLogin';
    String windowFeatures = 'width=800,height=600';
    html.window.open(url, windowName, windowFeatures);
  }

  final CardOverlayService _cardOverlayService = CardOverlayService();

  @override
  Widget build(BuildContext context) {
    double fontSize = SizeService.bodyFontSize(context);
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return AutoTabsRouter.tabBar(
      physics: const NeverScrollableScrollPhysics(),
      routes: [DeckBuilderRoute(deck: null), DeckListRoute(), CollectRoute(), InfoRoute()],
      builder: (context, child, controller) {
        controller.addListener(() {
          if (controller.indexIsChanging) {
            _cardOverlayService.removeAllOverlays();
          }
        });

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              Container(
                height: SizeService.headerHeight(context),
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
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeService.paddingSize(context) * 2,
                      ),
                      child: isPortrait
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // 세로모드에서 로그인 정보
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
                                              ? userProvider.logout()
                                              : openOAuthPopup();
                                        },
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
                                                ? userProvider.logout()
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
                                const Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [],
                                    )),
                              ],
                            ),
                    );
                  },
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
