import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  String _subject = '';
  String _category = '버그 제보';
  String _body = '';

  void _launchEmail(String nickname) async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'developer@example.com',
      query: 'subject=$_subject&body=카테고리: $_category\n\n$_body\n\n보낸 사람: $nickname',
    );
    String url = params.toString();
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('메일을 발송할 수 없습니다.');
    }
  }
  @override
  Widget build(BuildContext context) {
    double fontSize = min(MediaQuery.sizeOf(context).width * 0.02, 20);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return AutoTabsRouter.tabBar(
      routes: [DeckBuilderRoute(deck: null), DeckListRoute(), CollectRoute()],
      builder: (context, child, controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: [
              SizedBox(
                height: max(MediaQuery.sizeOf(context).height * 0.1, 80),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (userProvider.isLogin)
                                        Text(
                                          '${userProvider.nickname}',
                                          style: TextStyle(
                                              fontSize: min(
                                                  MediaQuery.sizeOf(context).width *
                                                      0.02,
                                                  15)),
                                        ),
                                      SizedBox(
                                          width: MediaQuery.sizeOf(context).width *
                                              0.009),
                                      userProvider.isLogin
                                          ? Center(
                                              child: TextButton(
                                                onPressed: () {
                                                  userProvider.logout();
                                                },
                                                child: Text(
                                                  '로그아웃',
                                                  style:
                                                      TextStyle(fontSize: fontSize),
                                                ),
                                              ),
                                            )
                                          : Center(
                                              child: TextButton(
                                                onPressed: () {
                                                  openOAuthPopup();
                                                },
                                                child: Text(
                                                  '로그인',
                                                  style:
                                                      TextStyle(fontSize: fontSize),
                                                ),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: TabBar(
                                  controller: controller,
                                  tabs: [
                                    Tab(
                                      icon: Center(child: Icon(Icons.build)),
                                      child: isPortrait?null:Text(
                                        'Builder',
                                        style: TextStyle(fontSize: fontSize * 0.9),
                                      ),
                                      iconMargin: EdgeInsets.zero,

                                    ),
                                    Tab(
                                      icon: Center(child: Icon(Icons.list)),
                                      child: isPortrait?null:Text('List',
                                          style: TextStyle(fontSize: fontSize * 0.9)
                                      ),
                                      iconMargin: EdgeInsets.zero,
                                    ),
                                    Tab(
                                      icon: Center(child: Icon(Icons.collections_bookmark_rounded)),
                                      child: isPortrait?null:Text(

                                          'Collect',
                                          style: TextStyle(fontSize: fontSize * 0.9)),
                                      iconMargin: EdgeInsets.zero,
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
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

                  ],
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
