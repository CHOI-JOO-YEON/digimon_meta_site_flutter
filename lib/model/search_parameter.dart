class SearchParameter{
  String? searchString;
  int? noteId;
  Set<String>? colors ={};
  int? colorOperation;
  Set<int>? lvs;

  Set<String>? cardTypes;
  int typeOperation =1; //0 = and, 1 = or

  Map<int, String> types = {};

  int? minPlayCost=0; //
  int? maxPlayCost=20;
  int? minDp=1000;
  int? maxDp=17000;
  int? minDigivolutionCost=0;
  int? maxDigivolutionCost=8;
  Set<String>? rarities;

  int page = 1;
  int size = 84;

  int parallelOption = 0; 

  String orderOption = "sortString";
  bool isOrderDesc = false;
  bool isEnglishCardInclude = true;

  SearchParameter();

  factory SearchParameter.fromJson(Map<String, dynamic> json) {
    return SearchParameter()
      ..searchString = json['searchString'] as String?
      ..noteId = json['noteId'] as int?
      ..colors = json['colors'] != null ? Set<String>.from(json['colors']) : null
      ..colorOperation = json['colorOperation'] as int?
      ..lvs = json['lvs'] != null ? Set<int>.from(json['lvs']) : null
      ..cardTypes = json['cardTypes'] != null ? Set<String>.from(json['cardTypes']) : null
      ..typeOperation = json['typeOperation'] as int? ?? 1
      ..types = (json['typeIds'] as List<dynamic>?)?.asMap().map((key, value) => MapEntry(value as int, '')) ?? {}
      ..minPlayCost = json['minPlayCost'] as int?
      ..maxPlayCost = json['maxPlayCost'] as int?
      ..minDp = json['minDp'] as int?
      ..maxDp = json['maxDp'] as int?
      ..minDigivolutionCost = json['minDigivolutionCost'] as int?
      ..maxDigivolutionCost = json['MaxDigivolutionCost'] as int?
      ..rarities = json['rarities'] != null ? Set<String>.from(json['rarities']) : null
      ..page = json['page'] as int? ?? 1
      ..size = json['size'] as int? ?? 84
      ..parallelOption = json['parallelOption'] as int? ?? 0
      ..orderOption = json['orderOption'] as String? ?? 'sortString'
      ..isOrderDesc = json['isOrderDesc'] as bool? ?? false
      ..isEnglishCardInclude = json['isEnglishCardInclude'] as bool? ?? true;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (searchString != null) data['searchString'] = searchString;
    if (noteId != null) data['noteId'] = noteId;
    if (colors != null) data['colors'] = colors!.toList();
    if (colorOperation != null) data['colorOperation'] = colorOperation;
    if (lvs != null) data['lvs'] = lvs!.toList();
    if (cardTypes != null) data['cardTypes'] = cardTypes!.toList();
    if (minPlayCost != null) data['minPlayCost'] = minPlayCost;
    if (maxPlayCost != null) data['maxPlayCost'] = maxPlayCost;
    if (minDp != null) data['minDp'] = minDp;
    if (maxDp != null) data['maxDp'] = maxDp;
    if (minDigivolutionCost != null) data['minDigivolutionCost'] = minDigivolutionCost;
    if (maxDigivolutionCost != null) data['MaxDigivolutionCost'] = maxDigivolutionCost;
    if (rarities != null) data['rarities'] = rarities!.toList();
    data['page'] = page;
    data['size'] = size;
    data['parallelOption'] = parallelOption;
    data['orderOption'] = orderOption;
    data['isOrderDesc'] = isOrderDesc;
    data['isEnglishCardInclude'] = isEnglishCardInclude;
    data['typeIds'] = types.keys.toList();
    data['typeOperation'] = typeOperation;

    return data;
  }

  @override
  String toString() {
    return 'SearchParameter{ searchString: $searchString, noteId: $noteId, colors: ${colors?.join(", ")}, colorOperation: $colorOperation, lvs: ${lvs?.join(", ")}, cardTypes: ${cardTypes?.join(", ")}, minPlayCost: $minPlayCost, maxPlayCost: $maxPlayCost, minDp: $minDp, maxDp: $maxDp, minDigivolutionCost: $minDigivolutionCost, maxDigivolutionCost: $maxDigivolutionCost, rarities: ${rarities?.join(", ")}, page: $page, size: $size, parallelOption: $parallelOption, orderOption: $orderOption, isOrderDesc: $isOrderDesc}';
  }

  void reset() {
    searchString = null;
    noteId = null;
    colors ={};
    colorOperation = null;
    lvs = null;

    cardTypes = null;
    typeOperation =1; 

    types = {};

    minPlayCost=0; 
    maxPlayCost=20;
    minDp=1000;
    maxDp=17000;
    minDigivolutionCost=0;
    maxDigivolutionCost=8;
    rarities = null;

    page = 1;
    size = 84;

    parallelOption = 0;

    orderOption = "sortString";
    isOrderDesc = false;
    isEnglishCardInclude = true;
  }
}