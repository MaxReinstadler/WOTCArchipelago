class WOTCArchipelago_StringHelpers extends Object;

var localized string strFirstName;
var localized string strLastName;
var localized string strNickName;
var localized string strRankFullName;
var localized string strFullName;
var localized string strRankName;
var localized string strRankLastName;
var localized string strFullNickName;

static function string InsertUnitInfo(coerce string Str, XComGameState_Unit UnitState)

{
	Str = Repl(Str, default.strFirstName, UnitState.GetName(eNameType_First));
	Str = Repl(Str, default.strLastName, UnitState.GetName(eNameType_Last));
	Str = Repl(Str, default.strNickName, UnitState.GetName(eNameType_Nick));
	Str = Repl(Str, default.strRankFullName, UnitState.GetName(eNameType_RankFull));
	Str = Repl(Str, default.strFullName, UnitState.GetName(eNameType_Full));
	Str = Repl(Str, default.strRankName, UnitState.GetName(eNameType_Rank));
	Str = Repl(Str, default.strRankLastName, UnitState.GetName(eNameType_RankLast));
	Str = Repl(Str, default.strFullNickName, UnitState.GetName(eNameType_FullNick));

	return Str;
}
