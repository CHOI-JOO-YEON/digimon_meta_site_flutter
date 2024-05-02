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
  int? maxDp=16000;
  int? minDigivolutionCost=0;
  int? maxDigivolutionCost=8;
  Set<String>? rarities;

  int page = 1;
  int size = 84;

  int parallelOption = 0; // 0= all, 1= onlyNormal, 2=onlyParallel

  String orderOption = "sortString";
  bool isOrderDesc = false;
  bool isEnglishCardInclude = true;

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
}