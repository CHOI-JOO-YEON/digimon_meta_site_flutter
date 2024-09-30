import 'package:flutter/material.dart';

class CardOverlayService {
  static final CardOverlayService _instance = CardOverlayService._internal();

  factory CardOverlayService() {
    return _instance;
  }

  CardOverlayService._internal();

  OverlayEntry? _imageOverlayEntry;
  OverlayEntry? _buttonOverlayEntry;
  bool isPanelOpen = false;

  void updatePanelStatus(bool panelOpenStatus) {
    isPanelOpen = panelOpenStatus;
  }

  void showBigImage(BuildContext context, String imgUrl, RenderBox renderBox,
      int rowNumber, int index) {
    if (isPanelOpen) {
      return;
    }
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxHeight = screenHeight * 0.5; // 화면 높이의 절반을 최대 높이로 설정

    final aspectRatio = renderBox.size.width / renderBox.size.height;
    final maxWidth = maxHeight * aspectRatio; // 최대 높이에 맞는 너비 계산

    final bool onRightSide = (index % rowNumber) < rowNumber / 2;
    final double overlayLeft =
        onRightSide ? offset.dx + renderBox.size.width : offset.dx - maxWidth;

    final double overlayTop = (offset.dy + maxHeight > screenHeight)
        ? screenHeight - maxHeight
        : offset.dy;

    final double correctedLeft = overlayLeft < 0 ? 0 : overlayLeft;

    final double correctedWidth = correctedLeft + maxWidth > screenWidth
        ? screenWidth - correctedLeft
        : maxWidth;

    _imageOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: correctedLeft,
        top: overlayTop,
        width: correctedWidth,
        height: correctedWidth / aspectRatio,
        child: Image.network(imgUrl, fit: BoxFit.cover),
      ),
    );

    Overlay.of(context)?.insert(_imageOverlayEntry!);
  }

  void removeAllOverlays() {
    _removeCurrentImageOverlay();
    _removeCurrentButtonOverlay();
  }

  void hideBigImage() {
    _imageOverlayEntry?.remove();
    _imageOverlayEntry = null;
  }

  void _removeCurrentButtonOverlay() {
    _buttonOverlayEntry?.remove();
    _buttonOverlayEntry = null;
  }

  void _removeCurrentImageOverlay() {
    _imageOverlayEntry?.remove();
    _imageOverlayEntry = null;
  }

  void showCardOptions(BuildContext context, RenderBox renderBox,
      Function onMinusTap, Function onPlusTap, bool isTama) {
    removeAllOverlays();
    if (isPanelOpen) {
      return;
    }
    final offset = renderBox.localToGlobal(Offset.zero); // 카드 위치 가져오기
    final screenHeight = MediaQuery.of(context).size.height;
    final cardWidth = renderBox.size.width;
    final cardHeight = renderBox.size.height;

    // 버튼 크기 및 높이 조정
    final buttonHeight = cardHeight * 0.2;
    double? overlayTop;
    double? overlayBottom;

    if (!isTama) {
      overlayTop = offset.dy + cardHeight; // 카드 하단에 버튼 표시
    } else {
      overlayBottom = screenHeight - offset.dy; // 카드 상단에 버튼 표시
    }

    _buttonOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: overlayTop,
        bottom: overlayBottom,
        width: cardWidth,
        height: buttonHeight,
        child: Material(
          color: Colors.transparent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double buttonSize =
                  constraints.maxWidth * 0.3; // 버튼 크기를 화면 비율에 맞게 설정
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: ElevatedButton(
                      onPressed: () => onMinusTap(),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.red),
                      child: Icon(Icons.remove,
                          color: Colors.white, size: buttonSize * 0.5),
                    ),
                  ),
                  SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: ElevatedButton(
                      onPressed: () => onPlusTap(),
                      style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.green),
                      child: Icon(Icons.add,
                          color: Colors.white, size: buttonSize * 0.5),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_buttonOverlayEntry!);
  }

  // 카드 옵션 버튼 숨기기
  void hideCardOptions() {
    _buttonOverlayEntry?.remove();
    _buttonOverlayEntry = null;
  }
}
