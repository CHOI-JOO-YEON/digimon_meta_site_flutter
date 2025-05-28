import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:digimon_meta_site_flutter/api/deck_api.dart';
import 'package:digimon_meta_site_flutter/model/deck-view.dart';
import 'package:digimon_meta_site_flutter/model/deck_search_parameter.dart';
import 'package:digimon_meta_site_flutter/model/paged_response_deck_dto.dart';
import 'package:digimon_meta_site_flutter/provider/format_deck_count_provider.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:digimon_meta_site_flutter/widget/common/toast_overlay.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:zxing2/qrcode.dart';
import 'dart:html' as html;
import '../enums/site_enum.dart';
import '../model/card.dart';
import '../model/deck-build.dart';
import 'package:auto_route/auto_route.dart';

import '../model/format.dart';
import '../model/limit_dto.dart';
import '../model/user_setting_dto.dart';
import '../provider/deck_sort_provider.dart';
import '../provider/limit_provider.dart';
import '../provider/user_provider.dart';
import '../service/user_setting_service.dart';
import 'package:image/image.dart' as imglib;

import '../router.dart';
import 'card_overlay_service.dart';
import 'color_service.dart';
import 'lang_service.dart';
import 'card_data_service.dart';
import '../model/sort_criterion_dto.dart';

class DeckService {
  DeckApi deckApi = DeckApi();

  Future<DeckBuild?> save(DeckBuild deck, BuildContext context) async {
    DeckView? responseDto = await deckApi.postDeck(deck);
    if (responseDto != null) {
      _refreshFormatDeckCounts(context);
      return DeckBuild.deckView(responseDto, context);
    }
    return null;
  }

  void _refreshFormatDeckCounts(BuildContext context) {
    try {
      Provider.of<FormatDeckCountProvider>(context, listen: false)
          .loadDeckCounts();
    } catch (e) {
    }
  }

  DeckBuild import(Map<String, int> deck, BuildContext context) {
    DeckBuild deckBuild = DeckBuild(context); 
    CardDataService cardDataService = CardDataService();
    deck.forEach((cardNo, count) {
      DigimonCard? card = cardDataService.getCardByCardNo(cardNo);
      if (card != null) {
        for (int i = 0; i < count; i++) {
          deckBuild.addSingleCard(card);
        }
      }
    });
    return deckBuild;
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

    return decks;
  }

  Future<bool> deleteDeck(int deckId) async {
    return await DeckApi().deleteDeck(deckId);
  }

