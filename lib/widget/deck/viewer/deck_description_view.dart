import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:digimon_meta_site_flutter/model/deck-build.dart';
import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:digimon_meta_site_flutter/model/search_parameter.dart';
import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:digimon_meta_site_flutter/service/card_data_service.dart';
import 'package:digimon_meta_site_flutter/service/card_service.dart';
import 'package:digimon_meta_site_flutter/service/card_overlay_service.dart';

// 가상의 RenderBox 클래스 (마우스 호버 위치 기반 오버레이 표시용)
class _VirtualRenderBox extends RenderBox {
  final Offset position;
  final Size _size;
  
  _VirtualRenderBox({
    required this.position,
    required Size size,
  }) : _size = size;
  
  @override
  Rect get paintBounds => Rect.fromLTWH(0, 0, _size.width, _size.height);
  
  @override
  Size get size => _size;
  
  @override
  Offset localToGlobal(Offset localOffset, {RenderObject? ancestor}) {
    return position + localOffset;
  }
}

// 카드 참조 패턴 정의 클래스
class CardReference {
  // 참조 형식: [@cardNo CardName]
  static final RegExp referencePattern = RegExp(r'\[@([A-Za-z0-9]+-\d+(?:-\d+)?)\s+([^\]]+)\]');
  
  // 문자열에서 모든 참조 찾기
  static List<RegExpMatch> findAll(String text) {
    return referencePattern.allMatches(text).toList();
  }
}

class DeckDescriptionView extends StatelessWidget {
  final DeckBuild deck;
  final Function(SearchParameter)? searchWithParameter;

