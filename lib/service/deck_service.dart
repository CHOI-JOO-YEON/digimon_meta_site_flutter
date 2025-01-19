import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:digimon_meta_site_flutter/api/deck_api.dart';
import 'package:digimon_meta_site_flutter/model/deck-view.dart';
import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/paged_response_deck_dto.dart';
import 'package:digimon_meta_site_flutter/provider/format_deck_count_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:zxing2/qrcode.dart';
import 'dart:html' as html;
import '../model/card.dart';
import '../model/deck-build.dart';

import '../model/format.dart';
import '../provider/limit_provider.dart';
import 'package:image/image.dart' as imglib;

class DeckService {
  DeckApi deckApi = DeckApi();

  Future<DeckBuild?> save(DeckBuild deck, BuildContext context) async {
    DeckView? responseDto = await deckApi.postDeck(deck);
    if (responseDto != null) {
      return DeckBuild.deckView(responseDto, context);
    }
    return null;
  }

  Future<DeckView?> import(Map<String, int> deck) async {
    DeckView? responseDto = await deckApi.importDeck(deck);
    if (responseDto != null) {
      return responseDto;
    }
    return null;
  }

  Future exportToTTSFile(DeckBuild deck) async {
    dynamic jsonData = await deckApi.exportDeckToTTSFile(deck);

    if (jsonData != null) {
      String jsonString = jsonEncode(jsonData);

      final blob = html.Blob([jsonString]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement anchor = html.AnchorElement(href: url)
        ..setAttribute("download", '${deck.deckName}.json')
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  Future<Map<int, FormatDto>> getFormats(DeckBuild deck) async {
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

    if(decks != null) {
      FormatDeckCountProvider formatDeckCountProvider = Provider.of(context, listen: false);
      deckSearchParameter.isMyDeck?formatDeckCountProvider.setFormatMyDeckCount(decks):formatDeckCountProvider.setFormatAllDeckCount(decks);
    }
    

    return decks;
  }

  Future<bool> deleteDeck(int deckId) async {
    return await DeckApi().deleteDeck(deckId);
  }

  Future<void> generateDeckRecipePDF(DeckBuild deck) async {
    final pdfData = await rootBundle.load('assets/doc/digimon_recipe.jpg');

    final pdf = pw.Document();

    final mainDeckMap = <String, List<dynamic>>{};

    for (var card in deck.deckCards) {
      String cardNo = card.cardNo!;
      int count = deck.deckMap[card]!;
      if (mainDeckMap.containsKey(cardNo)) {
        mainDeckMap[cardNo]![4] =
            (int.parse(mainDeckMap[cardNo]![4]) + count).toString();
      } else {
        mainDeckMap[cardNo] = [
          cardNo,
          card.lv == null || card.lv == 0 ? '-' : card.lv.toString(),
          card.getDisplayName(),
          card.getKorCardType(),
          count.toString()
        ];
      }
    }

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
          card.getDisplayName(),
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
                top: 731.5,
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
                          padding: const pw.EdgeInsets.all(2),
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

  Future<DeckBuild?> createDeckByLocalJsonString(
      String jsonString, BuildContext context) async {
    Map<String, dynamic> map = jsonDecode(jsonString);
    String deckName = map['deckName'];
    bool isStrict = map['isStrict'];
    Map<String, dynamic> deckMapJson =
        Map<String, dynamic>.from(map['deckMap']);

    DeckView? deckResponseDto = await DeckApi().importDeckThisSite(deckMapJson);

    if (deckResponseDto == null) {
      return null;
    }
    DeckBuild deck = DeckBuild(context);
    deck.deckName = deckName;
    deck.isStrict = isStrict;
    deck.import(deckResponseDto);
    return deck;
  }
  
  Future<String?> decodeQrCodeFromImage(Uint8List imageBytes) async {
    // 1) 이미지 디코딩
    final rawImage = imglib.decodeImage(imageBytes);
    if (rawImage == null) {
      // 디코딩 실패 (이미지가 아니거나 손상됨)
      return null;
    }

    final imageData = rawImage.data; // ImageData? 타입
    if (imageData == null) {
      // data가 없는 경우 (이론상 잘 없지만 안전하게 체크)
      return null;
    }

    // 보통 imageData.type == ImageDataType.uint8 (RGBA 8비트)
    // buffer가 실제 픽셀 바이트 배열 (Uint8List or null)
    final buffer = imageData.getBytes();
    if (buffer == null || buffer is! Uint8List) {
      // RGBA 픽셀 데이터를 읽을 수 없음
      return null;
    }

    // 2) RGBA -> ARGB 변환
    //   RGBA(4 bytes) = R, G, B, A 순서
    //   ARGB(32bit int) = 0xAARRGGBB 순서
    final width = rawImage.width;
    final height = rawImage.height;
    final pixelCount = width * height;
    // 픽셀 하나당 4바이트이므로, buffer 길이는 pixelCount*4 이상이어야 함
    if (buffer.length < pixelCount * 4) {
      return null;
    }

    final int32Data = Int32List(pixelCount);
    for (int i = 0; i < pixelCount; i++) {
      final r = buffer[i * 4 + 0];
      final g = buffer[i * 4 + 1];
      final b = buffer[i * 4 + 2];
      final a = buffer[i * 4 + 3];
      // 0xAARRGGBB 형태의 int (alpha가 최상위 바이트)
      int32Data[i] = (a << 24) | (r << 16) | (g << 8) | b;
    }

    // 3) zxing2로 QR 디코딩
    final luminanceSource = RGBLuminanceSource(width, height, int32Data);
    final binarizer = HybridBinarizer(luminanceSource);
    final bitmap = BinaryBitmap(binarizer);

    final reader = QRCodeReader();
    try {
      final result = reader.decode(bitmap);
      return result.text; // QR 코드 내용
    } catch (e) {
      // QR/바코드 인식 실패
      return null;
    }
  }

}
