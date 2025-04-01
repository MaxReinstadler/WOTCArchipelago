class WOTCArchipelago_APClient extends Actor
		dependson(WOTCArchipelago_TcpLink);

var bool bShowCustomPopup;
var string CustomPopupTitle;
var string CustomPopupText;

var private int SinceLastTick;

var private string TechCompletedType;
var private string CovertActionRewardType;
var private string ResourceType;
var private string WeaponModType;
var private string StaffType;
var private string TrapType;

var private array<name> CheckBuffer;

var localized string strRequestTimedOut;
var localized string strRequestTimedOutDetails;
var localized string strClientDisconnected;
var localized string strClientDisconnectedDetails;
var localized string strDialogAccept;
var localized string strDramaticMessageTitle;

static function WOTCArchipelago_APClient GetAPClient()
{
	local WOTCArchipelago_APClient APClient;

	foreach `XCOMGAME.AllActors(class'WOTCArchipelago_APClient', APClient)
	{
		break;
	}

	if (APClient == none)
	{
		APClient = `XCOMGAME.Spawn(class'WOTCArchipelago_APClient');
		APClient.Initialize();
	}

	return APClient;
}

private function Initialize()
{
	`AMLOG("Initializing APClient");

	bShowCustomPopup = false;
	CustomPopupTitle = "";
	CustomPopupText = "";

	SinceLastTick = 0;

	TechCompletedType = "[TechCompleted]";
	CovertActionRewardType = "[CovertActionReward]";
	ResourceType = "[Resource]";
	WeaponModType = "[WeaponMod]";
	StaffType = "[Staff]";
	TrapType = "[Trap]";
}

// CheckName depends on the type of check
//
// Research/Shadow Chamber Projects:	TechTemplate.DataName
// Enemy Kills:							'Kill' + CharTemplate.CharacterGroupName
// Item Uses:							'Use' + ItemTemplate.DataName (except experimental items)
// Chosen Hunt Covert Actions:			'ChosenHuntPt' + [1/2/3] + ':' + [1/2/3]
function OnCheckReached(XComGameState NewGameState, name CheckName)
{
	local WOTCArchipelago_TcpLink Link;
	
	`AMLOG("Check reached: " $ CheckName);
	
	Link = Spawn(class'WOTCArchipelago_TcpLink');
	Link.Call("/Check/" $ CheckName, CheckResponseHandler, CheckErrorHandler);
}

private final function CheckResponseHandler(WOTCArchipelago_TcpLink Link, HttpResponse Resp)
{
	local array<string>		Messages;
	local string			Message;

	if (Resp.ResponseCode >= 300) return;

	Messages = SplitString(Resp.Body, "\n\n", true);

	foreach Messages(Message)
	{
		HandleMessage(Message);
	}
	
	Link.Destroy();
	ClearCheckBuffer();
}

private final function CheckErrorHandler(WOTCArchipelago_TcpLink Link, HttpResponse Resp)
{
	local name CheckName;

	`AMLOG("Check Error Status: " $ Resp.ResponseCode);

	// Client can not be reached
	if (Resp.ResponseCode == 408)
	{
		RaiseDialog(default.strRequestTimedOut, default.strRequestTimedOutDetails);
	}
	// Client is not connected to server
	else if (Resp.ResponseCode == 503)
	{
		RaiseDialog(default.strClientDisconnected, default.strClientDisconnectedDetails);
	}

	// Add check to re-send buffer
	CheckName = Link.GetCheckName();
	if (CheckBuffer.Find(CheckName) == INDEX_NONE) CheckBuffer.AddItem(CheckName);
	
	Link.Destroy();
}

function Update()
{
	local WOTCArchipelago_TcpLink Link;

	// Handle custom popup
	if (bShowCustomPopup)
	{
		RaiseDialog(CustomPopupTitle, CustomPopupText);
		bShowCustomPopup = false;
	}

	// Handle tick count
	SinceLastTick++;
	if (SinceLastTick < 25) return;
	SinceLastTick = 0;

	// Handle objective completion
	HandleObjectiveCompletion();

	// Handle chosen stronghold unlock
	HandleStrongholdUnlock();
	
	// Strategy
	if (`HQPRES != none)
	{
		Link = Spawn(class'WOTCArchipelago_TcpLink');
		Link.Call("/Tick/Strategy/" $ `APCTRREAD('ItemsReceivedStrategy'), TickStrategyResponseHandler, TickErrorHandler);
	}
	// Tactical
	else
	{
		Link = Spawn(class'WOTCArchipelago_TcpLink');
		Link.Call("/Tick/Tactical/" $ `APCTRREAD('ItemsReceivedTactical'), TickTacticalResponseHandler, TickErrorHandler);
	}
}

