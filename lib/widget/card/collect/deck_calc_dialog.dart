import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../model/card_quantity_calculator.dart';
import '../../../model/card.dart';
import '../../../model/deck-view.dart';
import '../../../model/format.dart';
import '../../../provider/collect_provider.dart';
import '../../deck/color_palette.dart';

class DeckCalcDialog extends StatefulWidget {
  final List<FormatDto> formats;
  final Map<int, List<DeckView>> deckMap;

  const DeckCalcDialog(
      {super.key, required this.formats, required this.deckMap});

  @override
  State<DeckCalcDialog> createState() => _DeckCalcDialogState();
}

class _DeckCalcDialogState extends State<DeckCalcDialog> {
  late CardQuantityCalculator _calculator;
  int _selectedFormatId = 0;
  Map<int, Set<int>> _checkedDeckIds = {};
  bool _showExceededCards = true;
  bool _showEnCards = true;
  bool _useCardNoAsKey = true;
  List sortedFormats = [];
  List pastFormats = [];
  List currentFormats = [];
  bool _isAllDecksSelected = false;

  @override
  void initState() {
    super.initState();
    _calculator = CardQuantityCalculator();
    final now = DateTime.now();
    sortedFormats = widget.formats.toList()
      ..sort((a, b) => a.startDate!.compareTo(b.startDate!));
    pastFormats =
        sortedFormats.where((format) => format.endDate!.isBefore(now)).toList();
    currentFormats = sortedFormats
        .where((format) => !format.endDate!.isBefore(now))
        .toList();

    _selectedFormatId = currentFormats.first.formatId;
    _initializeCheckedDeckIds();
  }

  void _initializeCheckedDeckIds() {
    for (int formatId in widget.deckMap.keys) {
      _checkedDeckIds[formatId] = Set<int>();
    }
  }

