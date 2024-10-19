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

    // Should the Event Listener listen for the event during tactical missions?
    Template.RegisterInTactical = true;
    // Should listen to the event while on Avenger?
    Template.RegisterInStrategy = true;

	Template.AddEvent('UnitDied', OnUnitDied);
    Template.AddEvent('XComVictory', OnXComVictory);

    return Template;
}

static protected function EventListenerReturn OnUnitDied(Object EventData, Object EventSource, XComGameState NewGameState, name EventName, Object CallbackData)
{
	local XComGameState_Unit	UnitState;
	local name					CharacterGroupName;
	local array<name>			ValidCharacterGroupNames;
	local name					EnemyKillCheckName;

	UnitState = XComGameState_Unit(EventData);

	if (EventData == none) return ELR_NoInterrupt;

	CharacterGroupName = UnitState.GetMyTemplateGroupName();

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

	// Tracking is disabled for the unit type that died (e.g. it wasn't an enemy)
	if (ValidCharacterGroupNames.Find(CharacterGroupName) == INDEX_NONE) return ELR_NoInterrupt;

	EnemyKillCheckName = name("Kill" $ CharacterGroupName);
	`APCLIENT.OnCheckReached(NewGameState, EnemyKillCheckName);

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn OnXComVictory(Object EventData, Object EventSource, XComGameState NewGameState, name EventName, Object CallbackData)
{
	`APCLIENT.OnCheckReached(NewGameState, 'Victory');

	return ELR_NoInterrupt;
}
