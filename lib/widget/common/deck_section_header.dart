import 'package:flutter/material.dart';
import '../../service/size_service.dart';

class DeckSectionHeader extends StatelessWidget {
  final String title;
  final Color? color;
  final bool isPortrait;
  final bool isMobile;
  final bool isEmpty;

  const DeckSectionHeader({
    Key? key,
    required this.title,
    this.color,
    this.isPortrait = false,
    this.isMobile = false,
    this.isEmpty = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 비어있으면 헤더를 표시하지 않음
    if (isEmpty) {
      return const SizedBox.shrink();
    }

    final defaultColor = title == '메인' 
      ? const Color(0xFF2563EB) 
      : const Color(0xFF7C3AED);
    
    final sectionColor = color ?? defaultColor;

    return Container(
      height: isMobile ? 32 : 40, // 훨씬 더 컴팩트하게
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 4 : 8, 
        vertical: isMobile ? 6 : 8,
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16, 
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                sectionColor.withOpacity(0.08),
                sectionColor.withOpacity(0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
            border: Border.all(
              color: sectionColor.withOpacity(0.15),
              width: 0.5,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isMobile 
                ? SizeService.bodyFontSize(context) * 0.85
                : SizeService.bodyFontSize(context) * 0.95,
              fontWeight: FontWeight.w600,
              color: sectionColor.withOpacity(0.9),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}