enum Form{
  IN_TRAINING("In-Training","유년기"),
  BABY("Baby","유년기"),
  ROOKIE("Rookie","성장기"),
  CHAMPION("Champion","성숙기"),
  ULTIMATE("Ultimate","완전체"),
  MEGA("Mega","궁극체"),
  ARMOR("Armor Form","아머체"),
  D_REAPER("D-Reaper","데리퍼"),
  UNKNOWN("Unknown","불명"),
  HYBRID("Hybrid","하이브리드체");


  final String engName;
  final String korName;
  const Form(this.engName, this.korName);
  static String findKorNameByName(String engName) {
    for (Form form in Form.values) {
      if (form.name == engName) {
        return form.korName;
      }
    }
    return "Not Found";
  }
}