import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;
import '../provider/user_provider.dart';

@RoutePage()
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // bool _isLoginDialogShown = false;
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
      routes: [DeckBuilderRoute(), DeckListRoute()],
      builder: (context, child, controller) {
        return Scaffold(
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
                          // if(!userProvider.isLogin()){
                          //   _isLoginDialogShown=false;
                          // }
                          // if (userProvider.isLogin() && !_isLoginDialogShown) {
                          //   WidgetsBinding.instance.addPostFrameCallback((_) {
                          //     showDialog(
                          //       context: context,
                          //       builder: (BuildContext context) {
                          //         return AlertDialog(
                          //           title: Text('로그인 성공'),
                          //           content: Text('로그인이 성공적으로 완료되었습니다.'),
                          //           actions: [
                          //             TextButton(
                          //               onPressed: () {
                          //                 Navigator.of(context).pop();
                          //               },
                          //               child: Text('확인'),
                          //             ),
                          //           ],
                          //         );
                          //       },
                          //     ).then((_) {
                          //       setState(() {
                          //         _isLoginDialogShown = true;
                          //       });
                          //     });
                          //   });
                          // }
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
                                        child: ElevatedButton(
                                          onPressed: () {
                                            userProvider.logout();
                                          },
                                          child: Text(
                                            '로그아웃',
                                            style: TextStyle(
                                                fontSize:min(MediaQuery.sizeOf(context).width *0.02,15)),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            openOAuthPopup();
                                          },
                                          child: Text(
                                            '로그인',
                                            style: TextStyle(
                                                fontSize: min(MediaQuery.sizeOf(context).width *0.02,15)
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
                                  fontSize: min(
                                      MediaQuery.sizeOf(context).width * 0.02,
                                      25)),
                            ),
                          ),
                          Tab(
                            // icon: Icon(Icons.list_alt),
                            child: Text('List',
                                style: TextStyle(
                                    fontSize: min(
                                        MediaQuery.sizeOf(context).width * 0.02,
                                        25))),
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
