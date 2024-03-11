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
    return AutoTabsRouter.tabBar(
      routes: [
        DeckBuilderRoute(),
        DeckListRoute()
      ],
      builder: (context, child, controller) {
        return Scaffold(
          body: Column(
            children: [
              SizedBox(
                height: max(MediaQuery.sizeOf(context).height*0.1,80) ,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Padding(
                            padding: const EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                if (userProvider.isLogin())
                                  Text('${userProvider.nickname}'),
                                userProvider.isLogin()
                                    ? Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      userProvider.logout();
                                    },
                                    child: Text('로그아웃'),
                                  ),
                                )
                                    : Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      openOAuthPopup();
                                    },
                                    child: Text('로그인'),
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
                        child:  TabBar(
                          controller: controller,
                          tabs: const [
                            Tab(text: 'Deck Builder', icon: Icon(Icons.build)),
                            Tab(text: 'Deck List', icon: Icon(Icons.list_alt)),
                          ],),
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