private final function HandleObjectiveCompletion()
{
	local XComGameState						NewGameState;
	local XComGameState_HeadquartersXCom	XComHQ;

	XComHQ = `XCOMHQ;

	// Add story objective completed counters to HQ inventory
	if (!`APCFG(REQ_PSI_GATE_OBJ) || XComHQ.IsObjectiveCompleted('T4_M2_ConstructPsiGate')) `APCTRINC('PsiGateObjectiveCompleted');
	if (!`APCFG(REQ_STASIS_SUIT_OBJ) || XComHQ.IsObjectiveCompleted('T2_M4_BuildStasisSuit')) `APCTRINC('StasisSuitObjectiveCompleted');
	if (!`APCFG(REQ_AVATAR_CORPSE_OBJ) || XComHQ.IsObjectiveCompleted('T1_M6_S0_RecoverAvatarCorpse')) `APCTRINC('AvatarCorpseObjectiveCompleted');

	// HACK: Periodically trigger events to fix sequence broken objectives
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("HACK: Trigger events for sequence breaks");
	`XEVENTMGR.TriggerEvent('ResearchCompleted', , , NewGameState);
	`XEVENTMGR.TriggerEvent('FacilityConstructionCompleted', , , NewGameState); // Proving Grounds, Shadow Chamber
	`XEVENTMGR.TriggerEvent('ItemConstructionCompleted', , , NewGameState); // Skulljack
	`GAMERULES.SubmitGameState(NewGameState);

	// Remove story objective completed counters from HQ inventory
	`APCTRDEC('PsiGateObjectiveCompleted');
	`APCTRDEC('StasisSuitObjectiveCompleted');
	`APCTRDEC('AvatarCorpseObjectiveCompleted');
}

private final function HandleStrongholdUnlock()
{
	local XComGameState_AdventChosen ChosenState;

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_AdventChosen', ChosenState)
	{
		if (!ChosenState.bDefeated && ChosenState.bMetXCom && ChosenState.GetRivalFaction().bMetXCom)
		{
			if (ChosenState.GetMyTemplateName() == 'Chosen_Assassin' && `APCTRREAD('AssassinStrongholdReceived') >= 1)
			{
				UnlockChosenStronghold(ChosenState);
				`APCTRDEC('AssassinStrongholdReceived');
			}
			else if (ChosenState.GetMyTemplateName() == 'Chosen_Hunter' && `APCTRREAD('HunterStrongholdReceived') >= 1)
			{
				UnlockChosenStronghold(ChosenState);
				`APCTRDEC('HunterStrongholdReceived');
			}
			else if (ChosenState.GetMyTemplateName() == 'Chosen_Warlock' && `APCTRREAD('WarlockStrongholdReceived') >= 1)
			{
				UnlockChosenStronghold(ChosenState);
				`APCTRDEC('WarlockStrongholdReceived');
			}
		}
	}
}

private final function ClearCheckBuffer()
{
	local XComGameState		NewGameState;
	local name				CheckName;

	while (CheckBuffer.Length > 0)
	{
		CheckName = CheckBuffer[0];

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Re-send check " $ CheckName $ " from buffer");
		OnCheckReached(NewGameState, CheckName);
		`GAMERULES.SubmitGameState(NewGameState);

		CheckBuffer.Remove(0, 1);
	}
}

private final function TickStrategyResponseHandler(WOTCArchipelago_TcpLink Link, HttpResponse Resp)
{
	local array<string>		Messages;
	local int				NumMessages;
	local string			Message;
	local int				ItemNr;

	if (Resp.ResponseCode >= 300) return;

	Messages = SplitString(Resp.Body, "\n\n", true);

	// Max 5 messages per tick
	NumMessages = Min(5, Messages.Length);

	for (ItemNr = 0; ItemNr < NumMessages; ItemNr++)
	{
		Message = Messages[ItemNr];
		
		HandleMessage(Message);

		`APCTRINC('ItemsReceivedStrategy');
	}
	
	Link.Destroy();
	ClearCheckBuffer();
}

