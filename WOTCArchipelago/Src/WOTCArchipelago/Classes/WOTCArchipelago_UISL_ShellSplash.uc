// See the Community Highlander's X2WOTCCH_UIScreenListener_ShellSplash.uc
class WOTCArchipelago_UISL_ShellSplash extends UIScreenListener;

var bool bShowedWarningPopup;

event OnInit(UIScreen Screen)
{
	local UIShell ShellScreen;

	ShellScreen = UIShell(Screen);
	if (ShellScreen == none) return;

	RealizeVersionText(ShellScreen);

	// Black magic but it works
	ShowWarningPopup(ShellScreen);
	bShowedWarningPopup = false;
}

event OnReceiveFocus(UIScreen Screen)
{
	local UIShell ShellScreen;

	ShellScreen = UIShell(Screen);
	if (ShellScreen == none) return;

	RealizeVersionText(ShellScreen);

	ShowWarningPopup(ShellScreen);
}

private function RealizeVersionText(UIShell ShellScreen)
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

private function ShowWarningPopup(UIShell ShellScreen)
{
	if (bShowedWarningPopup) return;

	if (!class'WOTCArchipelago_Version'.static.CanCheckVersion())
		RealizeDisconnectedPopup(ShellScreen);
	else if (!class'WOTCArchipelago_Version'.static.CheckVersion(false))
		RealizeIncompatiblePopup(ShellScreen);

	bShowedWarningPopup = true;
}

private function RealizeDisconnectedPopup(UIShell ShellScreen)
{
	local TDialogueBoxData kDialogData;

	kDialogData.eType = eDialog_Warning;
	kDialogData.strTitle = class'WOTCArchipelago_APClient'.default.strDisconnectedWarning;
	kDialogData.strText = class'WOTCArchipelago_APClient'.default.strDisconnectedWarningDetails;
	kDialogData.strAccept = class'WOTCArchipelago_APClient'.default.strDialogAccept;

	ShellScreen.Movie.Pres.UIRaiseDialog(kDialogData);
}

private function RealizeIncompatiblePopup(UIShell ShellScreen)
{
	local TDialogueBoxData kDialogData;

	kDialogData.eType = eDialog_Warning;
	kDialogData.strTitle = class'WOTCArchipelago_APClient'.default.strIncompatibleWarning;
	kDialogData.strText = class'WOTCArchipelago_APClient'.default.strIncompatibleWarningDetails;
	kDialogData.strAccept = class'WOTCArchipelago_APClient'.default.strDialogAccept;

	ShellScreen.Movie.Pres.UIRaiseDialog(kDialogData);
}
