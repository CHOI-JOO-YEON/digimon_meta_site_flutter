enum PageName {
  home(''),
  admin('admin'),
  login('login'),
  deckBuilder('deck-builder'),
  toyBox('toy-box')
  ;


  final String route;

  const PageName(this.route);

  String get getRoute => route;
}
