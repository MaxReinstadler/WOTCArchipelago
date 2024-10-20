class WOTCArchipelago_APClient extends Actor
		dependson(WOTCArchipelago_TcpLink);

var bool bShowCustomPopup;
var string CustomPopupTitle;
var string CustomPopupText;

var private int SinceLastTick;

var private string TechCompletedType;
var private string ResourceType;
var private string WeaponModType;

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
	ResourceType = "[Resource]";
	WeaponModType = "[WeaponMod]";
}

// CheckName depends on the type of check
//
// Research/Shadow Chamber Projects:	TechTemplate.DataName
// Enemy Kills:							'Kill' + CharTemplate.CharacterGroupName
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

	Messages = SplitString(Resp.Body, "\n\n", true);

	foreach Messages(Message)
	{
		HandleMessage(Message);
	}
}

private final function CheckErrorHandler(WOTCArchipelago_TcpLink Link, HttpResponse Resp)
{
	// Do nothing
}

function Update()
{
	local WOTCArchipelago_TcpLink	Link;
	local XComGameState				NewGameState;

	// Handle custom popup
	if (bShowCustomPopup)
	{
		RaiseDialog(CustomPopupTitle, CustomPopupText);
		bShowCustomPopup = false;
	}

	// Handle tick count
	SinceLastTick++;
	if (SinceLastTick < 20) return;
	SinceLastTick = 0;

	// HACK: Periodically trigger events to fix sequence broken objectives
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("HACK: Trigger events for sequence breaks");
	`XEVENTMGR.TriggerEvent('ResearchCompleted', , , NewGameState);
	`XEVENTMGR.TriggerEvent('FacilityConstructionCompleted', , , NewGameState); // Proving Grounds, Shadow Chamber
	`XEVENTMGR.TriggerEvent('ItemConstructionCompleted', , , NewGameState); // Skulljack
	`GAMERULES.SubmitGameState(NewGameState);
	
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

private final function TickStrategyResponseHandler(WOTCArchipelago_TcpLink Link, HttpResponse Resp)
{
	local array<string>		Messages;
	local string			Message;
	local int				ItemNr;

	Messages = SplitString(Resp.Body, "\n\n", true);

	for (ItemNr = 0; ItemNr < Messages.Length; ItemNr++)
	{
		Message = Messages[ItemNr];
		
		HandleMessage(Message);

		`APCTRINC('ItemsReceivedStrategy');
	}
}

private final function TickTacticalResponseHandler(WOTCArchipelago_TcpLink Link, HttpResponse Resp)
{
	local array<string>		Messages;
	local string			Message;
	local int				ItemNr;

	Messages = SplitString(Resp.Body, "\n\n", true);

	for (ItemNr = 0; ItemNr < Messages.Length; ItemNr++)
	{
		Message = Messages[ItemNr];
		
		HandleMessage(Message);

		`APCTRINC('ItemsReceivedTactical');
	}
}

private final function TickErrorHandler(WOTCArchipelago_TcpLink Link, HttpResponse Resp)
{
	// Do nothing
}

private final function HandleMessage(string Message)
{
	local array<string>		Lines;
	local array<string>		ResourceData;
	local name				TemplateName;
	local int				Quantity;

	local XComGameState		NewGameState;

	Lines = SplitString(Message, "\n", true);
	
	// TechCompleted
	if (Left(Lines[0], Len(TechCompletedType)) == TechCompletedType)
	{
		TemplateName = name(Mid(Lines[0], Len(TechCompletedType)));

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding TechCompleted item to HQ Inventory");
		AddItemToHQInventory(NewGameState, TemplateName);
		`XEVENTMGR.TriggerEvent('ResearchCompleted', , , NewGameState); // Trigger ResearchCompleted event
		`GAMERULES.SubmitGameState(NewGameState);
	}
	// Resource
	else if (Left(Lines[0], Len(ResourceType)) == ResourceType)
	{
		ResourceData = SplitString(Mid(Lines[0], Len(ResourceType)), ":");
		TemplateName = name(ResourceData[0]);
		Quantity = int(ResourceData[1]);

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding resource item to HQ Inventory");
		AddItemToHQInventory(NewGameState, TemplateName, Quantity);
		`GAMERULES.SubmitGameState(NewGameState);
	}
	// WeaponMod
	else if (Left(Lines[0], Len(WeaponModType)) == WeaponModType)
	{
		TemplateName = name(Mid(Lines[0], Len(WeaponModType)));

		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding weapon mod item to HQ Inventory");
		AddItemToHQInventory(NewGameState, TemplateName);
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
	`AMLOG("Added item to HQ inventory: " $ TemplateName $ " x" $ Quantity);
}

static private final function int GetItemQuantityInHQInventory(XComGameState NewGameState, const name TemplateName)
{
	local XComGameState_HeadquartersXCom XComHQ;

	XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));

	return XComHQ.GetNumItemInInventory(TemplateName);
}

static function IncrementCounter(const name CounterName)
{
	local XComGameState NewGameState;

	// Increase ItemsReceivedTactical counter
	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding counter item to HQ Inventory");
	AddItemToHQInventory(NewGameState, CounterName);
	`GAMERULES.SubmitGameState(NewGameState);
}

static function int ReadCounter(const name CounterName)
{
	local XComGameState		NewGameState;
	local int				CounterValue;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Reading counter item quantity from HQ Inventory");
	CounterValue = GetItemQuantityInHQInventory(NewGameState, CounterName);
	`GAMERULES.SubmitGameState(NewGameState);

	return CounterValue;
}

static private final function RaiseDialog(string Title, string Text)
{
	local TDialogueBoxData kDialogData;

	// "None" signifies to skip dialog box
	if (Title == "None") return;
	if (Text == "None") return;

	kDialogData.eType		= eDialog_Normal;
	kDialogData.strTitle	= Title;
	kDialogData.strText		= Text;
	kDialogData.strAccept	= "OK";

	if (`HQPRES != none) `HQPRES.UIRaiseDialog(kDialogData);
}
