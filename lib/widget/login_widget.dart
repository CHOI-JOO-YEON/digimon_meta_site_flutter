import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:provider/provider.dart';

import '../provider/user_provider.dart';

class LoginWidget extends StatelessWidget {
  final String currentPage;

  const LoginWidget({super.key, required this.currentPage});

  void openOAuthPopup() {
    String url = 'http://localhost:8080/oauth2/authorization/kakao';
    String windowName = 'OAuthLogin';
    String windowFeatures = 'width=800,height=600';
    html.window.open(url, windowName, windowFeatures);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueAccent,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  pageButton(
                      "Deck Builder", Icons.build, context, ToyBoxRoute()),
                  // pageButton("Deck List", Icons.list, context, DeckListRoute()),
                ],
              )),
          Expanded(flex: 1, child: Container()),
        ],
      ),
    );
  }

  Widget pageButton(String text, IconData icon, BuildContext context,
      PageRouteInfo pageRouteInfo) {
    bool isActive = currentPage == text;

    return InkWell(
      onTap: isActive
          ? null
          : () {
              context.router.push(pageRouteInfo);
            },
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.blueAccent,
          // border: Border.all(width: 0,color: currentPage==text?Colors.white:Colors.blue)
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
