import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/page/admin_page.dart';
import 'package:digimon_meta_site_flutter/page/deck_builder_page.dart';
import 'package:digimon_meta_site_flutter/page/deck_image_page.dart';
import 'package:digimon_meta_site_flutter/page/deck_list_page.dart';
import 'package:digimon_meta_site_flutter/page/home_page.dart';
import 'package:digimon_meta_site_flutter/page/kakao_login_page.dart';
import 'package:digimon_meta_site_flutter/page/login_page.dart';
import 'package:digimon_meta_site_flutter/page/main_page.dart';
import 'package:digimon_meta_site_flutter/page/toy_box_page.dart';
import 'package:flutter/material.dart';

import 'model/deck.dart';

part 'router.gr.dart';



@AutoRouterConfig()
class AppRouter extends _$AppRouter {

  @override
  List<AutoRoute> get routes => [
    // AutoRoute(page: HomeRoute.page, initial: true, path: "/"),
    // AutoRoute(page: LoginRoute.page, path: "/login"),
    AutoRoute(page: AdminRoute.page,path: "/admin"),
    // AutoRoute(page: ToyBoxRoute.page,path: "/toy-box"),
    AutoRoute(page: DeckImageRoute.page,path: "/deck-image"),
    AutoRoute(page: KakaoLoginRoute.page,path: "/login/kakao"),
    AutoRoute(
      initial: true,
      path: '/',
      page: MainRoute.page,
      children: [
        AutoRoute(path: 'deck-builder', page: DeckBuilderRoute.page),
        AutoRoute(path: 'deck-list', page: DeckListRoute.page),
        // AutoRoute(path: '2', page: TestRoute2.page),
      ],
    ),
  ];
}