  const DeckDescriptionView({
    Key? key,
    required this.deck,
    this.searchWithParameter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (deck.description == null || deck.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(SizeService.roundRadius(context)),
      ),
      margin: EdgeInsets.only(
        bottom: SizeService.paddingSize(context),
        top: SizeService.paddingSize(context) * 2, // 디지타마와의 간격 추가
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(SizeService.paddingSize(context) / 2),
            child: Text(
              '설명',
              style: TextStyle(
                fontSize: SizeService.bodyFontSize(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(SizeService.paddingSize(context)),
            child: _buildDescriptionText(context, deck.description!),
          ),
        ],
      ),
    );
  }
  
  // 참조된 카드가 있는 설명 텍스트 생성
  Widget _buildDescriptionText(BuildContext context, String description) {
    final references = CardReference.findAll(description);
    
    // 참조가 없는 경우 일반 텍스트 반환
    if (references.isEmpty) {
      return Container(
        width: double.infinity,
        child: Text(
          description,
          style: TextStyle(
            fontSize: SizeService.bodyFontSize(context),
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
          ),
          textAlign: TextAlign.left,
        ),
      );
    }
    
    // 참조가 있는 경우 RichText로 처리
    final spans = <InlineSpan>[];
    int lastEnd = 0;
    
    for (final match in references) {
      // 참조 이전 텍스트 추가
      if (match.start > lastEnd) {
        spans.add(
          TextSpan(
            text: description.substring(lastEnd, match.start),
            style: TextStyle(
              fontSize: SizeService.bodyFontSize(context),
              fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
            ),
          ),
        );
      }
      
      // 참조된 카드 추가 - 카드 이름만 표시
      final cardNo = match.group(1);
      final cardName = match.group(2);
      
      // 카드 정보 가져오기
      final card = CardDataService().getCardByCardNo(cardNo!);
      
      // 카드 색상에 따른 텍스트 색상 설정
      Color cardColor = Colors.blue;
      if (card != null && card.color1 != null) {
        cardColor = _getColorForCardType(card.color1!);
      }
      
      spans.add(
        TextSpan(
          text: cardName, // CardName만 표시
          style: TextStyle(
            fontSize: SizeService.bodyFontSize(context),
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
            color: cardColor,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline, // 링크임을 표시하기 위한 밑줄 추가
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () => _showCardInfo(context, cardNo),
          // 마우스 호버 이벤트 추가
          onEnter: card != null ? (event) => _showCardHoverImage(context, card, event) : null,
          onExit: (event) => CardOverlayService().hideBigImage(),
        ),
      );
      
      lastEnd = match.end;
    }
    
    // 마지막 참조 이후 텍스트 추가
    if (lastEnd < description.length) {
      spans.add(
        TextSpan(
          text: description.substring(lastEnd),
          style: TextStyle(
            fontSize: SizeService.bodyFontSize(context),
            fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
          ),
        ),
      );
    }
    
    return Container(
      width: double.infinity,
      child: RichText(
        text: TextSpan(children: spans),
        textAlign: TextAlign.left,
      ),
    );
  }
  
  // 마우스 호버 시 카드 이미지 표시
  void _showCardHoverImage(BuildContext context, DigimonCard card, PointerEnterEvent event) {
    if (card.getDisplayImgUrl() == null) return;
    
    // 화면 크기 가져오기
    final screenSize = MediaQuery.sizeOf(context);
    
    // 마우스 포인터 위치 가져오기
    final mousePosition = event.position;
    
    // 실제 카드 비율과 크기 설정 (실제 덱에서 사용되는 카드 크기 모방)
    // 디지몬 카드 표준 비율: 63mm x 88mm
    const cardAspectRatio = 63.0 / 88.0;
    const cardWidth = 90.0; // 덱에서 카드의 일반적인 너비를 가정
    const cardHeight = cardWidth / cardAspectRatio;
    
    // 가상의 렌더박스 생성 - 마우스 위치를 카드의 중심으로 간주
    final renderBox = _VirtualRenderBox(
      // 마우스 위치를 카드의 중앙으로 가정하고 카드의 왼쪽 상단 좌표 계산
      position: Offset(
        mousePosition.dx - (cardWidth / 2), // 카드 중앙에서 왼쪽으로 카드 너비의 절반
        mousePosition.dy - (cardHeight / 2), // 카드 중앙에서 위로 카드 높이의 절반
      ),
      size: Size(cardWidth, cardHeight),
    );
    
    // 행 수와 인덱스 설정 - 덱의 카드와 같은 방식으로 동작하도록
    // 덱의 카드는 일반적으로 행의 왼쪽/오른쪽 위치에 따라 오버레이 방향이 결정됨
    final rowNumber = 4; // 일반적인 덱 행 개수 (카드가 화면에 표시되는 열 수)
    
    // 마우스가 화면 오른쪽에 있으면 카드가 오른쪽에 있다고 가정 (인덱스 = 행 개수 - 1)
    // 마우스가 화면 왼쪽에 있으면 카드가 왼쪽에 있다고 가정 (인덱스 = 0)
    final isRightHalf = mousePosition.dx > screenSize.width / 2;
    final index = isRightHalf ? rowNumber - 1 : 0;
    
    // CardOverlayService 이용해 이미지 표시 - 덱의 카드와 동일한 방식
    CardOverlayService().showBigImage(
      context,
      card.getDisplayImgUrl()!,
      renderBox,
      rowNumber,
      index,
    );
  }
  
  // 카드 타입에 따른 색상 반환
  Color _getColorForCardType(String color) {
    switch (color) {
      case 'RED':
        return Colors.red.shade700;
      case 'BLUE':
        return Colors.blue.shade700;
      case 'GREEN':
        return Colors.green.shade700;
      case 'YELLOW':
        return Colors.amber.shade700;
      case 'BLACK':
        return Colors.grey.shade800;
      case 'PURPLE':
        return Colors.purple.shade700;
      case 'WHITE':
        return Colors.blueGrey.shade400;
      default:
        return Colors.blue;
    }
  }
  
  // 카드 정보 표시 메서드
  void _showCardInfo(BuildContext context, String cardNo) {
    final card = CardDataService().getCardByCardNo(cardNo);
    if (card != null) {
      // CardService를 사용하여 카드 이미지 다이얼로그 표시
      CardService().showImageDialog(
        context, 
        card, 
        searchWithParameter: searchWithParameter,
      );
    }
  }
} 