  Future<bool> deleteDeckAndRefreshCounts(
      int deckId, BuildContext context) async {
    bool result = await deleteDeck(deckId);
    if (result) {
      _refreshFormatDeckCounts(context);
    }
    return result;
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
    
    // Helper function to determine font size based on text length
    double getFontSize(String text, double maxWidth, double baseFontSize) {
      // Estimate character width (approximate) - more conservative estimate
      double estimatedCharWidth = baseFontSize * 0.7; // Increased from 0.6 to be more conservative
      double estimatedTextWidth = text.length * estimatedCharWidth;
      
      if (estimatedTextWidth <= maxWidth) {
        return baseFontSize;
      } else {
        // Calculate reduced font size to fit within maxWidth with some padding
        double scaleFactor = (maxWidth * 0.95) / estimatedTextWidth; // Use 95% of available width for safety
        double newFontSize = baseFontSize * scaleFactor;
        // Set minimum font size to maintain readability
        return newFontSize < 4.0 ? 4.0 : newFontSize; // Reduced minimum from 5.0 to 4.0
      }
    }
    
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
                top: 205,
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
                      children: row.asMap().entries.map((entry) {
                        int index = entry.key;
                        String cell = entry.value.toString();
                        
                        // Apply dynamic font sizing for card name (index 2) and card type (index 3)
                        double fontSize = 7.0;
                        if (index == 2) {
                          // Card name column - width 141
                          fontSize = getFontSize(cell, 135.0, 7.0);
                        } else if (index == 3) {
                          // Card type column - width 130
                          fontSize = getFontSize(cell, 124.0, 7.0);
                        }
                        
                        return pw.Container(
                          height: 15.4,
                          alignment: pw.Alignment.center,
                          child: pw.Text(cell,
                              style: pw.TextStyle(font: font, fontSize: fontSize),
                              textAlign: pw.TextAlign.center,
                              overflow: pw.TextOverflow.visible),
                          padding: const pw.EdgeInsets.all(2),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
              pw.Positioned(
                left: 96,
                top: 730,
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
                      children: row.asMap().entries.map((entry) {
                        int index = entry.key;
                        String cell = entry.value.toString();
                        
                        // Apply dynamic font sizing for card name (index 2) and card type (index 3)
                        double fontSize = 7.0;
                        if (index == 2) {
                          // Card name column - width 141
                          fontSize = getFontSize(cell, 135.0, 7.0);
                        } else if (index == 3) {
                          // Card type column - width 130
                          fontSize = getFontSize(cell, 124.0, 7.0);
                        }
                        
                        return pw.Container(
                          height: 15.4,
                          alignment: pw.Alignment.center,
                          child: pw.Text(cell,
                              style: pw.TextStyle(font: font, fontSize: fontSize),
                              textAlign: pw.TextAlign.center,
                              overflow: pw.TextOverflow.visible),
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
    bool isStrict = map['isStrict'] ?? true;
    String? description = map['description'];
    Map<String, int> cardIdAndCntMap =
        Map<String, int>.from(map['deckMap']);
    
    Map<String, int> tamaCardIdAndCntMap = {};
    if (map.containsKey('tamaMap')) {
      tamaCardIdAndCntMap = Map<String, int>.from(map['tamaMap']);
    }

    DeckBuild deck = importDeckThisSite(cardIdAndCntMap, context);
    
    // 타마 카드 추가
    if (tamaCardIdAndCntMap.isNotEmpty) {
      CardDataService cardDataService = CardDataService();
      for (final entry in tamaCardIdAndCntMap.entries) {
        final cardId = entry.key;
        final count = entry.value;
        final card = await cardDataService.getCardById(int.parse(cardId));
        if (card != null) {
          for (int i = 0; i < count; i++) {
            deck.addSingleCard(card);
          }
        }
      }
    }
    
    deck.deckName = deckName;
    deck.isStrict = isStrict;
    deck.description = description;
    return deck;
  }

  Future<String?> decodeQrCodeFromImage(Uint8List imageBytes) async {
    // 기본 이미지 디코딩
    final rawImage = imglib.decodeImage(imageBytes);
    if (rawImage == null) {
      return null;
    }

    // 오른쪽 상단 QR 코드 영역 추출 (항상 QR 코드가 있는 위치)
    final qrRegion = _extractTopRightRegion(rawImage);
    
    // 1. 추출한 영역 그대로 스캔 시도
    String? result = await _scanQRCode(qrRegion);
    if (result != null) {
      return result;
    }
    
    // 2. 추출한 영역에 이미지 처리 기법 적용
    return await _enhanceAndScanQRRegion(qrRegion);
  }
  
  // 추출된 이미지를 PNG로 다운로드 (디버깅용)
  void _downloadImage(imglib.Image image, String filename) {
    // 디버깅 코드 비활성화
    return;

    /*
    try {
      // 이미지를 PNG로 인코딩
      List<int> pngBytes = imglib.encodePng(image);
      
      // Blob 생성
      final blob = html.Blob([Uint8List.fromList(pngBytes)], 'image/png');
      
      // 다운로드 URL 생성
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // 다운로드 링크 생성 및 클릭
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = filename;
      
      html.document.body?.children.add(anchor);
      anchor.click();
      
      // 클린업
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error downloading image: $e');
    }
    */
  }
  
  // 오른쪽 상단 QR 코드 영역 추출
  imglib.Image _extractTopRightRegion(imglib.Image image) {
    // QR 코드 영역 크기 계산 - 최소 150x150 보장
    int qrSize = 150;
    
    // 이미지가 작은 경우 전체 이미지 반환
    if (image.width < qrSize * 2 || image.height < qrSize * 2) {
      return image;
    }
    
    // 오른쪽 상단 영역 추출 - 여유있게 QR 코드 영역을 포함하도록 함
    int extractWidth = min(image.width ~/ 3, 300);
    extractWidth = max(extractWidth, qrSize);
    
    int extractHeight = min(image.height ~/ 3, 300);
    extractHeight = max(extractHeight, qrSize);
    
    // 오른쪽 상단 위치 계산
    int x = max(0, image.width - extractWidth);
    int y = 0;
    
    return imglib.copyCrop(
      image,
      x: x,
      y: y,
      width: extractWidth,
      height: extractHeight,
    );
  }
  
  // QR 영역에 집중 처리 기법 적용
  Future<String?> _enhanceAndScanQRRegion(imglib.Image qrRegion) async {
    // 원본 이미지 업스케일링 (저해상도 이미지 개선을 위해)
    final upscaled = imglib.copyResize(
      qrRegion,
      width: qrRegion.width * 2,
      height: qrRegion.height * 2,
      interpolation: imglib.Interpolation.cubic
    );
    String? result = await _scanQRCode(upscaled);
    if (result != null) return result;
    
    // 1. 그레이스케일 변환
    final grayscale = imglib.grayscale(upscaled);
    result = await _scanQRCode(grayscale);
    if (result != null) return result;
    
    // 2. 노이즈 감소 처리
    final denoised = _applyMedianFilter(grayscale, 3);
    result = await _scanQRCode(denoised);
    if (result != null) return result;
    
    // 3. 선명도 향상
    final sharpened = _sharpenImage(denoised);
    result = await _scanQRCode(sharpened);
    if (result != null) return result;
    
    // 4. 적응형 이진화 처리 
    final adaptiveThresholded = _applyAdaptiveThreshold(sharpened);
    result = await _scanQRCode(adaptiveThresholded);
    if (result != null) return result;
    
    // 5. 대비 향상 단계별 적용
    final contrastLevels = [1.5, 2.0, 2.5, 3.0];
    for (var contrast in contrastLevels) {
      final enhanced = imglib.adjustColor(
        grayscale, 
        contrast: contrast,
        brightness: 0.0,
      );
      result = await _scanQRCode(enhanced);
      if (result != null) return result;
      
      // 대비 향상 + 이진화 조합 시도
      for (int threshold in [100, 128, 150, 180]) {
        final binarized = _applySimpleThreshold(enhanced, threshold);
        result = await _scanQRCode(binarized);
        if (result != null) return result;
      }
    }
    
    // 6. 여러 크기로 조정 시도
    final scales = [1.5, 2.0, 2.5, 0.8, 0.6];
    for (var scale in scales) {
      final resized = imglib.copyResize(
        grayscale,
        width: (grayscale.width * scale).round(),
        height: (grayscale.height * scale).round(),
        interpolation: imglib.Interpolation.cubic
      );
      
      result = await _scanQRCode(resized);
      if (result != null) return result;
      
      // 크기 조정 + 선명화 + 대비 향상
      final enhancedResized = _sharpenImage(imglib.adjustColor(
        resized,
        contrast: 2.2,
        brightness: 0.0,
      ));
      result = await _scanQRCode(enhancedResized);
      if (result != null) return result;
      
      // 크기 조정 + 이진화
      final binarizedResized = _applySimpleThreshold(resized, 128);
      result = await _scanQRCode(binarizedResized);
      if (result != null) return result;
    }
    
    // 7. 외곽선 강화 처리
    final edgeEnhanced = _enhanceEdges(grayscale);
    result = await _scanQRCode(edgeEnhanced);
    if (result != null) return result;
    
    // 8. 각도 보정 (QR 코드가 회전된 경우)
    final angles = [90.0, 180.0, 270.0, 45.0, -45.0];
    for (var angle in angles) {
      final rotated = imglib.copyRotate(grayscale, angle: angle);
      result = await _scanQRCode(rotated);
      if (result != null) return result;
    }
    
    return null;
  }
  
  // 중앙값 필터를 사용한 노이즈 감소 (가장 좋은 노이즈 감소 기법 중 하나)
  imglib.Image _applyMedianFilter(imglib.Image image, int radius) {
    final result = imglib.Image.from(image);
    
    for (int y = radius; y < image.height - radius; y++) {
      for (int x = radius; x < image.width - radius; x++) {
        List<int> neighborValues = [];
        
        // 주변 픽셀 수집
        for (int dy = -radius; dy <= radius; dy++) {
          for (int dx = -radius; dx <= radius; dx++) {
            imglib.Pixel pixel = image.getPixel(x + dx, y + dy);
            neighborValues.add(pixel.r.toInt());
          }
        }
        
        // 중앙값 계산
        neighborValues.sort();
        int medianValue = neighborValues[neighborValues.length ~/ 2];
        
        // 중앙값으로 픽셀 설정
        result.setPixel(x, y, imglib.ColorRgb8(medianValue, medianValue, medianValue));
      }
    }
    
    return result;
  }
  
  // 이미지 선명화 (언샤프 마스킹)
  imglib.Image _sharpenImage(imglib.Image image) {
    final result = imglib.Image.from(image);
    final blurred = imglib.gaussianBlur(image, radius: 1);
    
    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final originalPixel = image.getPixel(x, y);
        final blurredPixel = blurred.getPixel(x, y);
        
        // 언샤프 마스킹 적용
        int sharpValue = (2 * originalPixel.r.toInt() - blurredPixel.r.toInt()).clamp(0, 255);
        result.setPixel(x, y, imglib.ColorRgb8(sharpValue, sharpValue, sharpValue));
      }
    }
    
    return result;
  }
  
  // 적응형 이진화 (저해상도 이미지에 효과적)
  imglib.Image _applyAdaptiveThreshold(imglib.Image image) {
    final result = imglib.Image.from(image);
    final radius = 7; // 적응형 영역 크기
    final diff = 7;   // 임계값 차이
    
    for (int y = radius; y < image.height - radius; y++) {
      for (int x = radius; x < image.width - radius; x++) {
        // 주변 영역 평균 계산
        int sum = 0;
        int count = 0;
        
        for (int dy = -radius; dy <= radius; dy++) {
          for (int dx = -radius; dx <= radius; dx++) {
            if (y + dy >= 0 && y + dy < image.height && 
                x + dx >= 0 && x + dx < image.width) {
              imglib.Pixel pixel = image.getPixel(x + dx, y + dy);
              sum += pixel.r.toInt();
              count++;
            }
          }
        }
        
        int average = sum ~/ count;
        int threshold = average - diff;
        
        // 중앙 픽셀 이진화
        imglib.Pixel centerPixel = image.getPixel(x, y);
        if (centerPixel.r.toInt() > threshold) {
          result.setPixel(x, y, imglib.ColorRgb8(255, 255, 255));
        } else {
          result.setPixel(x, y, imglib.ColorRgb8(0, 0, 0));
        }
      }
    }
    
    // 경계 픽셀 처리
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        if (y < radius || y >= image.height - radius || 
            x < radius || x >= image.width - radius) {
          imglib.Pixel pixel = image.getPixel(x, y);
          if (pixel.r.toInt() > 128) {
            result.setPixel(x, y, imglib.ColorRgb8(255, 255, 255));
          } else {
            result.setPixel(x, y, imglib.ColorRgb8(0, 0, 0));
          }
        }
      }
    }
    
    return result;
  }
  
  // 단순 임계값 이진화
  imglib.Image _applySimpleThreshold(imglib.Image image, int threshold) {
    final binary = imglib.Image.from(image);
    
    for (int y = 0; y < binary.height; y++) {
      for (int x = 0; x < binary.width; x++) {
        imglib.Pixel pixel = binary.getPixel(x, y);
        
        // 임계값 적용
        if (pixel.r.toInt() > threshold) {
          binary.setPixel(x, y, imglib.ColorRgb8(255, 255, 255));
        } else {
          binary.setPixel(x, y, imglib.ColorRgb8(0, 0, 0));
        }
      }
    }
    
    return binary;
  }
  
  // 외곽선 강화
  imglib.Image _enhanceEdges(imglib.Image image) {
    final result = imglib.Image.from(image);
    
    // 소벨 에지 검출 커널
    final sobelX = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1]
    ];
    
    final sobelY = [
      [-1, -2, -1],
      [0, 0, 0],
      [1, 2, 1]
    ];
    
    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        int gx = 0;
        int gy = 0;
        
        // 소벨 커널 적용
        for (int ky = -1; ky <= 1; ky++) {
          for (int kx = -1; kx <= 1; kx++) {
            imglib.Pixel pixel = image.getPixel(x + kx, y + ky);
            int val = pixel.r.toInt();
            
            gx += val * sobelX[ky + 1][kx + 1];
            gy += val * sobelY[ky + 1][kx + 1];
          }
        }
        
        // 그래디언트 크기 계산
        int magnitude = sqrt(gx * gx + gy * gy).toInt().clamp(0, 255);
        
        // 원본 이미지와 엣지를 합성
        imglib.Pixel originalPixel = image.getPixel(x, y);
        int originalValue = originalPixel.r.toInt();
        int enhancedValue = (originalValue * 0.7 + magnitude * 0.3).toInt().clamp(0, 255);
        
        result.setPixel(x, y, imglib.ColorRgb8(enhancedValue, enhancedValue, enhancedValue));
      }
    }
    