private final function TickTacticalResponseHandler(WOTCArchipelago_TcpLink Link, HttpResponse Resp)
{
	local array<string>		Messages;
	local int				NumMessages;
	local string			Message;
	local int				ItemNr;

	if (Resp.ResponseCode >= 300) return;

	Messages = SplitString(Resp.Body, "\n\n", true);

	// Max 5 messages per tick
	NumMessages = Min(5, Messages.Length);

	for (ItemNr = 0; ItemNr < NumMessages; ItemNr++)
	{
		Message = Messages[ItemNr];
		
		HandleMessage(Message);

		`APCTRINC('ItemsReceivedTactical');
	}

	Link.Destroy();
	ClearCheckBuffer();
}

private final function TickErrorHandler(WOTCArchipelago_TcpLink Link, HttpResponse Resp)
{
	`AMLOG("Tick Error Status: " $ Resp.ResponseCode);

	/* Commented out because it's currently too good at freezing the game

	// Client can not be reached
	if (Resp.ResponseCode == 408)
	{
	    RaiseDialog(default.strRequestTimedOut, default.strRequestTimedOutDetails);
	}
	// Client is not connected to server
	else if (Resp.ResponseCode == 503)
	{
	    RaiseDialog(default.strClientDisconnected, default.strClientDisconnectedDetails);
	}
	*/
	
	Link.Destroy();
}

private final function HandleMessage(string Message)
{
	local array<string>		Lines;
	local array<string>		ItemData;
	local name				ItemName;
	local int				ItemValue;

	local XComGameState		NewGameState;

	Lines = SplitString(Message, "\n", true);
	
	// TechCompleted
	if (Left(Lines[0], Len(TechCompletedType)) == TechCompletedType)
	{
		ItemName = name(Mid(Lines[0], Len(TechCompletedType)));

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding TechCompleted item to HQ inventory");
		AddItemToHQInventory(NewGameState, ItemName);
		`XEVENTMGR.TriggerEvent('ResearchCompleted', , , NewGameState); // Trigger ResearchCompleted event
		`GAMERULES.SubmitGameState(NewGameState);
	}
	// CovertActionReward
	else if (Left(Lines[0], Len(CovertActionRewardType)) == CovertActionRewardType)
	{
		ItemName = name(Mid(Lines[0], Len(CovertActionRewardType)));

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Giving CovertActionReward item");
		GiveCovertActionReward(NewGameState, ItemName);
		`GAMERULES.SubmitGameState(NewGameState);
	}
	// Resource
	else if (Left(Lines[0], Len(ResourceType)) == ResourceType)
	{
		ItemData = SplitString(Mid(Lines[0], Len(ResourceType)), ":");
		ItemName = name(ItemData[0]);
		ItemValue = int(ItemData[1]);

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding resource item to HQ inventory");
		AddItemToHQInventory(NewGameState, ItemName, ItemValue);
		`GAMERULES.SubmitGameState(NewGameState);
	}
	// WeaponMod
	else if (Left(Lines[0], Len(WeaponModType)) == WeaponModType)
	{
		ItemName = name(Mid(Lines[0], Len(WeaponModType)));

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding weapon mod item to HQ inventory");
		AddItemToHQInventory(NewGameState, ItemName);
		`GAMERULES.SubmitGameState(NewGameState);
	}
	// Staff
	else if (Left(Lines[0], Len(StaffType)) == StaffType)
	{
		ItemData = SplitString(Mid(Lines[0], Len(StaffType)), ":");
		ItemName = name(ItemData[0]);
		ItemValue = int(ItemData[1]);

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding staff to HQ crew");
		AddStaffToHQCrew(NewGameState, ItemName, ItemValue);
		`GAMERULES.SubmitGameState(NewGameState);
	}
	// Trap
	else if (Left(Lines[0], Len(TrapType)) == TrapType)
	{
		ItemData = SplitString(Mid(Lines[0], Len(TrapType)), ":");
		ItemName = name(ItemData[0]);
		ItemValue = int(ItemData[1]);

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Triggering trap");
		TriggerTrap(NewGameState, ItemName, ItemValue);
		`GAMERULES.SubmitGameState(NewGameState);
	}
	else
	{
		// No item received, raise arbitrary dialogue and exit
		RaiseDialog(Lines[0], Lines[1]);
		return;
	}

	// If item was received, raise ItemReceived dialogue
	RaiseDialog(Lines[1], Lines[2]);
}

static private final function AddItemToHQInventory(XComGameState NewGameState, const name TemplateName, optional int Quantity = 1)
{
    local XComGameState_HeadquartersXCom	XComHQ;
	local X2ItemTemplateManager             ItemMgr;
	local X2ItemTemplate					ItemTemplate;
    local XComGameState_Item				ItemState;
	
    XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));

	// Create ItemState
	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = ItemMgr.FindItemTemplate(TemplateName);
    ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);
	ItemState.Quantity = Quantity;
	
	// Add item to inventory
    XComHQ.PutItemInInventory(NewGameState, ItemState);

	// Do not print to log for story objective completion resource items
	if (TemplateName == 'PsiGateObjectiveCompleted') return;
	if (TemplateName == 'StasisSuitObjectiveCompleted') return;
	if (TemplateName == 'AvatarCorpseObjectiveCompleted') return;
	`AMLOG("Added item to HQ inventory: " $ TemplateName $ " x" $ Quantity);
}

static private final function RemoveItemFromHQInventory(XComGameState NewGameState, const name TemplateName, optional int Quantity = 1)
{
	local XComGameState_HeadquartersXCom	XComHQ;
	local XComGameState_Item				ItemState;

	// Retrieve ItemState
	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));
	ItemState = XComHQ.GetItemByName(TemplateName);

	if (ItemState == none) return;

	// Remove item from inventory
	XComHQ.RemoveItemFromInventory(NewGameState, ItemState.GetReference(), Quantity);

	// Do not print to log for story objective completion resource items
	if (TemplateName == 'PsiGateObjectiveCompleted') return;
	if (TemplateName == 'StasisSuitObjectiveCompleted') return;
	if (TemplateName == 'AvatarCorpseObjectiveCompleted') return;
	`AMLOG("Removed item from HQ inventory: " $ TemplateName $ " x" $ Quantity);
}

static private final function GiveCovertActionReward(XComGameState NewGameState, const name RewardName)
{
	if (RewardName == 'FactionInfluence') RaiseFactionInfluence(NewGameState);
	else if (RewardName == 'AssassinStronghold') `APCTRINC('AssassinStrongholdReceived', NewGameState);
	else if (RewardName == 'HunterStronghold') `APCTRINC('HunterStrongholdReceived', NewGameState);
	else if (RewardName == 'WarlockStronghold') `APCTRINC('WarlockStrongholdReceived', NewGameState);
	else if (RewardName == 'DefaultChosenHuntReward') GiveDefaultChosenHuntReward(NewGameState);
}

