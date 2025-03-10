class X2EventListener_WOTCArchipelago extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(CreateListenerTemplate());

    return Templates;
}

static private function X2EventListenerTemplate CreateListenerTemplate()
{
    local X2EventListenerTemplate Template;

    `CREATE_X2TEMPLATE(class'X2EventListenerTemplate', Template, 'APEventListenerTemplate');

    Template.RegisterInTactical = true;
    Template.RegisterInStrategy = true;

	Template.AddEvent('UnitDied', OnUnitDied);
	Template.AddEvent('CovertActionCompleted', OnCovertActionCompleted);
    Template.AddEvent('XComVictory', OnXComVictory);
	Template.AddEvent('AfterActionWalkUp', OnWalkUp);
	Template.AddEvent('AfterAction_ChosenDefeated', OnChosenDefeated);

    return Template;
}

static protected function EventListenerReturn OnUnitDied(Object EventData, Object EventSource, XComGameState NewGameState, name EventName, Object CallbackData)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(EventData);
	if (UnitState == none) return ELR_NoInterrupt;

	if (UnitState.GetTeam() == eTeam_Alien || UnitState.GetTeam() == eTeam_TheLost) OnEnemyDied(NewGameState, UnitState);

	return ELR_NoInterrupt;
}

static private function OnEnemyDied(XComGameState NewGameState, XComGameState_Unit EnemyState)
{
	SendEnemyKillCheck(NewGameState, EnemyState);
	DistributeExtraXP(NewGameState, EnemyState);
	GiveExtraCorpses(NewGameState, EnemyState);
}

static private function SendEnemyKillCheck(XComGameState NewGameState, XComGameState_Unit EnemyState)
{
	local name			CharacterGroupName;
	local array<name>	ValidCharacterGroupNames;
	local name			EnemyKillCheckName;

	CharacterGroupName = EnemyState.GetMyTemplateGroupName();

	// List of unit types we want to track
	ValidCharacterGroupNames.AddItem('Sectoid');
	ValidCharacterGroupNames.AddItem('Viper');
	ValidCharacterGroupNames.AddItem('Muton');
	ValidCharacterGroupNames.AddItem('Berserker');
	ValidCharacterGroupNames.AddItem('Archon');
	ValidCharacterGroupNames.AddItem('Gatekeeper');
	ValidCharacterGroupNames.AddItem('Andromedon');
	ValidCharacterGroupNames.AddItem('AndromedonRobot');
	ValidCharacterGroupNames.AddItem('Faceless');
	ValidCharacterGroupNames.AddItem('Chryssalid');
	ValidCharacterGroupNames.AddItem('AdventTrooper');
	ValidCharacterGroupNames.AddItem('AdventCaptain');
	ValidCharacterGroupNames.AddItem('Cyberus');
	ValidCharacterGroupNames.AddItem('AdventPsiWitch');
	ValidCharacterGroupNames.AddItem('AdventStunLancer');
	ValidCharacterGroupNames.AddItem('AdventShieldBearer');
	ValidCharacterGroupNames.AddItem('AdventMEC');
	ValidCharacterGroupNames.AddItem('AdventTurret');
	ValidCharacterGroupNames.AddItem('Sectopod');
	ValidCharacterGroupNames.AddItem('ViperKing');
	ValidCharacterGroupNames.AddItem('BerserkerQueen');
	ValidCharacterGroupNames.AddItem('ArchonKing');
	ValidCharacterGroupNames.AddItem('AdventPurifier');
	ValidCharacterGroupNames.AddItem('AdventPriest');
	ValidCharacterGroupNames.AddItem('TheLost');
	ValidCharacterGroupNames.AddItem('Spectre');
	ValidCharacterGroupNames.AddItem('ChosenAssassin');
	ValidCharacterGroupNames.AddItem('ChosenSniper');
	ValidCharacterGroupNames.AddItem('ChosenWarlock');

	// Check if tracking is disabled for the unit type that died
	if (ValidCharacterGroupNames.Find(CharacterGroupName) != INDEX_NONE)
	{
		EnemyKillCheckName = name("Kill" $ CharacterGroupName);
		`APCLIENT.OnCheckReached(NewGameState, EnemyKillCheckName);
	}
}

