import 'package:flutter/material.dart';

class TabTooltip extends StatefulWidget {
  final Widget child;
  final String message;

  const TabTooltip({
    super.key,
    required this.child,
    required this.message,
  });

  @override
  _TabTooltipState createState() => _TabTooltipState();
}

class _TabTooltipState extends State<TabTooltip> {
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_overlayEntry == null) {
          final RenderBox renderBox = context.findRenderObject() as RenderBox;
          final Offset offset = renderBox.localToGlobal(Offset.zero);
          final Size size = renderBox.size;

          _showTooltip(
            context: context,
            message: widget.message,
            offset: offset,
            size: size,
          );
        } else {
          _removeTooltip();
        }
      },
      child: widget.child,
    );
  }

  EdgeInsets _getDefaultPadding(BuildContext context) {
    return switch (Theme.of(context).platform) {
      TargetPlatform.macOS ||
      TargetPlatform.linux ||
      TargetPlatform.windows =>
      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      TargetPlatform.android ||
      TargetPlatform.fuchsia ||
      TargetPlatform.iOS =>
      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    };
  }

  double _getDefaultFontSize(BuildContext context) {
    return switch (Theme.of(context).platform) {
      TargetPlatform.macOS ||
      TargetPlatform.linux ||
      TargetPlatform.windows => 12.0,
      TargetPlatform.android ||
      TargetPlatform.fuchsia ||
      TargetPlatform.iOS => 14.0,
    };
  }

  void _showTooltip({
    required BuildContext context,
    required String message,
    required Offset offset,
    required Size size,
  }) {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _removeTooltip,
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  top: offset.dy + size.height,
                  left: offset.dx,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: _getDefaultPadding(context),
                      decoration: BoxDecoration(
                        color: Colors.grey[700]!.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _getDefaultFontSize(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}