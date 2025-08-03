import 'package:digimon_meta_site_flutter/model/deck-build.dart';
import 'package:digimon_meta_site_flutter/widget/common/toast_overlay.dart';
import 'package:flutter/material.dart';

class BottomSheetHeader extends StatelessWidget {
  final DeckBuild? deck;
  final VoidCallback? onMenuTap;
  final bool showDragHandle;
  final Function(DragUpdateDetails)? onDragUpdate;
  final bool enableMouseDrag;
  final bool showSaveWarning;

  const BottomSheetHeader({
    Key? key,
    this.deck,
    this.onMenuTap,
    this.showDragHandle = true,
    this.onDragUpdate,
    this.enableMouseDrag = false,
    this.showSaveWarning = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDragHandle) ...[
          // 드래그 핸들
          _buildDragHandle(),
          SizedBox(height: 12),
        ],
        
        // 덱 정보 요약 및 메뉴
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // 메인 덱 카운트
                  _buildCountBadge(
                    context,
                    icon: Icons.style,
                    count: deck?.deckCount ?? 0,
                    label: '메인',
                    colors: [Colors.blue[50]!, Colors.blue[100]!],
                    borderColor: Colors.blue[200]!,
                    iconColor: Colors.blue[700]!,
                    shadowColor: Colors.blue,
                  ),
                  SizedBox(width: 8),
                  // 디지타마 카운트
                  _buildCountBadge(
                    context,
                    icon: Icons.egg,
                    count: deck?.tamaCount ?? 0,
                    label: '디지타마',
                    colors: [Colors.orange[50]!, Colors.orange[100]!],
                    borderColor: Colors.orange[200]!,
                    iconColor: Colors.orange[700]!,
                    shadowColor: Colors.orange,
                  ),
                  // 저장 경고 아이콘
                  if (showSaveWarning && deck != null && !deck!.isSave) ...[
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => ToastOverlay.show(
                        context, 
                        '저장되지 않은 변경사항이 있습니다.', 
                        type: ToastType.warning
                      ),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          color: Colors.amber[600],
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              // 메뉴 버튼
              if (onMenuTap != null)
                _buildMenuButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDragHandle() {
    final handle = Container(
      width: 60,
      height: 5,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ],
        ),
        borderRadius: BorderRadius.circular(2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
    );

    if (enableMouseDrag && onDragUpdate != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.resizeUpDown,
        child: GestureDetector(
          onPanUpdate: onDragUpdate,
          child: handle,
        ),
      );
    }

    return handle;
  }

  Widget _buildCountBadge(
    BuildContext context, {
    required IconData icon,
    required int count,
    required String label,
    required List<Color> colors,
    required Color borderColor,
    required Color iconColor,
    required Color shadowColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          SizedBox(width: 4),
          Text(
            '$label $count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onMenuTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey[50]!,
                Colors.grey[100]!,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune,
                color: Theme.of(context).primaryColor,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                '메뉴',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}