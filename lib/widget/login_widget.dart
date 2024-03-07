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
          Expanded(flex: 1,child:  Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return  Padding(
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
          ),),
          Expanded(flex: 1,child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              pageButton("Deck Builder", Icons.build),
              pageButton("Deck List", Icons.list),
              // pageButton("Deck ", Icons.build),
              // pageButton("Deck Builder", Icons.build),
              // pageButton("Deck Builder", Icons.build),

            ],
          )),
          Expanded(flex: 1,child: Container()),

        ],
      ),
    );
  }

  Widget pageButton(String text, IconData icon){
    return InkWell(
      onTap: (){},

        child: Container(

          decoration: BoxDecoration(
            color: currentPage==text?Colors.white:Colors.blueAccent,
            // border: Border.all(width: 0,color: currentPage==text?Colors.white:Colors.blue)
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 5,
              right: 5
            ),
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
