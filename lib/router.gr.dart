// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [CollectPage]
class CollectRoute extends PageRouteInfo<CollectRouteArgs> {
  CollectRoute({
    Key? key,
    String? searchParameterString,
    List<PageRouteInfo>? children,
  }) : super(
         CollectRoute.name,
         args: CollectRouteArgs(
           key: key,
           searchParameterString: searchParameterString,
         ),
         rawQueryParams: {'searchParameter': searchParameterString},
         initialChildren: children,
       );

  static const String name = 'CollectRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<CollectRouteArgs>(
        orElse:
            () => CollectRouteArgs(
              searchParameterString: queryParams.optString('searchParameter'),
            ),
      );
      return CollectPage(
        key: args.key,
        searchParameterString: args.searchParameterString,
      );
    },
  );
}

class CollectRouteArgs {
  const CollectRouteArgs({this.key, this.searchParameterString});

  final Key? key;

  final String? searchParameterString;

  @override
  String toString() {
    return 'CollectRouteArgs{key: $key, searchParameterString: $searchParameterString}';
  }
}

/// generated route for
/// [DeckBuilderPage]
class DeckBuilderRoute extends PageRouteInfo<DeckBuilderRouteArgs> {
  DeckBuilderRoute({
    Key? key,
    DeckBuild? deck,
    String? searchParameterString,
    DeckView? deckView,
    List<PageRouteInfo>? children,
  }) : super(
         DeckBuilderRoute.name,
         args: DeckBuilderRouteArgs(
           key: key,
           deck: deck,
           searchParameterString: searchParameterString,
           deckView: deckView,
         ),
         rawQueryParams: {'searchParameter': searchParameterString},
         initialChildren: children,
       );

  static const String name = 'DeckBuilderRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<DeckBuilderRouteArgs>(
        orElse:
            () => DeckBuilderRouteArgs(
              searchParameterString: queryParams.optString('searchParameter'),
            ),
      );
      return DeckBuilderPage(
        key: args.key,
        deck: args.deck,
        searchParameterString: args.searchParameterString,
        deckView: args.deckView,
      );
    },
  );
}

class DeckBuilderRouteArgs {
  const DeckBuilderRouteArgs({
    this.key,
    this.deck,
    this.searchParameterString,
    this.deckView,
  });

  final Key? key;

  final DeckBuild? deck;

  final String? searchParameterString;

  final DeckView? deckView;

  @override
  String toString() {
    return 'DeckBuilderRouteArgs{key: $key, deck: $deck, searchParameterString: $searchParameterString, deckView: $deckView}';
  }
}

/// generated route for
/// [DeckImagePage]
class DeckImageRoute extends PageRouteInfo<DeckImageRouteArgs> {
  DeckImageRoute({
    Key? key,
    required DeckBuild deck,
    List<PageRouteInfo>? children,
  }) : super(
         DeckImageRoute.name,
         args: DeckImageRouteArgs(key: key, deck: deck),
         initialChildren: children,
       );

  static const String name = 'DeckImageRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DeckImageRouteArgs>();
      return DeckImagePage(key: args.key, deck: args.deck);
    },
  );
}

class DeckImageRouteArgs {
  const DeckImageRouteArgs({this.key, required this.deck});

  final Key? key;

  final DeckBuild deck;

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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<DeckListRouteArgs>(
        orElse:
            () => DeckListRouteArgs(
              searchParameterString: queryParams.optString('searchParameter'),
            ),
      );
      return DeckListPage(
        key: args.key,
        searchParameterString: args.searchParameterString,
      );
    },
  );
}

class DeckListRouteArgs {
  const DeckListRouteArgs({this.key, this.searchParameterString});

  final Key? key;

  final String? searchParameterString;

  @override
  String toString() {
    return 'DeckListRouteArgs{key: $key, searchParameterString: $searchParameterString}';
  }
}

/// generated route for
/// [GamePlayGroundPage]
class GamePlayGroundRoute extends PageRouteInfo<GamePlayGroundRouteArgs> {
  GamePlayGroundRoute({
    Key? key,
    required DeckBuild deckBuild,
    List<PageRouteInfo>? children,
  }) : super(
         GamePlayGroundRoute.name,
         args: GamePlayGroundRouteArgs(key: key, deckBuild: deckBuild),
         initialChildren: children,
       );

  static const String name = 'GamePlayGroundRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<GamePlayGroundRouteArgs>();
      return GamePlayGroundPage(key: args.key, deckBuild: args.deckBuild);
    },
  );
}

class GamePlayGroundRouteArgs {
  const GamePlayGroundRouteArgs({this.key, required this.deckBuild});

  final Key? key;

  final DeckBuild deckBuild;

  @override
  String toString() {
    return 'GamePlayGroundRouteArgs{key: $key, deckBuild: $deckBuild}';
  }
}

/// generated route for
/// [KakaoLoginPage]
class KakaoLoginRoute extends PageRouteInfo<void> {
  const KakaoLoginRoute({List<PageRouteInfo>? children})
    : super(KakaoLoginRoute.name, initialChildren: children);

  static const String name = 'KakaoLoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const KakaoLoginPage();
    },
  );
}

/// generated route for
/// [MainPage]
class MainRoute extends PageRouteInfo<void> {
  const MainRoute({List<PageRouteInfo>? children})
    : super(MainRoute.name, initialChildren: children);

  static const String name = 'MainRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return MainPage();
    },
  );
}

/// generated route for
/// [QrDeckImportPage]
class QrDeckImportRoute extends PageRouteInfo<QrDeckImportRouteArgs> {
  QrDeckImportRoute({
    Key? key,
    String? deckParam,
    List<PageRouteInfo>? children,
  }) : super(
         QrDeckImportRoute.name,
         args: QrDeckImportRouteArgs(key: key, deckParam: deckParam),
         rawQueryParams: {'deck': deckParam},
         initialChildren: children,
       );

  static const String name = 'QrDeckImportRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<QrDeckImportRouteArgs>(
        orElse:
            () =>
                QrDeckImportRouteArgs(deckParam: queryParams.optString('deck')),
      );
      return QrDeckImportPage(key: args.key, deckParam: args.deckParam);
    },
  );
}

class QrDeckImportRouteArgs {
  const QrDeckImportRouteArgs({this.key, this.deckParam});

  final Key? key;

  final String? deckParam;

  @override
  String toString() {
    return 'QrDeckImportRouteArgs{key: $key, deckParam: $deckParam}';
  }
}
