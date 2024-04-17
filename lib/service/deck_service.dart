import 'dart:convert';
import 'dart:math';

import 'package:digimon_meta_site_flutter/api/deck_api.dart';
import 'package:digimon_meta_site_flutter/model/deck_response_dto.dart';
import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/paged_response_deck_dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;
import '../model/deck.dart';

import '../model/format.dart';
import '../provider/limit_provider.dart';

class DeckService {
  DeckApi deckApi = DeckApi();

  Future<Deck?> save(Deck deck) async {
    DeckResponseDto? responseDto = await deckApi.postDeck(deck);
    if (responseDto != null) {
      return Deck.responseDto(responseDto);
    }
    return null;
  }

  Future<DeckResponseDto?> import(Map<String, int> deck) async {
    DeckResponseDto? responseDto = await deckApi.importDeck(deck);
    if (responseDto != null) {
      return responseDto;
    }
    return null;
  }

  Future exportToTTSFile(Deck deck) async {
    dynamic jsonData = await deckApi.exportDeckToTTSFile(deck);

    if (jsonData != null) {
      String jsonString = jsonEncode(jsonData);

      // Blob 객체 생성
      final blob = html.Blob([jsonString]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement anchor = html.AnchorElement(href: url)
        ..setAttribute("download", '${deck.deckName}.json')
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  Future<Map<int, FormatDto>> getFormats(Deck deck) async {
    List<FormatDto>? formats =
        await DeckApi().getFormats(deck.getLatestCardDate());
    Map<int, FormatDto> map = {};
    if (formats != null) {
      for (var format in formats) {
        map[format.formatId] = format;
      }
    }

    return map;
  }

  Future<List<FormatDto>> getAllFormat() async {
    List<FormatDto>? formats = await DeckApi().getFormats(DateTime(0));
    if (formats != null) {
      return formats;
    }
    return [];
  }

  Future<PagedResponseDeckDto?> getDeck(
      DeckSearchParameter deckSearchParameter, BuildContext context) async {
    LimitProvider limitProvider = Provider.of(context, listen: false);
    if (limitProvider.selectedLimit != null) {
      deckSearchParameter.limitId = limitProvider.selectedLimit!.id;
    }

    PagedResponseDeckDto? decks =
        await DeckApi().findDecks(deckSearchParameter);

    return decks;
  }

  Future<bool> deleteDeck(int deckId) async {
    return await DeckApi().deleteDeck(deckId);
  }

  String getCardType(String cardType) {
    switch (cardType) {
      case 'DIGIMON':
        return '디지몬';
      case 'OPTION':
        return '옵션';
      case 'TAMER':
        return '테이머';
      default:
        return '에러';
    }
  }

  Future<void> generateDeckRecipePDF(Deck deck) async {
    final pdfData = await rootBundle.load('assets/doc/digimon_recipe.jpg');

    final pdf = pw.Document();

    final mainDeckMap = <String, List<dynamic>>{};

    deck.deckCards.forEach((card) {
      String cardNo = card.cardNo!;
      int count = deck.deckMap[card]!;
      if (mainDeckMap.containsKey(cardNo)) {
        mainDeckMap[cardNo]![4] =
            (int.parse(mainDeckMap[cardNo]![4]) + count).toString();
      } else {
        mainDeckMap[cardNo!] = [
          cardNo,
          card.lv == null || card.lv == 0 ? '-' : card.lv.toString(),
          card.cardName,
          getCardType(card.cardType!),
          count.toString()
        ];
      }
    });

    final mainDeckData = mainDeckMap.values
        .toList()
        .sublist(0, min(31, mainDeckMap.values.toList().length));

    final digitamaDeckMap = <String, List<dynamic>>{};

    deck.tamaCards.forEach((card) {
      String cardNo = card.cardNo!;
      int count = deck.tamaMap[card]!;
      if (digitamaDeckMap.containsKey(cardNo)) {
        digitamaDeckMap[cardNo]![4] =
            (int.parse(digitamaDeckMap[cardNo]![4]) + count).toString();
      } else {
        digitamaDeckMap[cardNo!] = [
          cardNo,
          card.lv == null || card.lv == 0 ? '-' : card.lv.toString(),
          card.cardName,
          '디지타마',
          count.toString()
        ];
      }
    });
    final digitamaDeckData = digitamaDeckMap.values
        .toList()
        .sublist(0, min(5, digitamaDeckMap.values.toList().length));

    var font =
        pw.Font.ttf(await rootBundle.load('assets/fonts/JalnanGothicTTF.ttf'));
    final tableStyle = pw.TextStyle(font: font, fontSize: 7);
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(5),
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final pageSizeHeight = PdfPageFormat.a4.height;
          final image = pw.MemoryImage(pdfData.buffer.asUint8List());
          return pw.Stack(
            children: [
              pw.Center(
                  child: pw.Image(image,
                      height: pageSizeHeight - 10, fit: pw.BoxFit.fitHeight)),
              pw.Positioned(
                left: 96,
                top: 206.5,
                child: pw.Table(
                  columnWidths: {
                    0: pw.FixedColumnWidth(40),
                    1: pw.FixedColumnWidth(36),
                    2: pw.FixedColumnWidth(141),
                    3: pw.FixedColumnWidth(130),
                    4: pw.FixedColumnWidth(45),
                  },
                  children: mainDeckData.map((row) {
                    return pw.TableRow(
                      children: row.map((cell) {
                        return pw.Container(
                          height: 15.4,
                          child: pw.Text(cell!,
                              style: tableStyle,
                              textAlign: pw.TextAlign.center),
                          padding: const pw.EdgeInsets.all(2),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
              pw.Positioned(
                left: 96,
                top: 730.5,
                child: pw.Table(
                  columnWidths: {
                    0: pw.FixedColumnWidth(40),
                    1: pw.FixedColumnWidth(36),
                    2: pw.FixedColumnWidth(141),
                    3: pw.FixedColumnWidth(130),
                    4: pw.FixedColumnWidth(45),
                  },
                  children: digitamaDeckData.map((row) {
                    return pw.TableRow(
                      children: row.map((cell) {
                        return pw.Container(
                          height: 15.4,
                          child: pw.Text(cell!,
                              style: tableStyle,
                              textAlign: pw.TextAlign.center),
                          padding: const pw.EdgeInsets.all(4),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    downloadPDF(bytes, '${deck.deckName}.pdf');
  }

  Future<void> downloadPDF(Uint8List pdfData, String fileName) async {
    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Future<Deck?> createDeckByLocalJsonString(String jsonString) async {
    Map<String, dynamic> map = jsonDecode(jsonString);
    String deckName = map['deckName'];
    Map<String, dynamic> deckMapJson =
        Map<String, dynamic>.from(map['deckMap']);


    DeckResponseDto? deckResponseDto =
        await DeckApi().importDeckThisSite(deckMapJson);
    if (deckResponseDto == null) {
      return null;
    }
    Deck deck = Deck();
    deck.deckName=deckName;
    deck.import(deckResponseDto);
    return deck;
  }
}
