class WOTCArchipelago_APClient extends Actor
		dependson(WOTCArchipelago_TcpLink);

var bool bShowCustomPopup;
var string CustomPopupTitle;
var string CustomPopupText;

var private int SinceLastTick;

var private int ItemsReceivedStrategy;
var private int ItemsReceivedTactical;

var private string TechCompletedType;

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

	ItemsReceivedStrategy = 0;
	ItemsReceivedTactical = 0;

	TechCompletedType = "[TechCompleted]";
}

// CheckName depends on the type of check
//
// Research/Shadow Chamber Projects: TechTemplate.DataName
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
	local WOTCArchipelago_TcpLink Link;

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
	
	// Strategy
	if (`HQPRES != none)
	{
		Link = Spawn(class'WOTCArchipelago_TcpLink');
		Link.Call("/Tick/Strategy/" $ String(ItemsReceivedStrategy), TickStrategyResponseHandler, TickErrorHandler);
	}
	// Tactical
	else
	{
		Link = Spawn(class'WOTCArchipelago_TcpLink');
		Link.Call("/Tick/Tactical/" $ String(ItemsReceivedTactical), TickTacticalResponseHandler, TickErrorHandler);
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

		ItemsReceivedStrategy++;
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

		ItemsReceivedTactical++;
	}
}

private final function TickErrorHandler(WOTCArchipelago_TcpLink Link, HttpResponse Resp)
{
	// Do nothing
}

private final function HandleMessage(string Message)
{
	local array<string>		Lines;
	local name				TemplateName;
	local bool				AddedItem;

	local XComGameState		NewGameState;

	Lines = SplitString(Message, "\n", true);
	
	// TechCompleted
	if (Left(Lines[0], Len(TechCompletedType)) == TechCompletedType)
	{
		TemplateName = name(Mid(Lines[0], Len(TechCompletedType)));

		// Add CompletionItem to HQ inventory
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Adding TechCompleted item to HQ Inventory");
		AddedItem = AddItemToHQInventory(NewGameState, TemplateName, true);

		// Trigger ResearchCompleted event
		`XEVENTMGR.TriggerEvent('ResearchCompleted', , , NewGameState);

		`GAMERULES.SubmitGameState(NewGameState);

		// Raise ItemReceived dialogue if item was added
		if (AddedItem) RaiseDialog(Lines[1], Lines[2]);
	}
	else
	{
		// No item received
		RaiseDialog(Lines[0], Lines[1]);
	}
}

static private final function bool AddItemToHQInventory(XComGameState NewGameState, const name TemplateName, bool IsUnique=false)
{
    local XComGameState_HeadquartersXCom	XComHQ;
	local X2ItemTemplateManager             ItemMgr;
	local X2ItemTemplate					ItemTemplate;
    local XComGameState_Item				ItemState;

	// Drop unique items if already present
	if (IsUnique && `XCOMHQ.HasItemByName(TemplateName)) return false;
	
    XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));

	// Create ItemState
	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
	ItemTemplate = ItemMgr.FindItemTemplate(TemplateName);
    ItemState = ItemTemplate.CreateInstanceFromTemplate(NewGameState);   
	
	// Add item to inventory
    XComHQ.PutItemInInventory(NewGameState, ItemState);
	`AMLOG("Added item to HQ inventory: " $ TemplateName);

	return true;
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
