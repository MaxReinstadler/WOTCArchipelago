// See the Community Highlander's X2WOTCCH_UIScreenListener_ShellSplash.uc
class WOTCArchipelago_UISL_ShellSplash extends UIScreenListener;

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
		VersionText.InitText('APVersionText', class'WOTCArchipelago_Version'.static.GetModVersion());
		VersionText.AnchorBottomLeft();
		VersionText.SetY(-ShellScreen.TickerHeight + 10);
	}
}
