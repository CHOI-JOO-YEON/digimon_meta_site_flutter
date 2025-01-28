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
    String url = '$baseUrl/oauth2/authorization/kakao';
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
      routes: [DeckBuilderRoute(deck: null), DeckListRoute(), CollectRoute()],
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
              SizedBox(
                height: SizeService.headerHeight(context),
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                              padding: EdgeInsets.all(
                                  SizeService.paddingSize(context)*2),
                              child: ResponsiveRowColumn(
                                layout: ResponsiveBreakpoints.of(context)
                                        .smallerThan('4K')
                                    ? ResponsiveRowColumnType.COLUMN
                                    : ResponsiveRowColumnType.ROW,
                                rowMainAxisAlignment: MainAxisAlignment.start,
                                rowCrossAxisAlignment:
                                    CrossAxisAlignment.start,
                                columnMainAxisAlignment:
                                    MainAxisAlignment.start,
                                columnCrossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  if (userProvider.isLogin)
                                    ResponsiveRowColumnItem(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${userProvider.nickname}',
                                            style:
                                                TextStyle(fontSize: fontSize),
                                          ),
                                          Text(
                                            '#${(userProvider.userNo! - 3).toString().padLeft(4, '0')}',
                                            style:
                                                TextStyle(fontSize: fontSize),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ResponsiveRowColumnItem(
                                    child: SizedBox(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.009,
                                      // height: 8,
                                    ),
                                  ),
                                  ResponsiveRowColumnItem(
                                    child: GestureDetector(
                                      child: Text(
                                        userProvider.isLogin ? '로그아웃' : '로그인',
                                        style: TextStyle(
                                            fontSize: fontSize,
                                            color:
                                                Theme.of(context).primaryColor),
                                      ),
                                      onTap: () {
                                        userProvider.isLogin
                                            ? userProvider.logout()
                                            : openOAuthPopup();();
                                      },
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        Expanded(
                          flex: 1,
                          child: TabBar(
                            controller: controller,
                            tabs: [
                              Tab(
                                icon: Center(
                                    child: Icon(
                                  Icons.build,
                                  // size: SizeService.largeIconSize(context),
                                )),
                                iconMargin: EdgeInsets.zero,
                                child: isPortrait
                                    ? null
                                    : Text(
                                        'Builder',
                                        style: TextStyle(fontSize: fontSize),
                                      ),
                              ),
                              Tab(
                                icon: Center(
                                    child: Icon(
                                  Icons.list,
                                  // size: SizeService.largeIconSize(context),
                                )),
                                iconMargin: EdgeInsets.zero,
                                child: isPortrait
                                    ? null
                                    : Text('List',
                                        style: TextStyle(fontSize: fontSize)),
                              ),
                              Tab(
                                icon: Center(
                                    child: Icon(
                                  Icons.collections_bookmark_rounded,
                                  // size: SizeService.largeIconSize(context),
                                )),
                                iconMargin: EdgeInsets.zero,
                                child: isPortrait
                                    ? null
                                    : Text('Collect',
                                        style: TextStyle(fontSize: fontSize)),
                              )
                            ],
                          ),
                        ),
                        const Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // IconButton(
                                //   onPressed:  () async {
                                //     bool loginCheck = await userProvider.loginCheck();
                                //     if(loginCheck) {
                                //       _launchEmail(userProvider.nickname!);
                                //     }
                                //
                                //   },
                                //
                                //   icon: Icon(Icons.mail),
                                //   padding: EdgeInsets.zero,
                                //   tooltip: '개발자에게 메일 보내기',
                                // )
                              ],
                            )),
                      ],
                    );
                  },
                ),
              ),
              Expanded(child: child)
            ],
          ),
        );
      },
    );
  }
}
