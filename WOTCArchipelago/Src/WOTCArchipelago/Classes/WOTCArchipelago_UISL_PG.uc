class WOTCArchipelago_UISL_PG extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	if (UIFacility_ProvingGround(Screen) == none) return;
	ToggleInstantSparkBuilding();
}

event OnReceiveFocus(UIScreen Screen)
{
	if (UIFacility_ProvingGround(Screen) == none) return;
	ToggleInstantSparkBuilding();
}

private function ToggleInstantSparkBuilding()
{
	local array<StateObjectReference>		AvailableTechRefs;
	local XComGameState_Tech				AvailableTechState;
	local int								Idx;
	local XComGameState						NewGameState;

	AvailableTechRefs = `XCOMHQ.GetAvailableProvingGroundProjects();

	for (Idx = 0; Idx < AvailableTechRefs.Length; Idx++)
	{
		AvailableTechState = XComGameState_Tech(`XCOMHISTORY.GetGameStateForObjectID(AvailableTechRefs[Idx].ObjectID));
		if (AvailableTechState.GetMyTemplateName() == 'BuildSpark')
		{
			NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Toggle instant SPARK building");
			AvailableTechState = XComGameState_Tech(NewGameState.ModifyStateObject(class'XComGameState_Tech', AvailableTechState.ObjectID));
			AvailableTechState.bForceInstant = `APCFG(INSTANT_SPARK_BUILDING);
			`GAMERULES.SubmitGameState(NewGameState);
			break;
		}
	}
}
