class X2Effect_ItemUseCheck extends X2Effect config(WOTCArchipelago);

struct native ItemCategory
{
	var name			CategoryName;
	var array<name>		Members;
};

var config array<name>				DefaultUseItems;
var config array<ItemCategory>		DefaultUseItemCategories;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Item	SourceWeapon;
	local XComGameState_Item	AmmoState;
	local name					AmmoTemplateName;

	SourceWeapon = XComGameState_Item(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));
	if (SourceWeapon == none)
		SourceWeapon = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));

	AmmoState = XComGameState_Item(NewGameState.GetGameStateForObjectID(SourceWeapon.LoadedAmmo.ObjectID));
	if (AmmoState == none)
		AmmoState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SourceWeapon.LoadedAmmo.ObjectID));

	AmmoTemplateName = AmmoState.GetMyTemplateName();
	CheckItem(NewGameState, AmmoTemplateName);
}

simulated function ApplyEffectToWorld(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	local XComGameState_Ability		SourceAbility;
	local XComGameState_Item		SourceItem;
	local XComGameState_Item		SourceAmmo;
	local name						ItemTemplateName;

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
	CheckItem(NewGameState, ItemTemplateName);

	// If item is a grenade launcher, check ammo (= grenade) as well
	if (ClassIsChildOf(SourceItem.GetMyTemplate().Class, class'X2GrenadeLauncherTemplate'))
		CheckItem(NewGameState, SourceAmmo.GetMyTemplateName());
}

static private function CheckItem(XComGameState NewGameState, name ItemTemplateName)
{
	local ItemCategory Category;

	// Check Default Use Items
	if (default.DefaultUseItems.Find(ItemTemplateName) != INDEX_NONE)
		`APCLIENT.OnCheckReached(NewGameState, name("Use" $ ItemTemplateName));

	// Check Default Use Item Categories
	foreach default.DefaultUseItemCategories(Category)
	{
		if (Category.Members.Find(ItemTemplateName) != INDEX_NONE)
			`APCLIENT.OnCheckReached(NewGameState, name("Use" $ Category.CategoryName));
	}
}
