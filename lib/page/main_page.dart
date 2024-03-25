import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  @override
  Widget build(BuildContext context) {
    double fontSize = min(MediaQuery.sizeOf(context).width * 0.02, 20);
    print('Main Page ${MediaQuery.of(context).size}');
    print('Keboard ${MediaQuery.of(context).viewInsets.bottom}');
    return AutoTabsRouter.tabBar(
      routes: [DeckBuilderRoute(), DeckListRoute()],
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
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (userProvider.isLogin())
                                    Text(
                                      '${userProvider.nickname}',
                                      style: TextStyle(
                                          fontSize:min(MediaQuery.sizeOf(context).width *0.02,15)),
                                    ),
                                  SizedBox(
                                      width: MediaQuery.sizeOf(context).width *
                                          0.009),
                                  userProvider.isLogin()
                                      ? Center(
                                    child: TextButton(
                                      onPressed: () {
                                        userProvider.logout();
                                      },
                                      child: Text(
                                        '로그아웃',
                                        style: TextStyle(
                                            fontSize:fontSize),
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
                                        style: TextStyle(
                                            fontSize: fontSize
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TabBar(
                          controller: controller,
                          tabs: [
                            Tab(
                              // icon: Icon(Icons.build),
                              child: Text(
                                'Builder',
                                style: TextStyle(
                                    fontSize: fontSize*0.9),
                              ),
                            ),
                            Tab(
                              // icon: Icon(Icons.list_alt),
                              child: Text('List',
                                  style: TextStyle(
                                      fontSize: fontSize*0.9)),
                            )
                          ],
                        ),
                      ),
                      Expanded(flex: 1, child: Container()),
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
