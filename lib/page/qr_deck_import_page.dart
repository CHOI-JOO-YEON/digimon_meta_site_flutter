import 'package:digimon_meta_site_flutter/api/deck_api.dart';
import 'package:digimon_meta_site_flutter/service/deck_service.dart';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

import '../model/deck-build.dart';
import '../router.dart';
@RoutePage()
class QrDeckImportPage extends StatefulWidget {
  final String? deckParam;

  const QrDeckImportPage({
    Key? key,
    @QueryParam('deck') this.deckParam,
  }) : super(key: key);

  @override
  State<QrDeckImportPage> createState() => _QrDeckImportPageState();
}

class _QrDeckImportPageState extends State<QrDeckImportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processDeckParam();
    });
  }

  Future<void> _processDeckParam() async {
    final param = widget.deckParam;
    DeckBuild deck = DeckBuild(context);
    if (param != null && param.isNotEmpty) {
      var deckView = await DeckApi().importDeckQr(widget.deckParam!);
      if (deckView != null) {
        deck.import(deckView);
      }
      
    }
    context.router.push(DeckBuilderRoute(deck: deck));
  }

  Map<int, int> parseDeckString(String str) {
    final Map<int, int> result = {};
    final pairs = str.split(',');
    for (final p in pairs) {
      if (p.contains('=')) {
        final parts = p.split('=');
        if (parts.length == 2) {
          final key = int.tryParse(parts[0]) ?? 0;
          final value = int.tryParse(parts[1]) ?? 0;
          result[key] = value;
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
