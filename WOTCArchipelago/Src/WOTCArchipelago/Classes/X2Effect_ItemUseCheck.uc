class X2Effect_ItemUseCheck extends X2Effect config(WOTCArchipelago);

struct native ItemCategory
{
	var name			CategoryName;
	var array<name>		Members;
};

struct native CheckInventory
{
	var name			AbilityName;
	var array<name>		Members;
};

var config array<name>				CheckUseItems;
var config array<ItemCategory>		CheckUseItemCategories;
var config array<CheckInventory>	CheckUseItemInInventory;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Item SourceWeapon;
	local XComGameState_Item AmmoState;

	SourceWeapon = XComGameState_Item(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));
	if (SourceWeapon == none)
		SourceWeapon = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));

	AmmoState = XComGameState_Item(NewGameState.GetGameStateForObjectID(SourceWeapon.LoadedAmmo.ObjectID));
	if (AmmoState == none)
		AmmoState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SourceWeapon.LoadedAmmo.ObjectID));

	CheckItem(NewGameState, AmmoState.GetMyTemplateName());
}

simulated function ApplyEffectToWorld(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState)
{
	local XComGameState_Ability		SourceAbility;
	local XComGameState_Unit		SourceUnit;
	local XComGameState_Item		SourceItem;
	local XComGameState_Item		SourceAmmo;

	SourceAbility = XComGameState_Ability(NewGameState.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if (SourceAbility == none)
		SourceAbility = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));

	SourceUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(SourceAbility.OwnerStateObject.ObjectID));
	if (SourceUnit == none)
		SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(SourceAbility.OwnerStateObject.ObjectID));

	SourceItem = XComGameState_Item(NewGameState.GetGameStateForObjectID(SourceAbility.SourceWeapon.ObjectID));
	if (SourceItem == none)
		SourceItem = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SourceAbility.SourceWeapon.ObjectID));

	SourceAmmo = XComGameState_Item(NewGameState.GetGameStateForObjectID(SourceAbility.SourceAmmo.ObjectID));
	if (SourceAmmo == none)
		SourceAmmo = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(SourceAbility.SourceAmmo.ObjectID));

	CheckItem(NewGameState, SourceItem.GetMyTemplateName());

	// If item is a grenade launcher, check ammo (= grenade) as well
	if (ClassIsChildOf(SourceItem.GetMyTemplate().Class, class'X2GrenadeLauncherTemplate'))
		CheckItem(NewGameState, SourceAmmo.GetMyTemplateName());

	// Check ability in case of inventory exception
	CheckAbility(NewGameState, SourceAbility.GetMyTemplateName(), SourceUnit);
}

static private function CheckAbility(XComGameState NewGameState, name AbilityTemplateName, XComGameState_Unit UnitState)
{
	local CheckInventory			InInventory;
	local StateObjectReference		ItemRef;
	local XComGameState_Item		ItemState;
	local name						ItemTemplateName;

	foreach default.CheckUseItemInInventory(InInventory)
	{
		if (InInventory.AbilityName == AbilityTemplateName)
		{
			// Search unit inventory for specified items
			foreach UnitState.InventoryItems(ItemRef)
			{
				ItemState = XComGameState_Item(NewGameState.GetGameStateForObjectID(ItemRef.ObjectID));
				if (ItemState == none)
					ItemState = XComGameState_Item(`XCOMHISTORY.GetGameStateForObjectID(ItemRef.ObjectID));

				ItemTemplateName = ItemState.GetMyTemplateName();
				if (InInventory.Members.Find(ItemTemplateName) != INDEX_NONE)
					CheckItem(NewGameState, ItemTemplateName);
			}
		}
	}
}

static private function CheckItem(XComGameState NewGameState, name ItemTemplateName)
{
	local ItemCategory Category;

	// Check Items
	if (default.CheckUseItems.Find(ItemTemplateName) != INDEX_NONE)
		`APCLIENT.OnCheckReached(NewGameState, name("Use" $ ItemTemplateName));

	// Check Item Categories
	foreach default.CheckUseItemCategories(Category)
	{
		if (Category.Members.Find(ItemTemplateName) != INDEX_NONE)
			`APCLIENT.OnCheckReached(NewGameState, name("Use" $ Category.CategoryName));
	}
}
