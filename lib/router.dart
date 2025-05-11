import 'package:auto_route/auto_route.dart';
import 'package:digimon_meta_site_flutter/page/collect_page.dart';
import 'package:digimon_meta_site_flutter/page/deck_builder_page.dart';
import 'package:digimon_meta_site_flutter/page/deck_image_page.dart';
import 'package:digimon_meta_site_flutter/page/deck_list_page.dart';
import 'package:digimon_meta_site_flutter/page/game_playground_page.dart';
import 'package:digimon_meta_site_flutter/page/info_page.dart';
import 'package:digimon_meta_site_flutter/page/kakao_login_page.dart';
import 'package:digimon_meta_site_flutter/page/kakao_logout_page.dart';
import 'package:digimon_meta_site_flutter/page/keyword_info_page.dart';
import 'package:digimon_meta_site_flutter/page/limit_info_page.dart';
import 'package:digimon_meta_site_flutter/page/main_page.dart';
import 'package:digimon_meta_site_flutter/page/qr_deck_import_page.dart';
import 'package:digimon_meta_site_flutter/page/rule_info_page.dart';
import 'package:flutter/material.dart';

import 'model/deck-build.dart';
import 'model/deck-view.dart';

part 'router.gr.dart';



@AutoRouterConfig()
class AppRouter extends RootStackRouter {

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: DeckImageRoute.page,path: "/deck-image",guards: [DeckGuard()]),
    AutoRoute(page: GamePlayGroundRoute.page,path: "/game",guards: [DeckGuard()]),
    AutoRoute(page: KakaoLoginRoute.page,path: "/login/kakao"),
    AutoRoute(page: KakaoLogoutRoute.page,path: "/logout/kakao"),
    AutoRoute(page: QrDeckImportRoute.page,path: "/qr", meta: {'deck': 'String',},),
    AutoRoute(
      // initial: true,
      path: '/',
      page: MainRoute.page,
      children: [
        AutoRoute(path: 'deck-builder', page: DeckBuilderRoute.page
        ,meta: {'searchParameter': 'String',},

        ),
        AutoRoute(path: 'deck-list', page: DeckListRoute.page,
          meta: {'searchParameter': 'String'}
        ),
        AutoRoute(path: 'collect', page: CollectRoute.page
          ,meta: {'searchParameter': 'String',},
        ),
        AutoRoute(path: 'info', page: InfoRoute.page, children: [
          AutoRoute(path: 'limit', page: LimitInfoRoute.page),
          AutoRoute(path: 'keyword', page: KeywordInfoRoute.page),
          AutoRoute(path: 'rule', page: RuleInfoRoute.page),
        ]),
      ],
    ),
  ];

}
class DeckGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final args = resolver.route.args;

    if (args is DeckImageRouteArgs ) {
      resolver.next(true);
    } else if(args is GamePlayGroundRouteArgs) {
      resolver.next(true);
    } else {
      router.replace(MainRoute(children: [DeckBuilderRoute()]));
    }
  }
}