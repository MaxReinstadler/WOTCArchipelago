class X2Effect_ItemUseCheck extends X2Effect;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Item	SourceWeapon;
	local XComGameState_Item	AmmoState;
	local name					AmmoTemplateName;
	local array<name>			ExperimentalAmmoTemplateNames;

	SourceWeapon = XComGameState_Item(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));
	if (SourceWeapon == none)
		SourceWeapon = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));

	AmmoState = XComGameState_Item(NewGameState.GetGameStateForObjectID(SourceWeapon.LoadedAmmo.ObjectID));
	if (AmmoState == none)
		AmmoState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SourceWeapon.LoadedAmmo.ObjectID));

	AmmoTemplateName = AmmoState.GetMyTemplateName();

	ExperimentalAmmoTemplateNames.AddItem('APRounds');
	ExperimentalAmmoTemplateNames.AddItem('TracerRounds');
	ExperimentalAmmoTemplateNames.AddItem('VenomRounds');
	ExperimentalAmmoTemplateNames.AddItem('IncendiaryRounds');
	ExperimentalAmmoTemplateNames.AddItem('TalonRounds');

	if (AmmoTemplateName == 'BluescreenRounds')
		`APCLIENT.OnCheckReached(NewGameState, 'UseBluescreenRounds');
	if (ExperimentalAmmoTemplateNames.Find(AmmoTemplateName) != INDEX_NONE)
		`APCLIENT.OnCheckReached(NewGameState, 'UseExperimentalAmmo');
}

simulated function ApplyEffectToWorld(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	local XComGameState_Ability		SourceAbility;
	local XComGameState_Item		SourceItem;
	local XComGameState_Item		SourceAmmo;
	local name						ItemTemplateName;
	local array<name>				ValidItemTemplateNames;
	local array<name>				ExperimentalGrenadeTemplateNames;
	local array<name>				ExperimentalHeavyWeaponTemplateNames;
	local array<name>				ExperimentalPoweredWeaponTemplateNames;

	SourceAbility = XComGameState_Ability(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if (SourceAbility == none)
		SourceAbility = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));

	SourceItem = XComGameState_Item(NewGameState.GetGameStateForObjectID(SourceAbility.SourceWeapon.ObjectID));
	if (SourceItem == none)
		SourceItem = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SourceAbility.SourceWeapon.ObjectID));

	SourceAmmo = XComGameState_Item(NewGameState.GetGameStateForObjectID(SourceAbility.SourceAmmo.ObjectID));
	if (SourceAmmo == none)
		SourceAmmo = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SourceAbility.SourceAmmo.ObjectID));

	ItemTemplateName = SourceItem.GetMyTemplateName();

	// If item is a grenade launcher, use ammo (= grenade) instead
	if (ClassIsChildOf(SourceItem.GetMyTemplate().Class, class'X2GrenadeLauncherTemplate'))
		ItemTemplateName = SourceAmmo.GetMyTemplateName();

	// Grenades
	ValidItemTemplateNames.AddItem('FragGrenade');
	ValidItemTemplateNames.AddItem('AlienGrenade');
	ValidItemTemplateNames.AddItem('FlashbangGrenade');
	ValidItemTemplateNames.AddItem('SmokeGrenade');
	ValidItemTemplateNames.AddItem('SmokeGrenadeMk2');
	ValidItemTemplateNames.AddItem('EMPGrenade');
	ValidItemTemplateNames.AddItem('EMPGrenadeMk2');
	ValidItemTemplateNames.AddItem('ProximityMine');
	ValidItemTemplateNames.AddItem('Frostbomb');
	ValidItemTemplateNames.AddItem('UltrasonicLure');

	// Utility
	ValidItemTemplateNames.AddItem('Medikit');
	ValidItemTemplateNames.AddItem('NanoMedikit');
	ValidItemTemplateNames.AddItem('SKULLJACK');
	ValidItemTemplateNames.AddItem('BattleScanner');
	ValidItemTemplateNames.AddItem('MimicBeacon');
	ValidItemTemplateNames.AddItem('CombatStims');
	ValidItemTemplateNames.AddItem('RefractionField');

	// Rocket Launcher
	ValidItemTemplateNames.AddItem('RocketLauncher');

	// Experimental Grenades
	ExperimentalGrenadeTemplateNames.AddItem('Firebomb');
	ExperimentalGrenadeTemplateNames.AddItem('FirebombMk2');
	ExperimentalGrenadeTemplateNames.AddItem('AcidGrenade');
	ExperimentalGrenadeTemplateNames.AddItem('AcidGrenadeMk2');
	ExperimentalGrenadeTemplateNames.AddItem('GasGrenade');
	ExperimentalGrenadeTemplateNames.AddItem('GasGrenadeMk2');

	// Experimental Heavy Weapons
	ExperimentalHeavyWeaponTemplateNames.AddItem('Flamethrower');
	ExperimentalHeavyWeaponTemplateNames.AddItem('ShredderGun');
	ExperimentalPoweredWeaponTemplateNames.AddItem('FlamethrowerMk2');
	ExperimentalPoweredWeaponTemplateNames.AddItem('BlasterLauncher');
	ExperimentalPoweredWeaponTemplateNames.AddItem('PlasmaBlaster');
	ExperimentalPoweredWeaponTemplateNames.AddItem('ShredstormCannon');

	// Send valid check
	if (ValidItemTemplateNames.Find(ItemTemplateName) != INDEX_NONE)
		`APCLIENT.OnCheckReached(NewGameState, name("Use" $ ItemTemplateName));

	// Handle experimental grenade checks
	if (ExperimentalGrenadeTemplateNames.Find(ItemTemplateName) != INDEX_NONE)
	{
		`APCLIENT.OnCheckReached(NewGameState, 'UseExperimentalGrenade');
		if (Right(string(ItemTemplateName), 3) == "Mk2")
			`APCLIENT.OnCheckReached(NewGameState, 'UseExperimentalGrenadeMk2');
	}

	// Handle experimental heavy weapon checks
	if ((ExperimentalHeavyWeaponTemplateNames.Find(ItemTemplateName) != INDEX_NONE) || (ExperimentalPoweredWeaponTemplateNames.Find(ItemTemplateName) != INDEX_NONE))
		`APCLIENT.OnCheckReached(NewGameState, 'UseExperimentalHeavyWeapon');
	if (ExperimentalPoweredWeaponTemplateNames.Find(ItemTemplateName) != INDEX_NONE)
		`APCLIENT.OnCheckReached(NewGameState, 'UseExperimentalPoweredWeapon');

	// Handle upgraded item checks
	if (ItemTemplateName == 'AlienGrenade')
		`APCLIENT.OnCheckReached(NewGameState, 'UseFragGrenade');
	if (ItemTemplateName == 'SmokeGrenadeMk2')
		`APCLIENT.OnCheckReached(NewGameState, 'UseSmokeGrenade');
	if (ItemTemplateName == 'EMPGrenadeMk2')
		`APCLIENT.OnCheckReached(NewGameState, 'UseEMPGrenade');
	if (ItemTemplateName == 'NanoMedikit')
		`APCLIENT.OnCheckReached(NewGameState, 'UseMedikit');
}
