import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../service/size_service.dart';

class EnhancedPagination extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;
  final bool isLoading;

  const EnhancedPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.isLoading = false,
  });

  @override
  State<EnhancedPagination> createState() => _EnhancedPaginationState();
}

class _EnhancedPaginationState extends State<EnhancedPagination> {
  late TextEditingController _pageController;
  bool _showPageInput = false;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage() {
    final pageText = _pageController.text.trim();
    if (pageText.isNotEmpty) {
      final page = int.tryParse(pageText);
      if (page != null && page >= 1 && page <= widget.totalPages) {
        widget.onPageChanged(page);
        setState(() {
          _showPageInput = false;
        });
      }
    }
    _pageController.clear();
  }

  List<int> _getVisiblePages() {
    if (widget.totalPages <= 7) {
      return List.generate(widget.totalPages, (index) => index + 1);
    }

    final current = widget.currentPage;
    final total = widget.totalPages;
    
    if (current <= 4) {
      return [1, 2, 3, 4, 5, -1, total]; // -1은 "..." 표시용
    } else if (current >= total - 3) {
      return [1, -1, total - 4, total - 3, total - 2, total - 1, total];
    } else {
      return [1, -1, current - 1, current, current + 1, -1, total];
    }
  }

  Widget _buildPageButton(int page) {
    final isCurrentPage = page == widget.currentPage;
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: widget.isLoading ? null : () => widget.onPageChanged(page),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isCurrentPage 
                  ? theme.primaryColor 
                  : Colors.transparent,
              border: Border.all(
                color: isCurrentPage 
                    ? theme.primaryColor 
                    : theme.dividerColor,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                page.toString(),
                style: TextStyle(
                  fontSize: SizeService.smallFontSize(context),
                  fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.normal,
                  color: isCurrentPage 
                      ? Colors.white 
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Center(
        child: Text(
          '...',
          style: TextStyle(
            fontSize: SizeService.smallFontSize(context),
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.totalPages <= 1) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12,
        horizontal: SizeService.paddingSize(context),
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 메인 페이징 컨트롤
          if (!isPortrait || !_showPageInput) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 첫 페이지로 가기
                _buildNavigationButton(
                  icon: Icons.first_page,
                  onPressed: widget.currentPage > 1 && !widget.isLoading
                      ? () => widget.onPageChanged(1)
                      : null,
                  tooltip: '첫 페이지',
                ),
                
                const SizedBox(width: 4),
                
                // 이전 페이지
                _buildNavigationButton(
                  icon: Icons.chevron_left,
                  onPressed: widget.currentPage > 1 && !widget.isLoading
                      ? () => widget.onPageChanged(widget.currentPage - 1)
                      : null,
                  tooltip: '이전 페이지',
                ),
                
                const SizedBox(width: 8),
                
                // 페이지 번호들
                if (isPortrait) ...[
                  // 모바일에서는 간단한 표시
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.primaryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${widget.currentPage} / ${widget.totalPages}',
                      style: TextStyle(
                        fontSize: SizeService.bodyFontSize(context),
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ] else ...[
                  // 데스크톱에서는 페이지 번호 표시
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _getVisiblePages().map((page) {
                      if (page == -1) {
                        return _buildEllipsis();
                      }
                      return _buildPageButton(page);
                    }).toList(),
                  ),
                ],
                
                const SizedBox(width: 8),
                
                // 다음 페이지
                _buildNavigationButton(
                  icon: Icons.chevron_right,
                  onPressed: widget.currentPage < widget.totalPages && !widget.isLoading
                      ? () => widget.onPageChanged(widget.currentPage + 1)
                      : null,
                  tooltip: '다음 페이지',
                ),
                
                const SizedBox(width: 4),
                
                // 마지막 페이지로 가기
                _buildNavigationButton(
                  icon: Icons.last_page,
                  onPressed: widget.currentPage < widget.totalPages && !widget.isLoading
                      ? () => widget.onPageChanged(widget.totalPages)
                      : null,
                  tooltip: '마지막 페이지',
                ),
                
                const SizedBox(width: 12),
                
                // 페이지 입력 버튼
                _buildNavigationButton(
                  icon: Icons.more_horiz,
                  onPressed: !widget.isLoading ? () {
                    setState(() {
                      _showPageInput = !_showPageInput;
                    });
                  } : null,
                  tooltip: '페이지 직접 입력',
                ),
              ],
            ),
          ],
          
          // 페이지 입력 필드 (모바일에서만 또는 입력 모드일 때)
          if (_showPageInput) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  child: TextField(
                    controller: _pageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(fontSize: SizeService.smallFontSize(context)),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      hintText: '페이지',
                      hintStyle: TextStyle(
                        fontSize: SizeService.smallFontSize(context),
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                    onSubmitted: (_) => _goToPage(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: widget.isLoading ? null : _goToPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    '이동',
                    style: TextStyle(fontSize: SizeService.smallFontSize(context)),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showPageInput = false;
                    });
                    _pageController.clear();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    '취소',
                    style: TextStyle(fontSize: SizeService.smallFontSize(context)),
                  ),
                ),
              ],
            ),
          ],
          
          // 로딩 표시
          if (widget.isLoading) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.primaryColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    final theme = Theme.of(context);
    
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: onPressed != null 
                    ? theme.dividerColor 
                    : theme.dividerColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: SizeService.mediumIconSize(context),
              color: onPressed != null 
                  ? theme.iconTheme.color 
                  : theme.iconTheme.color?.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}