class WOTCArchipelago_MCMListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local WOTCArchipelago_MCMScreen MCMScreen;

	if (ScreenClass == none)
	{
		if (MCM_API(Screen) != none)
			ScreenClass = Screen.Class;
		else return;
	}

	MCMScreen = new class'WOTCArchipelago_MCMScreen';
	MCMScreen.OnInit(Screen);
}

defaultproperties
{
    ScreenClass = none;
}
