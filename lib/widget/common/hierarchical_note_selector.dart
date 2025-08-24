import 'package:flutter/material.dart';
import '../../model/note.dart';

class HierarchicalNoteSelector extends StatefulWidget {
  final List<NoteDto> notes;
  final Set<int> selectedNoteIds;
  final Function(Set<int>) onSelectionChanged;
  final String title;
  final bool allowSelectAll;

  const HierarchicalNoteSelector({
    Key? key,
    required this.notes,
    required this.selectedNoteIds,
    required this.onSelectionChanged,
    this.title = '입수처 선택',
    this.allowSelectAll = true,
  }) : super(key: key);

  @override
  State<HierarchicalNoteSelector> createState() => _HierarchicalNoteSelectorState();
}

class _HierarchicalNoteSelectorState extends State<HierarchicalNoteSelector> {
  Map<String, Map<String, List<NoteDto>>> originGroupedNotes = {};
  Map<String, bool> expandedOrigins = {};
  Map<String, bool> expandedGroups = {};
  late Set<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.selectedNoteIds);
    _groupNotesByParent();
  }

  @override
  void didUpdateWidget(HierarchicalNoteSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedNoteIds != oldWidget.selectedNoteIds) {
      setState(() {
        _selectedIds = Set.from(widget.selectedNoteIds);
      });
    }
    if (widget.notes != oldWidget.notes) {
      _groupNotesByParent();
    }
  }

  void _groupNotesByParent() {
    originGroupedNotes.clear();
    
    final validNotes = widget.notes.where((note) => note.noteId != null).toList();
    
    for (var note in validNotes) {
      final originKey = _getOriginDisplayName(note.cardOrigin ?? 'ETC');
      final parentKey = note.parent ?? '기타';
      
      if (!originGroupedNotes.containsKey(originKey)) {
        originGroupedNotes[originKey] = {};
        expandedOrigins[originKey] = false; // 기본적으로 모든 origin을 접어둠
      }
      
      if (!originGroupedNotes[originKey]!.containsKey(parentKey)) {
        originGroupedNotes[originKey]![parentKey] = [];
        expandedGroups['${originKey}_$parentKey'] = false; // 기본적으로 모든 그룹을 접어둠
      }
      
      originGroupedNotes[originKey]![parentKey]!.add(note);
    }

    // 각 그룹 내에서 정렬 (priority 오름차순)
    originGroupedNotes.forEach((originKey, parentGroups) {
      parentGroups.forEach((parentKey, notes) {
        notes.sort((a, b) {
          // 먼저 priority로 정렬 (오름차순)
          if (a.priority != null && b.priority != null) {
            int priorityComparison = a.priority!.compareTo(b.priority!);
            if (priorityComparison != 0) return priorityComparison;
          } else if (a.priority == null && b.priority != null) {
            return 1;  // null은 뒤로
          } else if (a.priority != null && b.priority == null) {
            return -1; // null은 뒤로
          }
          
          // priority가 같으면 releaseDate로 정렬 (최신순)
          if (a.releaseDate != null && b.releaseDate != null) {
            int dateComparison = b.releaseDate!.compareTo(a.releaseDate!);
            if (dateComparison != 0) return dateComparison;
          } else if (a.releaseDate == null && b.releaseDate != null) {
            return 1;
          } else if (a.releaseDate != null && b.releaseDate == null) {
            return -1;
          }
          
          // 마지막으로 이름으로 정렬
          return a.name.compareTo(b.name);
        });
      });
    });
  }
  
  String _getOriginDisplayName(String cardOrigin) {
    switch (cardOrigin) {
      case 'BOOSTER_PACK':
        return '부스터 팩';
      case 'STARTER_DECK':
        return '스타트 덱';
      case 'EVENT':
        return '이벤트';
      case 'TOURNAMENT':
        return '토너먼트';
      case 'ENGLISH':
        return '미발매 카드';
      default:
        return '기타';
    }
  }
  
  List<String> _getSortedOriginKeys() {
    final originKeys = originGroupedNotes.keys.toList();
    
    // 원하는 순서대로 정렬
    final orderPriority = {
      '부스터 팩': 1,
      '스타트 덱': 2,
      '이벤트': 3,
      '토너먼트': 4,
      '미발매 카드': 5,
      '기타': 6,
    };
    
    originKeys.sort((a, b) {
      final priorityA = orderPriority[a] ?? 999;
      final priorityB = orderPriority[b] ?? 999;
      return priorityA.compareTo(priorityB);
    });
    
    return originKeys;
  }
  
  List<String> _getSortedParentKeys(String originKey, Map<String, List<NoteDto>> originGroups) {
    final parentKeys = originGroups.keys.toList();
    final isEnglish = originKey == '미발매 카드';
    
    parentKeys.sort((a, b) {
      final notesA = originGroups[a]!;
      final notesB = originGroups[b]!;
      
      // 각 parent 그룹의 최신/최오래된 발매일 찾기
      DateTime? getTargetDate(List<NoteDto> notes) {
        final validDates = notes
            .where((note) => note.releaseDate != null)
            .map((note) => note.releaseDate!)
            .toList();
            
        if (validDates.isEmpty) return null;
        
        // 미발매는 가장 오래된 날짜, 나머지는 가장 최신 날짜
        return isEnglish 
            ? validDates.reduce((a, b) => a.isBefore(b) ? a : b)  // 오름차순용 최소값
            : validDates.reduce((a, b) => a.isAfter(b) ? a : b);  // 내림차순용 최대값
      }
      
      final dateA = getTargetDate(notesA);
      final dateB = getTargetDate(notesB);
      
      // 발매일 비교
      if (dateA != null && dateB != null) {
        return isEnglish 
            ? dateA.compareTo(dateB)      // 미발매: 오름차순 (오래된 순)
            : dateB.compareTo(dateA);     // 나머지: 내림차순 (최신순)
      } else if (dateA == null && dateB != null) {
        return 1;  // null은 뒤로
      } else if (dateA != null && dateB == null) {
        return -1; // null은 뒤로
      }
      
      // 발매일이 같거나 모두 null이면 이름순
      return a.compareTo(b);
    });
    
    return parentKeys;
  }

  void _toggleSelection(int noteId) {
    setState(() {
      if (_selectedIds.contains(noteId)) {
        _selectedIds.remove(noteId);
      } else {
        _selectedIds.add(noteId);
      }
    });
    widget.onSelectionChanged(_selectedIds);
  }

  void _toggleGroupSelection(String originKey, String parentKey) {
    final groupNotes = originGroupedNotes[originKey]?[parentKey] ?? [];
    final groupNoteIds = groupNotes.map((note) => note.noteId!).toSet();
    final allSelected = groupNoteIds.every((id) => _selectedIds.contains(id));

    setState(() {
      if (allSelected) {
        // 모두 선택된 상태면 전체 해제
        _selectedIds.removeAll(groupNoteIds);
      } else {
        // 일부만 선택되었거나 아무것도 선택되지 않았으면 전체 선택
        _selectedIds.addAll(groupNoteIds);
      }
    });
    widget.onSelectionChanged(_selectedIds);
  }
  
  void _toggleOriginSelection(String originKey) {
    final originGroups = originGroupedNotes[originKey] ?? {};
    final allOriginNoteIds = <int>{};
    
    for (var parentGroup in originGroups.values) {
      allOriginNoteIds.addAll(parentGroup.map((note) => note.noteId!));
    }
    
    final allSelected = allOriginNoteIds.every((id) => _selectedIds.contains(id));

    setState(() {
      if (allSelected) {
        // 모두 선택된 상태면 전체 해제
        _selectedIds.removeAll(allOriginNoteIds);
      } else {
        // 일부만 선택되었거나 아무것도 선택되지 않았으면 전체 선택
        _selectedIds.addAll(allOriginNoteIds);
      }
    });
    widget.onSelectionChanged(_selectedIds);
  }

  void _selectAll() {
    final validNotes = widget.notes.where((note) => note.noteId != null);
    final allIds = validNotes.map((note) => note.noteId!).toSet();
    setState(() {
      _selectedIds = Set.from(allIds);
    });
    widget.onSelectionChanged(_selectedIds);
  }

  void _clearAll() {
    setState(() {
      _selectedIds = <int>{}; // 새로운 빈 Set으로 교체
    });
    // 빈 Set 전달
    widget.onSelectionChanged(_selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더 (title이 있을 때만 표시)
        if (widget.title.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              if (widget.allowSelectAll)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: _selectAll,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '전체선택',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: _clearAll,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        '전체해제',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        
        // 계층형 목록
        Container(
          height: 300,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: _getSortedOriginKeys().map((originKey) {
              final originGroups = originGroupedNotes[originKey]!;
              final isOriginExpanded = expandedOrigins[originKey] ?? false;
              
              // Origin 선택 상태 계산
              final allOriginNoteIds = <int>{};
              for (var parentGroup in originGroups.values) {
                allOriginNoteIds.addAll(parentGroup.map((note) => note.noteId!));
              }
              final selectedInOrigin = allOriginNoteIds.where((id) => _selectedIds.contains(id)).length;
              final isOriginFullySelected = selectedInOrigin == allOriginNoteIds.length && selectedInOrigin > 0;
              final isOriginPartiallySelected = selectedInOrigin > 0 && selectedInOrigin < allOriginNoteIds.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Origin 헤더 (1계층)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          expandedOrigins[originKey] = !isOriginExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor.withOpacity(0.1),
                              Theme.of(context).primaryColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            // Origin 체크박스
                            GestureDetector(
                              onTap: () => _toggleOriginSelection(originKey),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: isOriginFullySelected || isOriginPartiallySelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                  color: isOriginFullySelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                                ),
                                child: isOriginFullySelected
                                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                                    : isOriginPartiallySelected
                                        ? Icon(Icons.remove, size: 16, color: Theme.of(context).primaryColor)
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // 펼침/접힘 아이콘
                            Icon(
                              isOriginExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                              size: 22,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            
                            // Origin명
                            Expanded(
                              child: Text(
                                '$originKey (${allOriginNoteIds.length}개)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            
                            // 선택된 개수 표시
                            if (selectedInOrigin > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$selectedInOrigin',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Parent 그룹들 (2계층)
                  if (isOriginExpanded)
                    ..._getSortedParentKeys(originKey, originGroups).map((parentKey) {
                      final groupNotes = originGroups[parentKey]!;
                      final groupExpandKey = '${originKey}_$parentKey';
                      final isGroupExpanded = expandedGroups[groupExpandKey] ?? false;
                      
                      // 그룹 선택 상태 계산
                      final groupNoteIds = groupNotes.map((note) => note.noteId!).toSet();
                      final selectedInGroup = groupNoteIds.where((id) => _selectedIds.contains(id)).length;
                      final isGroupFullySelected = selectedInGroup == groupNoteIds.length && selectedInGroup > 0;
                      final isGroupPartiallySelected = selectedInGroup > 0 && selectedInGroup < groupNoteIds.length;

                      return Container(
                        margin: const EdgeInsets.only(left: 16, bottom: 4),
                        child: Column(
                          children: [
                            // Parent 그룹 헤더
                            InkWell(
                              onTap: () {
                                setState(() {
                                  expandedGroups[groupExpandKey] = !isGroupExpanded;
                                });
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    // 그룹 체크박스
                                    GestureDetector(
                                      onTap: () => _toggleGroupSelection(originKey, parentKey),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: isGroupFullySelected || isGroupPartiallySelected
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey[400]!,
                                            width: 2,
                                          ),
                                          color: isGroupFullySelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.transparent,
                                        ),
                                        child: isGroupFullySelected
                                            ? const Icon(Icons.check, size: 14, color: Colors.white)
                                            : isGroupPartiallySelected
                                                ? Icon(Icons.remove, size: 14, color: Theme.of(context).primaryColor)
                                                : null,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    
                                    // 펼침/접힘 아이콘
                                    Icon(
                                      isGroupExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    
                                    // Parent 그룹명
                                    Expanded(
                                      child: Text(
                                        '$parentKey (${groupNotes.length}개)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    
                                    // 선택된 개수 표시
                                    if (selectedInGroup > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '$selectedInGroup',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // 개별 아이템들 (3계층)
                            if (isGroupExpanded)
                              ...groupNotes.map((note) {
                                final isSelected = _selectedIds.contains(note.noteId);
                                return Container(
                                  margin: const EdgeInsets.only(left: 16, bottom: 2),
                                  child: InkWell(
                                    onTap: () => _toggleSelection(note.noteId!),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      child: Row(
                                        children: [
                                          // 체크박스
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(3),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Theme.of(context).primaryColor
                                                    : Colors.grey[400]!,
                                                width: 2,
                                              ),
                                              color: isSelected
                                                  ? Theme.of(context).primaryColor
                                                  : Colors.transparent,
                                            ),
                                            child: isSelected
                                                ? const Icon(Icons.check, size: 12, color: Colors.white)
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          
                                          // 입수처 이름
                                          Expanded(
                                            child: Text(
                                              note.name,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isSelected
                                                    ? Theme.of(context).primaryColor
                                                    : Colors.grey[700],
                                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          
                                          // 카드 개수 표시
                                          if (note.cardCount != null)
                                            Text(
                                              '${note.cardCount}장',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      );
                    }),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}