  void _onFormatSelected(int formatId) {
    setState(() {
      _selectedFormatId = formatId;
      _updateSelectAllCheckbox();
    });
  }
  void _updateSelectAllCheckbox() {
    setState(() {
      if(widget.deckMap[_selectedFormatId]!=null) {
        _isAllDecksSelected = widget.deckMap[_selectedFormatId]!.every((deck) => _checkedDeckIds[_selectedFormatId]!.contains(deck.deckId));
      }else{
        _isAllDecksSelected=false;
      }

    });
  }
  void _onDeckChecked(DeckView deck, bool isChecked) {
    int formatId = deck.formatId!;
    int deckId = deck.deckId!;

    setState(() {
      if (isChecked) {
        _calculator.addDeck(deck);
        _checkedDeckIds[formatId]!.add(deckId);
      } else {
        _calculator.removeDeck(deck);
        _checkedDeckIds[formatId]!.remove(deckId);
      }

    });
    _updateSelectAllCheckbox();
  }
  void _selectAllDecks(bool? isChecked) {
    if(isChecked==null) {
      return;
    }
    if(widget.deckMap[_selectedFormatId]==null) {
      return;
    }
    setState(() {
      if (isChecked) {
        _isAllDecksSelected=true;
        widget.deckMap[_selectedFormatId]!.forEach((deck) {
          _checkedDeckIds[_selectedFormatId]!.add(deck.deckId!);
          _calculator.addDeck(deck);
        });
      } else {
        _isAllDecksSelected=false;
        widget.deckMap[_selectedFormatId]!.forEach((deck) {
          _checkedDeckIds[_selectedFormatId]!.remove(deck.deckId!);
          _calculator.removeDeck(deck);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    CollectProvider collectProvider = Provider.of(context, listen: false);

    List<DigimonCard> sortedCards = !_useCardNoAsKey
        ? _calculator.maxQuantitiesByCardNo.entries
            .map((entry) => _calculator.getCardByCardNo(entry.key))
            .whereType<DigimonCard>()
            .toList()
        : _calculator.maxQuantitiesById.keys
            .map((id) => _calculator.getCardById(id))
            .whereType<DigimonCard>()
            .toList();
    sortedCards
        .sort((a, b) => (a.sortString ?? '').compareTo(b.sortString ?? ''));

    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: Colors.grey)),
                        ),
                        child: Column(
                          children: [
                            Text('포맷', style: TextStyle(fontSize: 30)),
                            Expanded(
                              flex: 6,
                              child: ListView.builder(
                                itemCount: currentFormats.length,
                                itemBuilder: (context, index) {
                                  final format = currentFormats[index];
                                  return ListTile(
                                    title: Text(format.name ?? ''),
                                    onTap: () =>
                                        _onFormatSelected(format.formatId!),
                                    selected:
                                        _selectedFormatId == format.formatId,
                                    selectedTileColor: Colors.grey[200],
                                  );
                                },
                              ),
                            ),
                            if (pastFormats.isNotEmpty) ...[
                              Text('지난 포맷', style: TextStyle(fontSize: 20)),
                              Expanded(
                                flex: 2,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: pastFormats.length,
                                  itemBuilder: (context, index) {
                                    final format = pastFormats[index];
                                    return ListTile(
                                      title: Text(format.name ?? ''),
                                      onTap: () =>
                                          _onFormatSelected(format.formatId!),
                                      selected:
                                          _selectedFormatId == format.formatId,
                                      selectedTileColor: Colors.grey[200],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: Colors.grey)),
                        ),
                        child: Column(
                          children: [
                            Text('덱 이름', style: TextStyle(fontSize: 30)),
                            CheckboxListTile(
                              title: Text('전체 선택'),
                              value: _isAllDecksSelected,
                              onChanged: _selectAllDecks,
                              // controlAffinity: ListTileControlAffinity.leading,
                            ),
                            Divider(),
                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    widget.deckMap[_selectedFormatId]?.length ??
                                        0,
                                itemBuilder: (context, index) {
                                  final deck =
                                      widget.deckMap[_selectedFormatId]![index];
                                  final isChecked =
                                      _checkedDeckIds[_selectedFormatId]
                                              ?.contains(deck.deckId) ??
                                          false;
                                  return CheckboxListTile(
                                    title: Row(
                                      children: [
                                        ColorWheel(
                                          colors: deck.colors!,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(deck.deckName ?? ''),
                                      ],
                                    ),
                                    value: isChecked,
                                    onChanged: (value) =>
                                        _onDeckChecked(deck, value!),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(

                        children: [
                          Text('필요한 카드 목록', style: TextStyle(fontSize: 30)),
                          Container(
                            padding: EdgeInsets.all(8.0),
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: 8.0,
                              runSpacing: 4.0,
                              children: [
                                IntrinsicWidth(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: _showExceededCards,
                                        onChanged: (value) {
                                          setState(() {
                                            _showExceededCards = value!;
                                          });
                                        },
                                      ),
                                      Text('이미 가지고 있는 카드 표시'),
                                    ],
                                  ),
                                ),
                                IntrinsicWidth(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: _showEnCards,
                                        onChanged: (value) {
                                          setState(() {
                                            _showEnCards = value!;
                                          });
                                        },
                                      ),
                                      Text('미발매 카드 표시'),
                                    ],
                                  ),
                                ),
                                IntrinsicWidth(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: _useCardNoAsKey,
                                        onChanged: (value) {
                                          setState(() {
                                            _useCardNoAsKey = value!;
                                          });
                                        },
                                      ),
                                      Text('카드번호로 그룹화 (패레 구분 안함)'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: sortedCards.length,
                              itemBuilder: (context, index) {
                                final card = sortedCards[index];
                                final quantity = _useCardNoAsKey
                                    ? _calculator.maxQuantitiesByCardNo[card.cardNo] ?? 0
                                    : _calculator.maxQuantitiesById[card.cardId] ?? 0;
                                
                                final nowQuantity = _useCardNoAsKey
                                    ? collectProvider.getCardQuantityByCardNo(card.cardNo!)
                                    : collectProvider.getCardQuantityById(card.cardId!);
                                
                                bool showCard = true;
                                
                                if (!_showExceededCards && nowQuantity >= quantity) {
                                  showCard = false;
                                }
                                
                                if (!_showEnCards && card.isEn == true) {
                                  showCard = false;
                                }
                                
                                if (showCard) {
                                  return Card(
                                    child: ListTile(
                                      leading: Image.network(
                                          card.getDisplaySmallImgUrl() ?? ''),
                                      title: Text(
                                          '${card.cardNo} ${card.getDisplayName()} ${card.rarity}' ??
                                              ''),
                                      subtitle: Text(
                                        '소지: $nowQuantity / 필요: $quantity',
                                        style: TextStyle(
                                            color: nowQuantity >= quantity
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
