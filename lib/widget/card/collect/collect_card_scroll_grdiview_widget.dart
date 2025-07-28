import 'dart:math';

import 'package:digimon_meta_site_flutter/model/card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../provider/collect_provider.dart';
import '../card_widget.dart';

class CardScrollGridView extends StatefulWidget {
  final List<DigimonCard> cards;
  final int rowNumber;
  final Future<void> Function() loadMoreCards;
  final Function(DigimonCard, {Offset? position}) cardPressEvent;
  final int totalPages;
  final int currentPage;
  final bool isTextSimplify;

  const CardScrollGridView({
    super.key,
    required this.cards,
    required this.rowNumber,
    required this.loadMoreCards,
    required this.cardPressEvent,
    required this.totalPages,
    required this.currentPage,
    required this.isTextSimplify,
  });

  @override
  State<CardScrollGridView> createState() => _CardScrollGridViewState();
}

class _CardScrollGridViewState extends State<CardScrollGridView> {
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  final Map<String, GlobalKey> _cardKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // 스크롤이 끝에서 200px 정도 남았을 때 미리 로딩 시작
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200 &&
        _hasMorePages) {
      _loadMoreItems();
    }
  }

  bool get _hasMorePages {
    return !isLoading && widget.currentPage < widget.totalPages;
  }

  Future<void> _loadMoreItems() async {
    if (isLoading) return;
    
    setState(() => isLoading = true);
    
    try {
      await widget.loadMoreCards();
    } catch (e) {
      debugPrint('Error loading more cards: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Widget _buildLoadingIndicator(BoxConstraints constraints) {
    return Container(
      height: (constraints.maxWidth / widget.rowNumber) * 1.4,
      margin: EdgeInsets.all(constraints.maxWidth / 100),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '로딩 중...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'JalnanGothic',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final sizes = _calculateSizes(constraints, context);
        
        return GridView.builder(
          controller: _scrollController,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.rowNumber,
            crossAxisSpacing: constraints.maxWidth / 100,
            mainAxisSpacing: sizes.fontSize / 2,
            childAspectRatio: 0.5,
          ),
          itemCount: _getItemCount(),
          itemBuilder: (context, index) => _buildGridItem(index, constraints, sizes),
        );
      },
    );
  }

  int _getItemCount() => widget.cards.length + (isLoading ? widget.rowNumber : 0); // 한 줄 전체에 로딩 표시

  Widget _buildGridItem(int index, BoxConstraints constraints, _GridSizes sizes) {
    if (index >= widget.cards.length) {
      return _buildLoadingIndicator(constraints);
    }

    String cardId = widget.cards[index].cardId?.toString() ?? 'card_$index';
    _cardKeys.putIfAbsent(cardId, () => GlobalKey());
    final cardKey = _cardKeys[cardId]!;
    
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildCardWithQuantity(index, constraints, cardKey, sizes),
        ],
      ),
    );
  }

  Widget _buildCardWithQuantity(int index, BoxConstraints constraints, GlobalKey cardKey, _GridSizes sizes) {
    return Consumer<CollectProvider>(
      builder: (context, collectProvider, _) {
        final quantity = collectProvider.getCardQuantityById(widget.cards[index].cardId!);
        
        return Column(
          children: [
            CustomCard(
              key: cardKey,
              card: widget.cards[index],
              width: (constraints.maxWidth / widget.rowNumber) * 0.99,
              cardPressEvent: (card) => _handleCardPress(card, cardKey),
              zoomActive: false,
              isActive: quantity > 0,
            ),
            SizedBox(height: sizes.fontSize / 2),
            _buildQuantityControls(index, collectProvider, sizes),
          ],
        );
      },
    );
  }

  Widget _buildQuantityControls(int index, CollectProvider collectProvider, _GridSizes sizes) {
    final quantity = collectProvider.getCardQuantityById(widget.cards[index].cardId!);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.remove,
          onPressed: () => collectProvider.removeCard(widget.cards[index]),
          size: sizes.iconSize,
        ),
        Text(
          '$quantity',
          style: TextStyle(fontSize: sizes.fontSize),
        ),
        _buildControlButton(
          icon: Icons.add,
          onPressed: () => collectProvider.addCard(widget.cards[index]),
          size: sizes.iconSize,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(width: size, height: size),
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        iconSize: size,
        icon: Icon(icon),
      ),
    );
  }

  void _handleCardPress(DigimonCard card, GlobalKey key) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final position = renderBox?.localToGlobal(Offset.zero);
    widget.cardPressEvent(card, position: position);
  }
}

class _GridSizes {
  final double fontSize;
  final double iconSize;

  _GridSizes(this.fontSize, this.iconSize);
}

_GridSizes _calculateSizes(BoxConstraints constraints, BuildContext context) {
  final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
  
  double fontSize = constraints.maxWidth * 0.02;
  double iconSize = constraints.maxWidth * 0.04;
  
  if (isPortrait) {
    fontSize *= 1.5;
    iconSize *= 1.5;
  }
  
  return _GridSizes(fontSize, iconSize);
}
