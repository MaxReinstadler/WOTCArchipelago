class X2Item_APCounterResources extends X2Item;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> APCounterItems;

	// Items Received
	APCounterItems.AddItem(CreateCounterTemplate('ItemsReceivedStrategy'));
	APCounterItems.AddItem(CreateCounterTemplate('ItemsReceivedTactical'));

	// Chosen Hunt Covert Actions Checked
	APCounterItems.AddItem(CreateCounterTemplate('ReaperChosenHuntChecked'));
	APCounterItems.AddItem(CreateCounterTemplate('SkirmisherChosenHuntChecked'));
	APCounterItems.AddItem(CreateCounterTemplate('TemplarChosenHuntChecked'));

	// Chosen Hunt Covert Action Unlocks Received
	APCounterItems.AddItem(CreateCounterTemplate('ReaperChosenHuntReceived'));
	APCounterItems.AddItem(CreateCounterTemplate('SkirmisherChosenHuntReceived'));
	APCounterItems.AddItem(CreateCounterTemplate('TemplarChosenHuntReceived'));

	// Chosen Stronghold Unlocks Received
	APCounterItems.AddItem(CreateCounterTemplate('AssassinStrongholdReceived'));
	APCounterItems.AddItem(CreateCounterTemplate('HunterStrongholdReceived'));
	APCounterItems.AddItem(CreateCounterTemplate('WarlockStrongholdReceived'));

	// Chosen Defeated
	APCounterItems.AddItem(CreateCounterTemplate('ChosenDefeated'));

	// Story Objectives Completed
	APCounterItems.AddItem(CreateCounterTemplate('PsiGateObjectiveCompleted'));
	APCounterItems.AddItem(CreateCounterTemplate('StasisSuitObjectiveCompleted'));
	APCounterItems.AddItem(CreateCounterTemplate('AvatarCorpseObjectiveCompleted'));

	return APCounterItems;
}

// Count chosen hunt covert ops completed by each faction
static function CountChosenHuntCompleted(out int NumReaperChosenHuntCompleted, out int NumSkirmisherChosenHuntCompleted, out int NumTemplarChosenHuntCompleted, optional XComGameState NewGameState)
{
	local XComGameState_ResistanceFaction	FactionState;
	local array<name>						ChosenHuntNameList;
	local name								ChosenHuntName;

	ChosenHuntNameList.AddItem('CovertAction_RevealChosenMovements');
	ChosenHuntNameList.AddItem('CovertAction_RevealChosenStrengths');
	ChosenHuntNameList.AddItem('CovertAction_RevealChosenStronghold');

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		if (NewGameState != none)
			FactionState = XComGameState_ResistanceFaction(NewGameState.GetGameStateForObjectID(FactionState.ObjectID));

		foreach ChosenHuntNameList(ChosenHuntName)
		{
			if (FactionState.CompletedCovertActions.Find(ChosenHuntName) != INDEX_NONE)
			{
				if (FactionState.GetMyTemplateName() == 'Faction_Reapers') NumReaperChosenHuntCompleted += 1;
				if (FactionState.GetMyTemplateName() == 'Faction_Skirmishers') NumSkirmisherChosenHuntCompleted += 1;
				if (FactionState.GetMyTemplateName() == 'Faction_Templars') NumTemplarChosenHuntCompleted += 1;
			}
		}
	}
}

// Get faction of most recently completed (and not checked) chosen hunt covert op
static function GetRecentCompletedChosenHuntFaction(out XComGameState_ResistanceFaction FactionState, out name CheckedCounterName, optional XComGameState NewGameState)
{
	local int NumReaperChosenHuntCompleted;
	local int NumSkirmisherChosenHuntCompleted;
	local int NumTemplarChosenHuntCompleted;

	CountChosenHuntCompleted(NumReaperChosenHuntCompleted, NumSkirmisherChosenHuntCompleted, NumTemplarChosenHuntCompleted, NewGameState);

	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		switch (FactionState.GetMyTemplateName())
		{
			case 'Faction_Reapers':
				CheckedCounterName = 'ReaperChosenHuntChecked';
				if (`APCTRREAD(CheckedCounterName) < NumReaperChosenHuntCompleted) return;
				break;
			case 'Faction_Skirmishers':
				CheckedCounterName = 'SkirmisherChosenHuntChecked';
				if (`APCTRREAD(CheckedCounterName) < NumSkirmisherChosenHuntCompleted) return;
				break;
			case 'Faction_Templars':
				CheckedCounterName = 'TemplarChosenHuntChecked';
				if (`APCTRREAD(CheckedCounterName) < NumTemplarChosenHuntCompleted) return;
				break;
		}
	}

	// No chosen hunt covert action
	FactionState = none;
}

// Get faction of most recently checked (and not received) chosen hunt covert op
static function GetRecentCheckedChosenHuntFaction(out XComGameState_ResistanceFaction FactionState, out name ReceivedCounterName)
{
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_ResistanceFaction', FactionState)
	{
		switch (FactionState.GetMyTemplateName())
		{
			case 'Faction_Reapers':
				ReceivedCounterName = 'ReaperChosenHuntReceived';
				if (`APCTRREAD(ReceivedCounterName) < `APCTRREAD('ReaperChosenHuntChecked')) return;
				break;
			case 'Faction_Skirmishers':
				ReceivedCounterName = 'SkirmisherChosenHuntReceived';
				if (`APCTRREAD(ReceivedCounterName) < `APCTRREAD('SkirmisherChosenHuntChecked')) return;
				break;
			case 'Faction_Templars':
				ReceivedCounterName = 'TemplarChosenHuntReceived';
				if (`APCTRREAD(ReceivedCounterName) < `APCTRREAD('TemplarChosenHuntChecked')) return;
				break;
		}
	}

	// No chosen hunt covert action
	FactionState = none;
}

static private function X2DataTemplate CreateCounterTemplate(name TemplateName)
{
	local X2ItemTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ItemTemplate', Template, TemplateName);
	Template.CanBeBuilt = false;
	Template.HideInInventory = true;
	Template.ItemCat = 'resource';

	return Template;
}