static private final function RaiseFactionInfluence(XComGameState NewGameState, optional XComGameState_ResistanceFaction FactionState)
{
	if (FactionState == none)
	{
		// Pick starting faction at influence 0 or any faction at influence 1
		foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
		{
			if (FactionState.Influence == eFactionInfluence_Minimal && FactionState.bFirstFaction) break;
			if (FactionState.Influence == eFactionInfluence_Respected) break;
			FactionState = none;
		}

		if (FactionState == none)
		{
			// Otherwise, pick any faction at influence 0 (ignore bFarthestFaction for now)
			foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
			{
				if (FactionState.Influence == eFactionInfluence_Minimal) break;
				FactionState = none;
			}
		}
	}

	// No appropriate faction found
	if (FactionState == none) return;

	FactionState = XComGameState_ResistanceFaction(NewGameState.ModifyStateObject(class'XComGameState_ResistanceFaction', FactionState.ObjectID));
	FactionState.IncreaseInfluenceLevel(NewGameState);

	`AMLOG("Increased influence of " $ FactionState.GetMyTemplateName());
}

static private final function UnlockChosenStronghold(XComGameState_AdventChosen ChosenState)
{
	local XComGameState NewGameState;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Unlocking chosen stronghold mission");

	ChosenState = XComGameState_AdventChosen(NewGameState.ModifyStateObject(class'XComGameState_AdventChosen', ChosenState.ObjectID));
	ChosenState.MakeStrongholdMissionVisible(NewGameState);
	ChosenState.MakeStrongholdMissionAvailable(NewGameState);

	`GAMERULES.SubmitGameState(NewGameState);

	`AMLOG("Unlocked stronghold of " $ ChosenState.GetMyTemplateName());
}

static private final function GiveDefaultChosenHuntReward(XComGameState NewGameState)
{
	local XComGameState_ResistanceFaction	FactionState;
	local name								ReceivedCounterName;

	class'X2Item_APCounterResources'.static.GetRecentCheckedChosenHuntFaction(FactionState, ReceivedCounterName);

	if (FactionState.Influence == eFactionInfluence_Minimal || FactionState.Influence == eFactionInfluence_Respected)
	{
		RaiseFactionInfluence(NewGameState, FactionState);
		`APCTRINC(ReceivedCounterName, NewGameState);
	}
	else if (FactionState.Influence == eFactionInfluence_Influential)
	{
		switch (FactionState.GetRivalChosen().GetMyTemplateName())
		{
			case 'Chosen_Assassin':
				`APCTRINC('AssassinStrongholdReceived', NewGameState);
				`APCTRINC(ReceivedCounterName, NewGameState);
				break;
			case 'Chosen_Hunter':
				`APCTRINC('HunterStrongholdReceived', NewGameState);
				`APCTRINC(ReceivedCounterName, NewGameState);
				break;
			case 'Chosen_Warlock':
				`APCTRINC('WarlockStrongholdReceived', NewGameState);
				`APCTRINC(ReceivedCounterName, NewGameState);
				break;
		}
	}
}

