// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AdminRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AdminPage(),
      );
    },
    DeckBuilderRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DeckBuilderPage(),
      );
    },
    DeckImageRoute.name: (routeData) {
      final args = routeData.argsAs<DeckImageRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DeckImagePage(
          key: args.key,
          deck: args.deck,
        ),
      );
    },
    DeckListRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DeckListPage(),
      );
    },
    HomeRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomePage(),
      );
    },
    KakaoLoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const KakaoLoginPage(),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginPage(),
      );
    },
    MainRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MainPage(),
      );
    },
    ToyBoxRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ToyBoxPage(),
      );
    },
  };
}

/// generated route for
/// [AdminPage]
class AdminRoute extends PageRouteInfo<void> {
  const AdminRoute({List<PageRouteInfo>? children})
      : super(
          AdminRoute.name,
          initialChildren: children,
        );

  static const String name = 'AdminRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DeckBuilderPage]
class DeckBuilderRoute extends PageRouteInfo<void> {
  const DeckBuilderRoute({List<PageRouteInfo>? children})
      : super(
          DeckBuilderRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeckBuilderRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DeckImagePage]
class DeckImageRoute extends PageRouteInfo<DeckImageRouteArgs> {
  DeckImageRoute({
    Key? key,
    required Deck deck,
    List<PageRouteInfo>? children,
  }) : super(
          DeckImageRoute.name,
          args: DeckImageRouteArgs(
            key: key,
            deck: deck,
          ),
          initialChildren: children,
        );

  static const String name = 'DeckImageRoute';

  static const PageInfo<DeckImageRouteArgs> page =
      PageInfo<DeckImageRouteArgs>(name);
}

class DeckImageRouteArgs {
  const DeckImageRouteArgs({
    this.key,
    required this.deck,
  });

  final Key? key;

  final Deck deck;

  @override
  String toString() {
    return 'DeckImageRouteArgs{key: $key, deck: $deck}';
  }
}

/// generated route for
/// [DeckListPage]
class DeckListRoute extends PageRouteInfo<void> {
  const DeckListRoute({List<PageRouteInfo>? children})
      : super(
          DeckListRoute.name,
          initialChildren: children,
        );

  static const String name = 'DeckListRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [KakaoLoginPage]
class KakaoLoginRoute extends PageRouteInfo<void> {
  const KakaoLoginRoute({List<PageRouteInfo>? children})
      : super(
          KakaoLoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'KakaoLoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [MainPage]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [ToyBoxPage]
class ToyBoxRoute extends PageRouteInfo<void> {
  const ToyBoxRoute({List<PageRouteInfo>? children})
      : super(
          ToyBoxRoute.name,
          initialChildren: children,
        );

  static const String name = 'ToyBoxRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
