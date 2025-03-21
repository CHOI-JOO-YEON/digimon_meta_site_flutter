import 'package:flutter/material.dart';
import 'dart:async';

class CardOverlayService {
  static final CardOverlayService _instance = CardOverlayService._internal();

  factory CardOverlayService() {
    return _instance;
  }

  CardOverlayService._internal();

  OverlayEntry? _imageOverlayEntry;
  OverlayEntry? _buttonOverlayEntry;
  bool isPanelOpen = false;
  
  // 현재 선택된 카드 정보 저장
  RenderBox? _selectedCardRenderBox;
  Function? _onMinusTap;
  Function? _onPlusTap;
  bool? _isTama;
  BuildContext? _currentContext;

  void updatePanelStatus(bool panelOpenStatus) {
    isPanelOpen = panelOpenStatus;
  }

  void showBigImage(BuildContext context, String imgUrl, RenderBox renderBox,
      int rowNumber, int index) {
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    double maxHeight = screenHeight * 0.5;

    final aspectRatio = renderBox.size.width / renderBox.size.height;

    double maxWidth = maxHeight * aspectRatio;

    if (maxWidth > screenWidth / 2) {
      maxWidth = screenWidth / 2;
      maxHeight = maxWidth / aspectRatio;
    }
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
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: 1.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Skeleton loading with shimmer effect - only shown when image is loading
                  Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        // Image is loaded, show only the image
                        return child;
                      }
                      // Image is still loading, show shimmer
                      return _buildShimmerEffect();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[100],
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red[400],
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '이미지 로딩 실패',
                                style: TextStyle(
                                  color: Colors.red[400],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_imageOverlayEntry!);
  }

  // Shimmer effect for skeleton loading
  Widget _buildShimmerEffect() {
    return Stack(
      alignment: Alignment.center,
      children: [
        _ShimmerLoading(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
        ),
        // Loading indicator
        SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue.shade300,
            ),
          ),
        ),
      ],
    );
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
    
    // 현재 선택된 카드 정보 저장
    _selectedCardRenderBox = renderBox;
    _onMinusTap = onMinusTap;
    _onPlusTap = onPlusTap;
    _isTama = isTama;
    _currentContext = context;
    
    _showCardOptionsOverlay();
  }

  // 오버레이 표시 로직을 별도 메서드로 분리
  void _showCardOptionsOverlay() {
    if (_selectedCardRenderBox == null || _currentContext == null) return;
    
    final offset = _selectedCardRenderBox!.localToGlobal(Offset.zero);
    final cardWidth = _selectedCardRenderBox!.size.width;
    final cardHeight = _selectedCardRenderBox!.size.height;

    _buttonOverlayEntry?.remove();
    _buttonOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy,
        width: cardWidth,
        height: cardHeight,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // 반투명 배경
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // 중앙에 수량 조절 컨트롤
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  width: cardWidth * 0.8,
                  height: cardHeight * 0.35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCountButton(
                        onTap: _onMinusTap!,
                        icon: Icons.remove,
                        color: Colors.red.shade700,
                        size: cardWidth * 0.2,
                      ),
                      _buildCountButton(
                        onTap: _onPlusTap!,
                        icon: Icons.add,
                        color: Colors.green.shade700,
                        size: cardWidth * 0.2,
                      ),
                    ],
                  ),
                ),
              ),
              // 닫기 버튼
              Positioned(
                right: 5,
                top: 5,
                child: GestureDetector(
                  onTap: removeAllOverlays,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 16, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(_currentContext!)?.insert(_buttonOverlayEntry!);
  }

  // 스크롤 발생 시 오버레이 위치 업데이트
  void updateCardOptionsPosition() {
    if (_buttonOverlayEntry != null && _selectedCardRenderBox != null && _currentContext != null) {
      _buttonOverlayEntry!.remove();
      _showCardOptionsOverlay();
    }
  }

  Widget _buildCountButton({
    required Function onTap,
    required IconData icon,
    required Color color,
    required double size,
  }) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }

  // 카드 옵션 버튼 숨기기
  void hideCardOptions() {
    _buttonOverlayEntry?.remove();
    _buttonOverlayEntry = null;
  }
}

class _ShimmerLoading extends StatefulWidget {
  final Widget child;

  const _ShimmerLoading({
    required this.child,
  });

  @override
  _ShimmerLoadingState createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFEBEBF4),
                Color(0xFFF4F4F4),
                Color(0xFFEBEBF4),
              ],
              stops: [
                0.1,
                0.3 + _animation.value.abs() * 0.5,
                0.4 + _animation.value.abs() * 0.5,
              ],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
