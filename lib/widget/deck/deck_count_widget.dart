import 'package:digimon_meta_site_flutter/service/size_service.dart';
import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../model/deck-build.dart';

class DeckCount extends StatelessWidget {
  final DeckBuild deck;

  const DeckCount({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    Color deckCountColor = deck.deckCount == 50 
        ? const Color(0xFF10B981) 
        : deck.deckCount > 50 
            ? const Color(0xFFEF4444) 
            : const Color(0xFFFF8E53);
    
    Color tamaCountColor = deck.tamaCount <= 5 
        ? const Color(0xFF10B981) 
        : const Color(0xFFEF4444);

    bool isDesktop = ResponsiveBreakpoints.of(context).largerOrEqualTo(DESKTOP);
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallHeight = screenHeight < 600;

    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: _buildCompactDeckCount(
              icon: Icons.style_outlined,
              title: '메인',
              current: deck.deckCount,
              max: 50,
              color: deckCountColor,
              context: context,
              isSmallHeight: isSmallHeight,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildCompactDeckCount(
              icon: Icons.pets_outlined,
              title: '디지타마',
              current: deck.tamaCount,
              max: 5,
              color: tamaCountColor,
              context: context,
              isSmallHeight: isSmallHeight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDeckCount({
    required IconData icon,
    required String title,
    required int current,
    required int max,
    required Color color,
    required BuildContext context,
    required bool isSmallHeight,
  }) {
    double progress = (current / max).clamp(0.0, 1.0);
    bool isComplete = current == max;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallHeight ? 6 : 8, 
        vertical: isSmallHeight ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: isComplete 
              ? color.withOpacity(0.3)
              : Colors.grey.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isSmallHeight ? 12 : 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: isSmallHeight 
                    ? SizeService.smallFontSize(context) * 0.8
                    : SizeService.smallFontSize(context) * 0.9,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              const Spacer(),
              Text(
                '$current',
                style: TextStyle(
                  fontSize: isSmallHeight
                    ? SizeService.smallFontSize(context) * 0.9
                    : SizeService.smallFontSize(context),
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                '/$max',
                style: TextStyle(
                  fontSize: isSmallHeight
                    ? SizeService.smallFontSize(context) * 0.75
                    : SizeService.smallFontSize(context) * 0.85,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: isSmallHeight ? 2 : 3,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isComplete) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.check_circle,
                  size: isSmallHeight ? 10 : 12,
                  color: color,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

