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
    CollectRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CollectPage(),
      );
    },
    DeckBuilderRoute.name: (routeData) {
      final queryParams = routeData.queryParams;
      final args = routeData.argsAs<DeckBuilderRouteArgs>(
          orElse: () => DeckBuilderRouteArgs(
              searchParameterString: queryParams.optString('searchParameter')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DeckBuilderPage(
          key: args.key,
          deck: args.deck,
          searchParameterString: args.searchParameterString,
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
      final queryParams = routeData.queryParams;
      final args = routeData.argsAs<DeckListRouteArgs>(
          orElse: () => DeckListRouteArgs(
              searchParameterString: queryParams.optString('searchParameter')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: DeckListPage(
          key: args.key,
          searchParameterString: args.searchParameterString,
        ),
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
/// [CollectPage]
class CollectRoute extends PageRouteInfo<void> {
  const CollectRoute({List<PageRouteInfo>? children})
      : super(
          CollectRoute.name,
          initialChildren: children,
        );

  static const String name = 'CollectRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DeckBuilderPage]
class DeckBuilderRoute extends PageRouteInfo<DeckBuilderRouteArgs> {
  DeckBuilderRoute({
    Key? key,
    Deck? deck,
    String? searchParameterString,
    List<PageRouteInfo>? children,
  }) : super(
          DeckBuilderRoute.name,
          args: DeckBuilderRouteArgs(
            key: key,
            deck: deck,
            searchParameterString: searchParameterString,
          ),
          rawQueryParams: {'searchParameter': searchParameterString},
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
    this.searchParameterString,
  });

  final Key? key;

  final Deck? deck;

  final String? searchParameterString;

  @override
  String toString() {
    return 'DeckBuilderRouteArgs{key: $key, deck: $deck, searchParameterString: $searchParameterString}';
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
class DeckListRoute extends PageRouteInfo<DeckListRouteArgs> {
  DeckListRoute({
    Key? key,
    String? searchParameterString,
    List<PageRouteInfo>? children,
  }) : super(
          DeckListRoute.name,
          args: DeckListRouteArgs(
            key: key,
            searchParameterString: searchParameterString,
          ),
          rawQueryParams: {'searchParameter': searchParameterString},
          initialChildren: children,
        );

  static const String name = 'DeckListRoute';

  static const PageInfo<DeckListRouteArgs> page =
      PageInfo<DeckListRouteArgs>(name);
}

class DeckListRouteArgs {
  const DeckListRouteArgs({
    this.key,
    this.searchParameterString,
  });

  final Key? key;

  final String? searchParameterString;

  @override
  String toString() {
    return 'DeckListRouteArgs{key: $key, searchParameterString: $searchParameterString}';
  }
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