    return result;
  }
  
  // ZXing 라이브러리를 사용한 QR 코드 스캔
  Future<String?> _scanQRCode(imglib.Image image) async {
    try {
      final imageData = image.data;
      if (imageData == null) return null;
      
      final buffer = imageData.getBytes();
      if (buffer == null || buffer is! Uint8List) return null;
      
      final width = image.width;
      final height = image.height;
      final pixelCount = width * height;
      
      if (buffer.length < pixelCount * 4) return null;
      
      // ZXing 라이브러리가 요구하는 포맷으로 변환
      final int32Data = Int32List(pixelCount);
      for (int i = 0; i < pixelCount; i++) {
        final r = buffer[i * 4 + 0];
        final g = buffer[i * 4 + 1];
        final b = buffer[i * 4 + 2];
        final a = buffer[i * 4 + 3];
        int32Data[i] = (a << 24) | (r << 16) | (g << 8) | b;
      }
      
      final luminanceSource = RGBLuminanceSource(width, height, int32Data);
      final binarizer = HybridBinarizer(luminanceSource);
      final bitmap = BinaryBitmap(binarizer);
      
      // QR 코드 리더 객체 생성
      final reader = QRCodeReader();
      
      // 기본 디코딩 시도
      try {
        final result = reader.decode(bitmap);
        return result.text;
      } catch (e) {
        // 첫 번째 시도 실패, 다른 방식 시도 (ZXing 라이브러리 제약으로 힌트를 사용할 수 없음)
        // 이 라이브러리 버전은 별도의 힌트 파라미터를 지원하지 않음
        return null;
      }
    } catch (e) {
      // QR 코드 인식 실패는 정상적인 경우
      return null;
    }
  }

  void showDeckReceiptDialog(BuildContext context, DeckBuild deck) {
    CardOverlayService().removeAllOverlays();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('대회 제출용 레시피 다운로드'),
          content: const SizedBox(
            width: 300,
            child: Text(
              '* 덱은 31종, 디지타마는 5종까지만 레시피에 기입되며, 이를 초과하는 카드 종류는 레시피에 반영되지 않습니다.\n* 레시피 불일치로 발생하는 문제는 책임지지 않으며, 제출 전 꼭 확인 바랍니다.',
              softWrap: true,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            ElevatedButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(
                '다운로드',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await DeckService().generateDeckRecipePDF(deck);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showDeckCopyDialog(BuildContext context, DeckBuild deck) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('덱 복사'),
          content: Text('이 덱을 카피하여 새로운 덱을 만들겠습니까?'),
          actions: [
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('예'),
              onPressed: () {
                deck.newCopy();
                
                Navigator.of(context).pop();
                
                // 토스트 메시지 표시
                ToastOverlay.show(
                  context,
                  '덱이 복사되었습니다.',
                  type: ToastType.success
                );

                // 새 덱 복사본을 생성하지 않고, 현재 덱의 상태를 업데이트한 후 리디렉션
                context.navigateTo(DeckBuilderRoute(deck: deck));
              },
            ),
          ],
        );
      },
    );
  }

  void showExportDialog(BuildContext context, DeckBuild deck) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        SiteName selectedButton = SiteName.values.first;
        TextEditingController textEditingController = TextEditingController(
          text: selectedButton.ExportToSiteDeckCode(deck),
        );

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('내보내기'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: SiteName.values.map((siteName) {
                        String name = siteName.getName;
                        return Expanded(
                          child: ListTile(
                            title: Text(name),
                            leading: Radio<SiteName>(
                              value: siteName,
                              groupValue: selectedButton,
                              onChanged: (SiteName? value) {
                                setState(() {
                                  selectedButton = value!;
                                  textEditingController.text =
                                      selectedButton.ExportToSiteDeckCode(deck);
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    TextField(
                      controller: textEditingController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Paste your deck.',
                      ),
                      enabled: false,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                    text: textEditingController.text))
                                .then((_) {
                              ToastOverlay.show(
                                context,
                                '클립보드에 복사되었습니다.',
                                type: ToastType.success,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showOrderMapDialog(BuildContext context, SortCriterion criterion,
      StateSetter parentSetState, double width) {
    List<String> items = criterion.orderMap!.keys.toList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(
                '${DeckSortProvider().getSortPriorityKor(criterion.field)} 순서 변경'),
            content: SizedBox(
              width: width,
              child: ReorderableListView(
                shrinkWrap: true,
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final String item = items.removeAt(oldIndex);
                    items.insert(newIndex, item);
                  });
                },
                children: [
                  for (int index = 0; index < items.length; index++)
                    ListTile(
                      key: ValueKey(items[index]),
                      title: Text(LangService().getKorText(items[index])),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('확인'),
                onPressed: () {
                  // Update the orderMap
                  parentSetState(() {
                    criterion.orderMap = {
                      for (int i = 0; i < items.length; i++) items[i]: i + 1
                    };
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  void showDeckSettingDialog(
      BuildContext context, DeckBuild deck, Function() reload) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    double width = isPortrait
        ? MediaQuery.sizeOf(context).width * 0.9
        : MediaQuery.sizeOf(context).width / 3;
    double height = MediaQuery.sizeOf(context).height / 2;
    CardOverlayService().removeAllOverlays();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer3<LimitProvider, DeckSortProvider, UserProvider>(
          builder: (context, limitProvider, deckSortProvider, userProvider, child) {
            // selectedLimit 초기화 - 저장된 설정을 확인하여 초기화
            LimitDto? selectedLimit = limitProvider.selectedLimit;
            
            // 로컬 스토리지에서 defaultLimitId 직접 확인
            final defaultLimitIdStr = html.window.localStorage['defaultLimitId'];
            final defaultLimitId = defaultLimitIdStr != null ? int.tryParse(defaultLimitIdStr) : null;
            
            if (defaultLimitId == null || defaultLimitId == 0) {
              // defaultLimitId가 null이거나 0이면 "항상 최신 금제로 설정" 옵션으로 설정
              selectedLimit = LimitDto(
                id: 0,
                restrictionBeginDate: DateTime.now(),
                allowedQuantityMap: {},
                limitPairs: [],
              );
            }
            
            bool isStrict = deck.isStrict;
            List<SortCriterion> sortPriority = List.from(
              deckSortProvider.sortPriority.map(
                (criterion) => SortCriterion(
                  criterion.field,
                  ascending: criterion.ascending,
                  orderMap: criterion.orderMap != null
                      ? Map<String, int>.from(criterion.orderMap!)
                      : null,
                ),
              ),
            );

            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: width,
                height: height,
                child: AlertDialog(
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('취소'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (!deck.isStrict && isStrict) {
                              // 엄격한 덱 작성 모드 활성화 시 먼저 확인
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('경고'),
                                    content: Text(
                                        '엄격한 덱 작성 모드를 활성화하시겠습니까? \n지금까지 작성된 내용은 사라집니다.'),
                                    actions: [
                                      TextButton(
                                        child: Text('취소'),
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close warning dialog
                                        },
                                      ),
                                      TextButton(
                                        child: Text('확인'),
                                        onPressed: () async {
                                          // 확인 후 설정 저장
                                          UserSettingDto setting = UserSettingDto(
                                            defaultLimitId: selectedLimit?.id == 0 ? 0 : selectedLimit?.id,
                                            strictDeck: isStrict,
                                            sortPriority: sortPriority.map((criterion) => 
                                              SortCriterionDto(
                                                field: criterion.field,
                                                ascending: criterion.ascending,
                                                orderMap: criterion.orderMap,
                                              )
                                            ).toList(),
                                          );

                                          // 설정을 즉시 적용
                                          await UserSettingService().applyUserSetting(context, setting);

                                          // 서버에 설정 저장 (로그인된 경우)
                                          if (userProvider.isLogin) {
                                            bool saveSuccess = await UserSettingService().saveUserSetting(context, setting);
                                            if (saveSuccess) {
                                              ToastOverlay.show(
                                                context,
                                                '설정이 서버에 저장되었습니다.',
                                                type: ToastType.success
                                              );
                                            } else {
                                              ToastOverlay.show(
                                                context,
                                                '서버 저장에 실패했습니다. 브라우저에만 저장됩니다.',
                                                type: ToastType.warning
                                              );
                                            }
                                          } else {
                                            // 로컬에만 저장
                                            await UserSettingService().saveUserSetting(context, setting);
                                            ToastOverlay.show(
                                              context,
                                              '설정이 브라우저에 저장되었습니다.',
                                              type: ToastType.info
                                            );
                                          }

                                          // Apply changes after confirmation
                                          if (selectedLimit != null) {
                                            limitProvider.updateSelectLimit(
                                                selectedLimit!.restrictionBeginDate);
                                          }
                                          deck.clear();
                                          deck.updateIsStrict(isStrict);
                                          deckSortProvider.setSortPriority(sortPriority);
                                          reload();
                                          Navigator.of(context).pop(); // Close warning dialog
                                          Navigator.of(context).pop(); // Close settings dialog
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              // 일반적인 경우 설정 저장
                              UserSettingDto setting = UserSettingDto(
                                defaultLimitId: selectedLimit?.id == 0 ? 0 : selectedLimit?.id,
                                strictDeck: isStrict,
                                sortPriority: sortPriority.map((criterion) => 
                                  SortCriterionDto(
                                    field: criterion.field,
                                    ascending: criterion.ascending,
                                    orderMap: criterion.orderMap,
                                  )
                                ).toList(),
                              );

                              // 설정을 즉시 적용
                              await UserSettingService().applyUserSetting(context, setting);

                              // 서버에 설정 저장 (로그인된 경우)
                              if (userProvider.isLogin) {
                                bool saveSuccess = await UserSettingService().saveUserSetting(context, setting);
                                if (saveSuccess) {
                                  ToastOverlay.show(
                                    context,
                                    '설정이 서버에 저장되었습니다.',
                                    type: ToastType.success
                                  );
                                } else {
                                  ToastOverlay.show(
                                    context,
                                    '서버 저장에 실패했습니다. 로컬에만 저장됩니다.',
                                    type: ToastType.warning
                                  );
                                }
                              } else {
                                // 로컬에만 저장
                                await UserSettingService().saveUserSetting(context, setting);
                                ToastOverlay.show(
                                  context,
                                  '설정이 로컬에 저장되었습니다.',
                                  type: ToastType.info
                                );
                              }

                              // Proceed without warning
                              if (selectedLimit != null) {
                                limitProvider.updateSelectLimit(
                                    selectedLimit!.restrictionBeginDate);
                              }
                              deck.updateIsStrict(isStrict);
                              deckSortProvider.setSortPriority(sortPriority);
                              reload();
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  ],
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            '금지/제한: ',
                            style: TextStyle(
                                fontSize: SizeService.bodyFontSize(context)),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: DropdownButtonFormField<LimitDto>(
                              value: selectedLimit?.id == 0 ? null : selectedLimit,
                              hint: selectedLimit?.id == 0 
                                  ? Text(
                                      '항상 최신 금제로 설정',
                                      style: TextStyle(
                                        fontSize: SizeService.bodyFontSize(context),
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    )
                                  : Text(
                                      '금지/제한 선택',
                                      style: TextStyle(
                                        fontSize: SizeService.bodyFontSize(context),
                                      ),
                                    ),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedLimit = newValue;
                                  // "항상 최신 금제로 설정" 옵션을 선택한 경우
                                  if (newValue != null && newValue.id == 0) {
                                    selectedLimit = LimitDto(
                                      id: 0,
                                      restrictionBeginDate: DateTime.now(),
                                      allowedQuantityMap: {},
                                      limitPairs: [],
                                    );
                                  }
                                });
                              },
                              items: [
                                // 최신 금제 옵션 추가 - 가장 최근 금제 날짜 표시
                                DropdownMenuItem<LimitDto>(
                                  value: LimitDto(
                                    id: 0,
                                    restrictionBeginDate: DateTime.now(),
                                    allowedQuantityMap: {},
                                    limitPairs: [],
                                  ),
                                  child: Text(
                                    '항상 최신 금제로 설정${limitProvider.limits.isNotEmpty ? ' (현재: ${DateFormat('yyyy-MM-dd').format(limitProvider.limits.values.reduce((a, b) => a.restrictionBeginDate.isAfter(b.restrictionBeginDate) ? a : b).restrictionBeginDate)})' : ''}',
                                    style: TextStyle(
                                      fontSize: SizeService.bodyFontSize(context),
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                // 기존 금제 목록들의 선택 시 표시될 텍스트
                                ...limitProvider.limits.values.map((limitDto) {
                                  return DropdownMenuItem<LimitDto>(
                                    value: limitDto,
                                    child: Text(
                                      '${DateFormat('yyyy-MM-dd').format(limitDto.restrictionBeginDate)}',
                                      style: TextStyle(
                                        fontSize:
                                            SizeService.bodyFontSize(context),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            '엄격한 덱 작성 모드',
                            style: TextStyle(
                                fontSize: SizeService.bodyFontSize(context)),
                          ),
                          Transform.scale(
                            scale: SizeService.switchScale(context),
                            child: Switch(
                              inactiveThumbColor: Colors.red,
                              value: isStrict,
                              onChanged: (bool v) {
                                setState(() {
                                  isStrict = v;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '정렬 우선순위 변경',
                            style: TextStyle(
                                fontSize: SizeService.bodyFontSize(context)),
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  // 정렬 우선순위만 초기화
                                  sortPriority = deckSortProvider.getOriginalSortPriority();
                                });
                              },
                              icon: Icon(Icons.refresh))
                        ],
                      ),
                      SizedBox(
                        width: width * 0.8,
                        height: height * 0.6,
                        child: ReorderableListView.builder(
                          shrinkWrap: true,
                          itemCount: sortPriority.length,
                          onReorder: (int oldIndex, int newIndex) {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final SortCriterion item =
                                sortPriority.removeAt(oldIndex);
                            sortPriority.insert(newIndex, item);
                            setState(() {});
                          },
                          itemBuilder: (BuildContext context, int index) {
                            final criterion = sortPriority[index];
                            return ListTile(
                              key: ValueKey('${criterion.field}-$index'),
                              title: Text(
                                deckSortProvider
                                    .getSortPriorityKor(criterion.field),
                                style: TextStyle(
                                    fontSize:
                                        SizeService.smallFontSize(context)),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (criterion.field == 'cardType' ||
                                      criterion.field == 'color1' ||
                                      criterion.field == 'color2')
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        showOrderMapDialog(context, criterion,
                                            setState, width * 0.8);
                                      },
                                    ),
                                  IconButton(
                                    tooltip: '오름차순/내림차순',
                                    icon: (criterion.ascending ?? true)
                                        ? const Icon(Icons.arrow_drop_up)
                                        : const Icon(Icons.arrow_drop_down),
                                    onPressed: () {
                                      setState(() {
                                        criterion.ascending =
                                            !(criterion.ascending ?? true);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            });
          },
        );
      },
    );
  }

  void showImportDialog(BuildContext context, Function(DeckBuild) importAction) {
    CardOverlayService().removeAllOverlays();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        SiteName selectedButton = SiteName.values.first;
        TextEditingController textEditingController = TextEditingController();
        bool isSubmitted = false;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('덱 가져오기'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: SiteName.values.map((siteName) {
                        String name = siteName.getName;
                        return Expanded(
                          child: ListTile(
                            title: Text(name),
                            leading: Radio<SiteName>(
                              value: siteName,
                              groupValue: selectedButton,
                              onChanged: (SiteName? value) {
                                setState(() {
                                  selectedButton = value!;
                                });
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    TextField(
                      controller: textEditingController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: '덱 코드를 붙여넣으세요.',
                      ),
                      enabled: true,
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('덱 이미지에서 가져오기'),
                      onPressed: () async {
                        // 로딩 다이얼로그 표시 - 파일 선택 전에 먼저 표시
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(width: 20),
                                  Text("QR 코드 이미지 불러오는 중...")
                                ],
                              ),
                            );
                          },
                        );
                        
                        try {
                          FilePickerResult? result = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png'],
                          );
                          
                          if (result != null) {
                            // 로딩 다이얼로그 업데이트
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 20),
                                      Text("QR 코드 처리 중...")
                                    ],
                                  ),
                                );
                              },
                            );
                            
                            Uint8List fileBytes = result.files.first.bytes!;
                            String? qrData = await decodeQrCodeFromImage(fileBytes);
                            
                            // 로딩 다이얼로그 닫기
                            Navigator.pop(context);
                            
                            if (qrData != null) {
                              DeckBuild deck = importDeckQr(qrData, context);
                              Navigator.pop(context); // Import 다이얼로그 닫기
                              importAction(deck);
                              
                              // 토스트 메시지 표시
                              ToastOverlay.show(
                                context,
                                'QR코드에서 덱을 가져왔습니다.',
                                type: ToastType.success
                              );
                            } else {
                              ToastOverlay.show(
                                context,
                                'QR코드를 인식할 수 없습니다.',
                                type: ToastType.error
                              );
                            }
                          } else {
                            // 파일 선택 취소 시 로딩 다이얼로그 닫기
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          // 오류 발생 시 로딩 다이얼로그 닫기
                          Navigator.pop(context);
                          ToastOverlay.show(
                            context,
                            '이미지 처리 중 오류가 발생했습니다.',
                            type: ToastType.error
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    try {
                      if (textEditingController.text.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('오류'),
                              content: const Text('덱 코드를 입력해주세요.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('확인'),
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      isSubmitted = true;
                      Map<String, int> map = {};
                      map = selectedButton.convertStringToMap(
                          textEditingController.text);
                      Navigator.pop(context);
                      DeckBuild deck = import(map, context);
                      importAction(deck);
                      
                      // 토스트 메시지 표시
                      ToastOverlay.show(
                        context,
                        '덱을 가져왔습니다.',
                        type: ToastType.success
                      );
                      
                    } catch (e) {
                      if (!isSubmitted) {
                        isSubmitted = true;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('오류'),
                              content: const Text('덱 코드를 확인해주세요.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('확인'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  },
                  child: const Text('가져오기'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showDeckClearDialog(
      BuildContext context, DeckBuild deck, Function() reload) {
    CardOverlayService().removeAllOverlays();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('덱 비우기'),
          content: const Text('덱을 비우시겠습니까?'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            ElevatedButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(
                '예',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                deck.clear();
                reload();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _colorSelectionWidget(DeckBuild deck) {
    CardOverlayService().removeAllOverlays();
    List<String> cardColorList = deck.getOrderedCardColorList();
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          children: [
            const Text('덱 컬러 선택', style: TextStyle(fontSize: 25)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                cardColorList.length,
                (index) {
                  String color = cardColorList[index];
                  Color buttonColor = ColorService.getColorFromString(color);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (deck.colors.contains(color)) {
                          deck.colors.remove(color);
                        } else {
                          deck.colors.add(color);
                        }
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 40.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: deck.colors.contains(color)
                                ? buttonColor
                                : buttonColor.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          color,
                          style: TextStyle(
                              fontSize: 12.0,
                              color: deck.colors.contains(color)
                                  ? Colors.black
                                  : Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void showSaveDialog(BuildContext context, Map<int, FormatDto> formats,
      DeckBuild deck, Function() reload) {
    CardOverlayService().removeAllOverlays();
    LimitProvider limitProvider = Provider.of(context, listen: false);

    var korFormats = formats.entries
        .where((entry) => entry.value.isOnlyEn == false)
        .toList();
    if (!formats.keys.contains(deck.formatId)) {
      if (!korFormats.isEmpty) {
        deck.formatId = korFormats.first.key;
      } else {
        var enFormats = formats.entries
            .where((entry) => entry.value.isOnlyEn == true)
            .toList()
            .reversed;
        if (enFormats.length == 0) {
          deck.formatId = korFormats.first.key;
        } else {
          deck.formatId = enFormats.first.key;
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              content: SizedBox(
                width: MediaQuery.sizeOf(context).width / 3,
                height: MediaQuery.sizeOf(context).height / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          deck.isPublic ? '전체 공개' : '비공개',
                          style: const TextStyle(fontSize: 25),
                        ),
                        Switch(
                          inactiveThumbColor: Colors.red,
                          value: deck.isPublic,
                          onChanged: (bool v) {
                            setState(() {
                              deck.isPublic = v;
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    _colorSelectionWidget(deck),
                    const Divider(),
                    const Text('포맷', style: TextStyle(fontSize: 25)),
                    DropdownButton<int>(
                      isExpanded: true,
                      value: deck.formatId,
                      hint: Text(formats[deck.formatId]?.name ?? "포맷 "),
                      items: [
                        const DropdownMenuItem<int>(
                          enabled: false,
                          child: Text(
                            '일반 포맷',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ...formats.entries
                            .where((entry) => entry.value.isOnlyEn == false)
                            .map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(
                              '${entry.value.name} ['
                              '${DateFormat('yyyy-MM-dd').format(entry.value.startDate)} ~ '
                              '${DateFormat('yyyy-MM-dd').format(entry.value.endDate)}]',
                              // overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                        const DropdownMenuItem<int>(
                          enabled: false,
                          child: Text('미발매 포맷 [예상 발매 일정]',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ...formats.entries
                            .where((entry) => entry.value.isOnlyEn == true)
                            .toList()
                            .reversed
                            .map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text('${entry.value.name} ['
                                '${DateFormat('yyyy-MM-dd').format(entry.value.startDate)} ~ '
                                '${DateFormat('yyyy-MM-dd').format(entry.value.endDate)}]'),
                          );
                        }),
                      ],
                      onChanged: (int? newValue) {
                        setState(() {
                          deck.formatId = newValue!;
                        });
                      },
                    ),
                    const Divider(),
                    const Text('선택된 금지/제한', style: TextStyle(fontSize: 25)),
                    Text(
                        '${DateFormat('yyyy-MM-dd').format(limitProvider.selectedLimit!.restrictionBeginDate)}',
                        style: const TextStyle(fontSize: 20))
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    List<String> cardColorList = deck.getOrderedCardColorList();
                    Set<String> set = cardColorList.toSet();
                    deck.colorArrange(set);
                    if (deck.colors.isEmpty) {
                      _showShortDialog(context, "색을 하나 이상 골라야 합니다.");
                      return;
                    }
                    if (deck.formatId == null) {
                      _showShortDialog(context, "포맷을 골라야 합니다.");
                      return;
                    }
                    DeckBuild? newDeck = await save(deck, context);
                    if (newDeck != null) {
                      deck.deckId = newDeck.deckId;
                      deck.isSave = true;
                      reload();
                      Navigator.of(context).pop();
                      ToastOverlay.show(
                        context,
                        '덱이 저장되었습니다.',
                        type: ToastType.success
                      );
                    } else {
                      ToastOverlay.show(
                        context,
                        '저장에 실패했습니다.',
                        type: ToastType.error
                      );
                    }
                  },
                  child: const Text('저장'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showDeckResetDialog(BuildContext context, Function() init) {
    CardOverlayService().removeAllOverlays();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('새로 만들기'),
          content: const Text('새로운 덱을 작성하시겠습니까? \n저장되지 않은 변경사항은 사라집니다.'),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            ElevatedButton(
              child: const Text('아니오'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text(
                '예',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                init();
              },
            ),
          ],
        );
      },
    );
  }

  DeckBuild importDeckQr(String deckMapString, BuildContext context) {
    try {
      // URL 형식으로 되어 있는지 확인하고 파싱
      if (deckMapString.contains('?deck=')) {
        Uri uri = Uri.parse(deckMapString);
        String? deckParam = uri.queryParameters['deck'];
        if (deckParam != null) {
          deckMapString = Uri.decodeComponent(deckParam);
        }
      }
      
      // Parse the deck string into a map of cardId to count
      Map<int, int> cardIdAndCntMap = parseDeckString(deckMapString);
      // Create a new deck
      DeckBuild deck = DeckBuild(context);
      deck.isStrict = false;
      // Add each card to the deck
      cardIdAndCntMap.forEach((cardId, count) {
        DigimonCard? card = CardDataService().getCardById(cardId);
        if (card != null) {
          for (int i = 0; i < count; i++) {
            deck.addSingleCard(card);
          }
        }
      });
      deck.isStrict = true;
      return deck;
    } catch (e) {
      return DeckBuild(context);
    }
  }

  // Parse deck string with format "cardId1=count1,cardId2=count2,..."
  // Or the optimized formats "v2:base64encodeddata" or "v3:base64encodeddata"
  Map<int, int> parseDeckString(String deckString) {
    Map<int, int> result = {};

    if (deckString.isEmpty) {
      return result;
    }
    
    // v3 고급 압축 포맷 (50장 이상 대용량 덱용)
    if (deckString.startsWith('v3:')) {
      try {
        // Base64 데이터 추출
        String base64Data = deckString.substring(3);
        // Base64 디코딩
        Uint8List bytes = base64Url.decode(base64Data);
        
        if (bytes.isEmpty) {
          return result;
        }
        
        // 첫 번째 카드 ID (2바이트)
        int currentId = (bytes[0] << 8) | bytes[1];
        int count = bytes[2];
        result[currentId] = count;
        
        int i = 3;
        // 나머지 카드 데이터 파싱
        while (i < bytes.length) {
          // 차이값 파싱 - 가변 길이 인코딩
          int diff;
          if ((bytes[i] & 0x80) == 0) {
            // 1바이트 차이값
            diff = bytes[i];
            i++;
          } else if ((bytes[i] & 0xC0) == 0x80) {
            // 2바이트 차이값
            diff = ((bytes[i] & 0x3F) << 8) | bytes[i + 1];
            i += 2;
          } else {
            // 3바이트 차이값
            diff = (bytes[i + 1] << 8) | bytes[i + 2];
            i += 3;
          }
          
          // 바이트 범위 체크
          if (i >= bytes.length) break;
          
          // 수량 파싱
          count = bytes[i++];
          
          // 새 카드 ID 계산 및 저장
          currentId += diff;
          result[currentId] = count;
        }
        
        return result;
      } catch (e) {
        print('Error parsing v3 format: $e');
      }
    }
    
    // v2 압축 포맷 (기존 코드)
    if (deckString.startsWith('v2:')) {
      try {
        // Extract the base64 data (remove 'v2:' prefix)
        String base64Data = deckString.substring(3);
        // Decode base64 to binary
        Uint8List bytes = base64Url.decode(base64Data);
        ByteData byteData = ByteData.view(bytes.buffer);
        
        // Each entry consists of two integers (card ID and count)
        int entryCount = bytes.length ~/ 4; // 2 uint16 values per entry
        
        if (entryCount > 0) {
          // First value is stored directly
          int currentId = byteData.getUint16(0, Endian.big);
          int count = byteData.getUint16(2, Endian.big);
          result[currentId] = count;
          
          // Following entries are stored as differences
          for (int i = 1; i < entryCount; i++) {
            int idDiff = byteData.getUint16(i * 4, Endian.big);
            int nextCount = byteData.getUint16(i * 4 + 2, Endian.big);
            
            currentId += idDiff;
            result[currentId] = nextCount;
          }
        }
        
        return result;
      } catch (e) {
        // If there's an error parsing the new format, fall back to old format
        print('Error parsing v2 QR format: $e');
      }
    }
    
    // 원래 형식 파싱 (기본 폴백)
    try {
      List<String> pairs = deckString.split(",");
      for (String pair in pairs) {
        if (pair.contains("=")) {
          List<String> parts = pair.split("=");
          if (parts.length == 2) {
            int key = int.parse(parts[0]);
            int value = int.parse(parts[1]);
            result[key] = value;
          }
        }
      }
    } catch (e) {
      print('Error parsing original format: $e');
    }
    
    return result;
  }

  DeckBuild importDeckThisSite(Map<String, int> cardIdAndCntMap, BuildContext context) {
    try {
      if (cardIdAndCntMap.isEmpty) return DeckBuild(context);

      // Create a DeckView object with the parsed data
      DeckBuild deck = DeckBuild(context);

      cardIdAndCntMap.forEach((cardId, count) {
        DigimonCard? card = CardDataService().getCardById(int.parse(cardId));
        if (card != null) {
          for (int i = 0; i < count; i++) {
            deck.addSingleCard(card);
          }
        }
      });
      return deck;
    } catch (e) {
      return DeckBuild(context);
    }
  }

  void _showShortDialog(BuildContext context, String text) {
    CardOverlayService().removeAllOverlays();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(text),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
