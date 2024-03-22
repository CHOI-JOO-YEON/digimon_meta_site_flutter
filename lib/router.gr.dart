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
    DeckBuilderRoute.name: (routeData) {
      final args = routeData.argsAs<DeckBuilderRouteArgs>(
          orElse: () => const DeckBuilderRouteArgs());
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DeckBuilderPage(
          key: args.key,
          deck: args.deck,
        ),
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
    KakaoLoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const KakaoLoginPage(),
      );
    },
    MainRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: MainPage(),
      );
    },
  };
}

/// generated route for
/// [DeckBuilderPage]
class DeckBuilderRoute extends PageRouteInfo<DeckBuilderRouteArgs> {
  DeckBuilderRoute({
    Key? key,
    Deck? deck,
    List<PageRouteInfo>? children,
  }) : super(
          DeckBuilderRoute.name,
          args: DeckBuilderRouteArgs(
            key: key,
            deck: deck,
          ),
          initialChildren: children,
        );

  static const String name = 'DeckBuilderRoute';

  static const PageInfo<DeckBuilderRouteArgs> page =
      PageInfo<DeckBuilderRouteArgs>(name);
}

class DeckBuilderRouteArgs {
  const DeckBuilderRouteArgs({
    this.key,
    this.deck,
  });

  final Key? key;

  final Deck? deck;

  @override
  String toString() {
    return 'DeckBuilderRouteArgs{key: $key, deck: $deck}';
  }
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
