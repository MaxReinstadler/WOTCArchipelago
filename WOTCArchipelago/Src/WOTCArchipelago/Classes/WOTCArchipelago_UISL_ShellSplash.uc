// See the Community Highlander's X2WOTCCH_UIScreenListener_ShellSplash.uc
class WOTCArchipelago_UISL_ShellSplash extends UIScreenListener;

var const string ModVersion;

event OnInit(UIScreen Screen)
{
	if (UIShell(Screen) == none) return;
	RealizeVersionText(UIShell(Screen));
}

event OnReceiveFocus(UIScreen Screen)
{
	if (UIShell(Screen) == none) return;
	RealizeVersionText(UIShell(Screen));
}

function RealizeVersionText(UIShell ShellScreen)
{
	local UIText VersionText;

	VersionText = UIText(ShellScreen.GetChildByName('APVersionText', false));
	if (VersionText == none)
	{
		VersionText = ShellScreen.Spawn(class'UIText', ShellScreen);
		VersionText.InitText('APVersionText', default.ModVersion);
		VersionText.AnchorBottomLeft();
		VersionText.SetY(-ShellScreen.TickerHeight + 10);
	}
}

DefaultProperties
{
	ModVersion="WOTCArchipelago 0.7.5"
}