static private final function AddStaffToHQCrew(XComGameState NewGameState, const name TemplateName, optional int Quantity = 1)
{
	local XComGameState_HeadquartersXCom	XComHQ;
	local XComGameState_Unit				UnitState;
	local int								Idx;

	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));

	for (Idx = 0; Idx < Quantity; Idx++)
	{
		// Create UnitState
		UnitState = `CHARACTERPOOLMGR.CreateCharacter(NewGameState, `XPROFILESETTINGS.Data.m_eCharPoolUsage, TemplateName);
		UnitState.RandomizeStats();

		// Add staff to crew
		XComHQ.AddToCrew(NewGameState, UnitState);
		XComHQ.HandlePowerOrStaffingChange(NewGameState);
	}

	`AMLOG("Added staff to HQ crew: " $ TemplateName $ " x" $ Quantity);
}

static private final function TriggerTrap(XComGameState NewGameState, const name TrapName, optional int Quantity = 1)
{
	local XComGameState_HeadquartersAlien	AlienHQ;
	local int								StartingForceLevel;
	local int								MaxForceLevel;
	local int								Idx;

	AlienHQ = XComGameState_HeadquartersAlien(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_HeadquartersAlien'));
	AlienHQ = XComGameState_HeadquartersAlien(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersAlien', AlienHQ.ObjectID));

	StartingForceLevel = class'XComGameState_HeadquartersAlien'.default.AlienHeadquarters_StartingForceLevel;
	MaxForceLevel = class'XComGameState_HeadquartersAlien'.default.AlienHeadquarters_MaxForceLevel;

	for (Idx = 0; Idx < Quantity; Idx++)
	{
		// Doom
		if (TrapName == 'Doom')
		{
			AlienHQ.ModifyDoom();
		}
		// Force Level
		else if (TrapName == 'ForceLevel')
		{
			AlienHQ.ForceLevel = Clamp(AlienHQ.ForceLevel + 1, StartingForceLevel, MaxForceLevel);
		}
	}

	`AMLOG("Triggered trap: " $ TrapName $ " x" $ Quantity);
}

static function int IncrementCounter(const name CounterName, optional XComGameState NewGameState)
{
	if (NewGameState != none)
	{
		AddItemToHQInventory(NewGameState, CounterName);
	}
	else
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding counter item to HQ Inventory");
		AddItemToHQInventory(NewGameState, CounterName);
		`GAMERULES.SubmitGameState(NewGameState);
	}

	return ReadCounter(CounterName);
}

static function int DecrementCounter(const name CounterName, optional XComGameState NewGameState)
{
	if (NewGameState != none)
	{
		RemoveItemFromHQInventory(NewGameState, CounterName);
	}
	else
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Removing counter item from HQ Inventory");
		RemoveItemFromHQInventory(NewGameState, CounterName);
		`GAMERULES.SubmitGameState(NewGameState);
	}

	return ReadCounter(CounterName);
}

static function int ReadCounter(const name CounterName)
{
	return `XCOMHQ.GetNumItemInInventory(CounterName);
}

static private final function RaiseDialog(string Title, string Text)
{
	local TDialogueBoxData				kDialogData;
	local SeqAct_ShowDramaticMessage	SeqActShowDramaticMessage;
	local XComGameState					NewGameState;

	// "None" signifies to skip dialog box
	if (Title == "None") return;
	if (Text == "None") return;

	if (`HQPRES != none)
	{
		kDialogData.eType		= eDialog_Normal;
		kDialogData.strTitle	= Title;
		kDialogData.strText		= Text;
		kDialogData.strAccept	= default.strDialogAccept;

		`HQPRES.UIRaiseDialog(kDialogData);
	}
	else
	{
		SeqActShowDramaticMessage = new class'SeqAct_ShowDramaticMessage';
		SeqActShowDramaticMessage.Title = default.strDramaticMessageTitle;
		SeqActShowDramaticMessage.Message1 = Title;
		SeqActShowDramaticMessage.Message2 = Text;
		SeqActShowDramaticMessage.MessageColor = eUIState_Normal;
		
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("SeqAct: Archipelago Tactical Message");
		SeqActShowDramaticMessage.BuildVisualization(NewGameState);
		`GAMERULES.SubmitGameState(NewGameState);
	}
}