static private function DistributeExtraXP(XComGameState NewGameState, XComGameState_Unit EnemyState)
{
	local StateObjectReference	SoldierRef;
	local XComGameState_Unit	SoldierState;
	local float					ExtraXp;

	foreach `XCOMHQ.Squad(SoldierRef)
	{
		if (SoldierRef.ObjectID == 0) continue;

		SoldierState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(SoldierRef.ObjectID));
		
		if (SoldierState != none && SoldierState.IsSoldier() && SoldierState.CanEarnXP() && SoldierState.IsAlive())
		{
			ExtraXp = EnemyState.GetMyTemplate().KillContribution * `APCFG(EXTRA_XP_MULT);

			SoldierState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', SoldierRef.ObjectID));
			`AMLOG("Adding XP: " $ ExtraXp $ " to " $ SoldierState.GetFullName());
			SoldierState.BonusKills += ExtraXp; // Add to bonus kills (like Wet Work, Deeper Learning)
		}
	}
}

static private function GiveExtraCorpses(XComGameState NewGameState, XComGameState_Unit EnemyState)
{
	local X2LootTableManager		LootTableManager;
	local XComGameState_BattleData	BattleData;
	local array<LootReference>		LootRefs;
	local LootReference				LootRef;
	local name						LootTableName;
	local array<name>				LootTemplateNames;
	local name						LootTemplateName;
	local int						Num;

	LootTableManager = class'X2LootTableManager'.static.GetLootTableManager();
	BattleData = XComGameState_BattleData(`XCOMHISTORY.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
	BattleData = XComGameState_BattleData(NewGameState.ModifyStateObject(class'XComGameState_BattleData', BattleData.ObjectID));
	
	LootRefs = EnemyState.GetMyTemplate().Loot.LootReferences;

	foreach LootRefs(LootRef)
	{
		LootTableName = LootRef.LootTableName;
		LootTableManager.RollForLootTable(LootTableName, LootTemplateNames);

		foreach LootTemplateNames(LootTemplateName)
		{
			for (Num = 0; Num < `APCFG(EXTRA_CORPSES); Num++)
				BattleData.AutoLootBucket.AddItem(LootTemplateName);
		}
	}
}

static protected function EventListenerReturn OnCovertActionCompleted(Object EventData, Object EventSource, XComGameState NewGameState, name EventName, Object CallbackData)
{
	local XComGameState_ResistanceFaction	FactionState;
	local name								CheckedCounterName;
	local int								ChosenHuntPart;
	local int								ChosenHuntPartCount;

	class'X2Item_APCounterResources'.static.GetRecentCompletedChosenHuntFaction(FactionState, CheckedCounterName);

	// No chosen hunt covert action
	if (FactionState == none) return ELR_NoInterrupt;

	// HACK: Passing the GameState breaks the read macros right after, but not passing it works fine. Must be haunted.
	ChosenHuntPart = `APCTRINC(CheckedCounterName);

	if (`APCTRREAD('ReaperChosenHuntChecked') >= ChosenHuntPart) ChosenHuntPartCount += 1;
	if (`APCTRREAD('SkirmisherChosenHuntChecked') >= ChosenHuntPart) ChosenHuntPartCount += 1;
	if (`APCTRREAD('TemplarChosenHuntChecked') >= ChosenHuntPart) ChosenHuntPartCount += 1;

	`APCLIENT.OnCheckReached(NewGameState, name("ChosenHuntPt" $ ChosenHuntPart $ ":" $ ChosenHuntPartCount));

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn OnXComVictory(Object EventData, Object EventSource, XComGameState NewGameState, name EventName, Object CallbackData)
{
	`APCLIENT.OnCheckReached(NewGameState, 'Victory');
	return ELR_NoInterrupt;
}

static protected function EventListenerReturn OnWalkUp(Object EventData, Object EventSource, XComGameState NewGameState, name EventName, Object CallbackData)
{
	local XComGameState_MissionSite MissionState;
	MissionState = XComGameState_MissionSite(`XCOMHISTORY.GetGameStateForObjectID(`XCOMHQ.MissionRef.ObjectID));
	if (MissionState.GetMissionSource().DataName == 'MissionSource_Broadcast')
		`APCLIENT.OnCheckReached(NewGameState, 'Broadcast');
	return ELR_NoInterrupt;
}

static protected function EventListenerReturn OnChosenDefeated(Object EventData, Object EventSource, XComGameState NewGameState, name EventName, Object CallbackData)
{
	local int NumChosenDefeated;

	NumChosenDefeated = `APCTRINC('ChosenDefeated');
	if (NumChosenDefeated <= 3)
		`APCLIENT.OnCheckReached(NewGameState, name("Stronghold" $ NumChosenDefeated));
	return ELR_NoInterrupt;
}
