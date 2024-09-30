class X2Item_ResearchCompleted extends X2Item;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> CompletionItems;

	// BASE GAME

	// Weapon Techs
	CompletionItems.AddItem(CreateResearchCompletedTemplate('ModularWeaponsCompleted', 'ModularWeapons'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('MagnetizedWeaponsCompleted', 'MagnetizedWeapons'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('GaussWeaponsCompleted', 'GaussWeapons'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('PlasmaRifleCompleted', 'PlasmaRifle'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('HeavyPlasmaCompleted', 'HeavyPlasma'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('PlasmaSniperCompleted', 'PlasmaSniper'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AlloyCannonCompleted', 'AlloyCannon'));

	// Armor Techs
	CompletionItems.AddItem(CreateResearchCompletedTemplate('HybridMaterialsCompleted', 'HybridMaterials'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('PlatedArmorCompleted', 'PlatedArmor'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('PoweredArmorCompleted', 'PoweredArmor'));

	// Elerium Tech
	CompletionItems.AddItem(CreateResearchCompletedTemplate('EleriumCompleted', 'Tech_Elerium'));

	// Psionics Tech
	CompletionItems.AddItem(CreateResearchCompletedTemplate('PsionicsCompleted', 'Psionics'));

	// Autopsy Techs
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AlienBiotechCompleted', 'AlienBiotech'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsySectoidCompleted', 'AutopsySectoid'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyViperCompleted', 'AutopsyViper'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyMutonCompleted', 'AutopsyMuton'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyBerserkerCompleted', 'AutopsyBerserker'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyArchonCompleted', 'AutopsyArchon'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyGatekeeperCompleted', 'AutopsyGatekeeper'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyAndromedonCompleted', 'AutopsyAndromedon'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyFacelessCompleted', 'AutopsyFaceless'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyChryssalidCompleted', 'AutopsyChryssalid'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyAdventTrooperCompleted', 'AutopsyAdventTrooper'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyAdventStunLancerCompleted', 'AutopsyAdventStunLancer'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyAdventShieldbearerCompleted', 'AutopsyAdventShieldbearer'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyAdventMECCompleted', 'AutopsyAdventMEC'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyAdventTurretCompleted', 'AutopsyAdventTurret'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsySectopodCompleted', 'AutopsySectopod'));

	// Golden Path Techs & Shadow Chamber Projects
	CompletionItems.AddItem(CreateResearchCompletedTemplate('ResistanceCommunicationsCompleted', 'ResistanceCommunications'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('ResistanceRadioCompleted', 'ResistanceRadio'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyAdventOfficerCompleted', 'AutopsyAdventOfficer'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AlienEncryptionCompleted', 'AlienEncryption'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('CodexBrainPt1Completed', 'CodexBrainPt1'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('CodexBrainPt2Completed', 'CodexBrainPt2'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('BlacksiteDataCompleted', 'BlacksiteData'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('ForgeStasisSuitCompleted', 'ForgeStasisSuit'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('PsiGateCompleted', 'PsiGate'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyAdventPsiWitchCompleted', 'AutopsyAdventPsiWitch'));

	// ALIEN HUNTERS DLC

	// Experimental Weapons Tech
	CompletionItems.AddItem(CreateResearchCompletedTemplate('ExperimentalWeaponsCompleted', 'ExperimentalWeapons'));

	// Autopsy Techs
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyViperKingCompleted', 'AutopsyViperKing'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyBerserkerQueenCompleted', 'AutopsyBerserkerQueen'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyArchonKingCompleted', 'AutopsyArchonKing'));

	// WOTC DLC

	// Autopsy Techs
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyAdventPurifierCompleted', 'AutopsyAdventPurifier'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyAdventPriestCompleted', 'AutopsyAdventPriest'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsyTheLostCompleted', 'AutopsyTheLost'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('AutopsySpectreCompleted', 'AutopsySpectre'));

	// Chosen Weapons Techs
	CompletionItems.AddItem(CreateResearchCompletedTemplate('ChosenAssassinWeaponsCompleted', 'ChosenAssassinWeapons'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('ChosenHunterWeaponsCompleted', 'ChosenHunterWeapons'));
	CompletionItems.AddItem(CreateResearchCompletedTemplate('ChosenWarlockWeaponsCompleted', 'ChosenWarlockWeapons'));

	return CompletionItems;
}

static private function X2DataTemplate CreateResearchCompletedTemplate(name CompletionItemName, name TechTemplateName)
{
	local X2CompletionItemTemplate Template;

	`CREATE_X2TEMPLATE(class'X2CompletionItemTemplate', Template, CompletionItemName);

	Template.ItemCat = 'goldenpath';
	
	Template.AssociatedClass = class'X2TechTemplate';
	Template.AssociatedTemplateName = TechTemplateName;

	Template.OnAcquiredFn = CallTechDelegate;

	return Template;
}

static function bool CallTechDelegate(XComGameState NewGameState, XComGameState_Item ItemState)
{
	local X2ItemTemplate				ItemTemplate;
	local X2CompletionItemTemplate		CompletionItemTemplate;
	local name							AssociatedTemplateName;
	local XComGameState_Tech			TechState;

	ItemTemplate = ItemState.GetMyTemplate();

	if (!ClassIsChildOf(ItemTemplate.Class, class'X2CompletionItemTemplate'))
	{
		`ERROR("Wrong type for " $ ItemTemplate.DataName);
		return false;
	}

	CompletionItemTemplate = X2CompletionItemTemplate(ItemTemplate);
	AssociatedTemplateName = CompletionItemTemplate.AssociatedTemplateName;
	
	// Find Associated TechState
	foreach `XCOMHISTORY.IterateByClassType(class'XComGameState_Tech', TechState)
	{
		if (TechState.GetMyTemplateName() == AssociatedTemplateName) break;
	}

	if (TechState == none || TechState.GetMyTemplateName() != AssociatedTemplateName)
	{
		`ERROR("No TechState for " $ AssociatedTemplateName);
		return false;
	}

	// Call Associated TechDelegate
	CompletionItemTemplate.AssociatedTechDelegate(NewGameState, TechState);

	`AMLOG("Called Tech Delegate for " $ CompletionItemTemplate.DataName);
	return true;
}
