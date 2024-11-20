//---------------------------------------------------------------------------------------
//  FILE:    X2DLCInfo_WOTCArchipelago.uc
//  AUTHOR:  Iridar / Enhanced Mod Project Template --  26/02/2024
//  PURPOSE: Contains various DLC hooks, with examples on using the most popular ones.
//           Delete this file if you do not end up using it, as every class
//           that extends X2DownloadableContentInfo adds a tiny performance cost.
//---------------------------------------------------------------------------------------

class X2DLCInfo_WOTCArchipelago extends X2DownloadableContentInfo;

delegate ModifyTemplate(X2DataTemplate DataTemplate);


//=======================================================================================
//                           ON POST TEMPLATES CREATED (OPTC)
//---------------------------------------------------------------------------------------

// Purpose: patching templates.
// Runs: every time the game starts, after creating templates.

static event OnPostTemplatesCreated()
{
	// Patch research projects to alter effects upon completion
	`AMLOG("Patching Research Project Templates");
	IterateTemplatesAllDiff(class'X2TechTemplate', PatchResearchTemplates);

	// Patch items to alter unlock requirements
	`AMLOG("Patching Item Templates");
	IterateTemplatesAllDiff(class'X2ItemTemplate', PatchItemTemplates);

	// Patch facilities to alter unlock requirements
	`AMLOG("Patching Facility Templates");
	IterateTemplatesAllDiff(class'X2FacilityTemplate', PatchStrategyElementTemplates);

	// Patch facility upgrades to alter unlock requirements
	`AMLOG("Patching Facility Upgrade Templates");
	IterateTemplatesAllDiff(class'X2FacilityUpgradeTemplate', PatchStrategyElementTemplates);

	// Patch objectives to alter completion requirements
	`AMLOG("Patching Objective Templates");
	IterateTemplatesAllDiff(class'X2ObjectiveTemplate', PatchStrategyElementTemplates);

	// Patch proving ground projects to alter unlock requirements
	`AMLOG("Patching Proving Ground Project Templates");
	IterateTemplatesAllDiff(class'X2TechTemplate', PatchProvingGroundTemplates);

	// Patch mission source templates to disable some optional mission types
	`AMLOG("Patching Mission Source Templates");
	IterateTemplatesAllDiff(class'X2MissionSourceTemplate', PatchMissionSourceTemplates);

	// Patch covert action risk templates to disarm ambush and capture risks
	`AMLOG("Patching Covert Op Risk Templates");
	IterateTemplatesAllDiff(class'X2CovertActionRiskTemplate', PatchCovertActionRiskTemplates);

	// Patch chosen hunt covert action templates to alter rewards
	`AMLOG("Patching Covert Op Templates");
	IterateTemplatesAllDiff(class'X2CovertActionTemplate', PatchCovertActionTemplates);
}

// Patch research projects to alter effects upon completion
static private function PatchResearchTemplates(X2DataTemplate DataTemplate)
{
	local X2TechTemplate				TechTemplate;
	local name							TechTemplateName;
	local X2CompletionItemTemplate		CompletionItemTemplate;

    TechTemplate = X2TechTemplate(DataTemplate);
	TechTemplateName = TechTemplate.DataName;

	// Ignore random or repeatable projects
	if (TechTemplate.bBreakthrough) return;
	if (TechTemplate.bProvingGround) return;
	if (TechTemplate.bRepeatable) return;

	CompletionItemTemplate = class'X2CompletionItemTemplate'.static.GetCompletionItemTemplate(TechTemplateName);

	if (CompletionItemTemplate == none)
	{
		`ERROR("No CompletionItemTemplate for " $ TechTemplateName);
		return;
	}

	// Replace completion delegate
	CompletionItemTemplate.AssociatedTechDelegate = TechTemplate.ResearchCompletedFn;
	TechTemplate.ResearchCompletedFn = HandleResearchCompletion;

	// Enable pop-ups for AlienBiotech and AutopsyAdventOfficer
	TechTemplate.bJumpToLabs = false;

	`AMLOG("Patched " $ TechTemplate.Name);
}

// Handle research completions as Archipelago checks
static function HandleResearchCompletion(XComGameState NewGameState, XComGameState_Tech TechState)
{
	local X2TechTemplate	TechTemplate;
	local name				TechTemplateName;
	
	TechTemplate = TechState.GetMyTemplate();
	TechTemplateName = TechState.GetMyTemplateName();

	`AMLOG("Research Completed: " $ TechTemplateName);

	`APCLIENT.OnCheckReached(NewGameState, TechTemplateName);

	// Trigger pop-ups for Shadow Chamber projects
	if (TechTemplate.bShadowProject)
	{
		TechTemplate.bShadowProject = false;
		`HQPRES.UIResearchComplete(TechState.GetReference());
		TechTemplate.bShadowProject = true;
	}
}

// Patch items to alter unlock requirements
static private function PatchItemTemplates(X2DataTemplate DataTemplate)
{
	local X2ItemTemplate				ItemTemplate;
	local StrategyRequirement			Requirements;
	local array<name>					RequiredTechs;
	local name							ReqTechTemplateName;
	local X2CompletionItemTemplate		CompletionItemTemplate;

	ItemTemplate = X2ItemTemplate(DataTemplate);
	Requirements = ItemTemplate.Requirements;

	// Replace Tech Requirements with Item Requirements
	RequiredTechs = Requirements.RequiredTechs;
	foreach RequiredTechs(ReqTechTemplateName)
	{
		`AMLOG("Attempting to replace Tech Requirement: " $ ReqTechTemplateName);

		CompletionItemTemplate = class'X2CompletionItemTemplate'.static.GetCompletionItemTemplate(ReqTechTemplateName);

		if (CompletionItemTemplate == none) continue;
		
		ItemTemplate.Requirements.RequiredItems.AddItem(CompletionItemTemplate.DataName);
		ItemTemplate.Requirements.RequiredTechs.RemoveItem(ReqTechTemplateName);

		`AMLOG("Replaced with Item Requirement: " $ CompletionItemTemplate.DataName);
	}

	`AMLOG("Patched " $ ItemTemplate.Name);
}

// Patch strategy elements to alter unlock/completion requirements
static private function PatchStrategyElementTemplates(X2DataTemplate DataTemplate)
{
	local X2FacilityTemplate			FacilityTemplate;
	local X2FacilityUpgradeTemplate		FacilityUpgradeTemplate;
	local X2ObjectiveTemplate			ObjectiveTemplate;

	local StrategyRequirement			Requirements;
	local array<name>					RequiredTechs;
	local name							ReqTechTemplateName;
	local X2CompletionItemTemplate		CompletionItemTemplate;

	// Filter by class
	if (ClassIsChildOf(DataTemplate.Class, class'X2FacilityTemplate'))
	{
		FacilityTemplate = X2FacilityTemplate(DataTemplate);
		Requirements = FacilityTemplate.Requirements;
	}
	else if (ClassIsChildOf(DataTemplate.Class, class'X2FacilityUpgradeTemplate'))
	{
		FacilityUpgradeTemplate = X2FacilityUpgradeTemplate(DataTemplate);
		Requirements = FacilityUpgradeTemplate.Requirements;
	}
	else if (ClassIsChildOf(DataTemplate.Class, class'X2ObjectiveTemplate'))
	{
		ObjectiveTemplate = X2ObjectiveTemplate(DataTemplate);
		Requirements = ObjectiveTemplate.CompletionRequirements;

		// Alter Avatar Autopsy requirements
		if (ObjectiveTemplate.Name == 'T5_M1_AutopsyTheAvatar')
		{
			ObjectiveTemplate.AssignmentRequirements.RequiredObjectives.RemoveItem('T1_M6_S0_RecoverAvatarCorpse');
			ObjectiveTemplate.CompletionRequirements.RequiredItems.AddItem('PsiGateObjectiveCompleted');
			ObjectiveTemplate.CompletionRequirements.RequiredItems.AddItem('StasisSuitObjectiveCompleted');
			ObjectiveTemplate.CompletionRequirements.RequiredItems.AddItem('AvatarCorpseObjectiveCompleted');
		}
	}
	else
	{
		`ERROR("Patch failed: Incorrect type for " $ DataTemplate.Name);
		return;
	}

	// Replace Tech Requirements with Item Requirements
	RequiredTechs = Requirements.RequiredTechs;
	foreach RequiredTechs(ReqTechTemplateName)
	{
		`AMLOG("Attempting to replace Tech Requirement: " $ ReqTechTemplateName);

		CompletionItemTemplate = class'X2CompletionItemTemplate'.static.GetCompletionItemTemplate(ReqTechTemplateName);

		if (CompletionItemTemplate == none) continue;
		
		// Filter by class
		if (ClassIsChildOf(DataTemplate.Class, class'X2FacilityTemplate'))
		{
			FacilityTemplate.Requirements.RequiredItems.AddItem(CompletionItemTemplate.DataName);
			FacilityTemplate.Requirements.RequiredTechs.RemoveItem(ReqTechTemplateName);
		}
		else if (ClassIsChildOf(DataTemplate.Class, class'X2FacilityUpgradeTemplate'))
		{
			FacilityUpgradeTemplate.Requirements.RequiredItems.AddItem(CompletionItemTemplate.DataName);
			FacilityUpgradeTemplate.Requirements.RequiredTechs.RemoveItem(ReqTechTemplateName);
		}
		else if (ClassIsChildOf(DataTemplate.Class, class'X2ObjectiveTemplate'))
		{
			ObjectiveTemplate.CompletionRequirements.RequiredItems.AddItem(CompletionItemTemplate.DataName);
			ObjectiveTemplate.CompletionRequirements.RequiredTechs.RemoveItem(ReqTechTemplateName);
		}

		`AMLOG("Replaced with Item Requirement: " $ CompletionItemTemplate.DataName);
	}

	`AMLOG("Patched " $ DataTemplate.Name);
}

// Patch proving ground projects to alter unlock requirements
static private function PatchProvingGroundTemplates(X2DataTemplate DataTemplate)
{
	local X2TechTemplate				TechTemplate;
	local StrategyRequirement			Requirements;
	local array<name>					RequiredTechs;
	local name							ReqTechTemplateName;
	local X2CompletionItemTemplate		CompletionItemTemplate;

	TechTemplate = X2TechTemplate(DataTemplate);
	if (!TechTemplate.bProvingGround) return;
	Requirements = TechTemplate.Requirements;

	// Replace Tech Requirements with Item Requirements
	RequiredTechs = Requirements.RequiredTechs;
	foreach RequiredTechs(ReqTechTemplateName)
	{
		`AMLOG("Attempting to replace Tech Requirement: " $ ReqTechTemplateName);

		CompletionItemTemplate = class'X2CompletionItemTemplate'.static.GetCompletionItemTemplate(ReqTechTemplateName);

		if (CompletionItemTemplate == none) continue;
		
		TechTemplate.Requirements.RequiredItems.AddItem(CompletionItemTemplate.DataName);
		TechTemplate.Requirements.RequiredTechs.RemoveItem(ReqTechTemplateName);

		`AMLOG("Replaced with Item Requirement: " $ CompletionItemTemplate.DataName);
	}

	`AMLOG("Patched " $ TechTemplate.Name);
}

// Patch mission source templates to disable some optional mission types
static private function PatchMissionSourceTemplates(X2DataTemplate DataTemplate)
{
	local X2MissionSourceTemplate MissionSourceTemplate;

	MissionSourceTemplate = X2MissionSourceTemplate(DataTemplate);

	// Only patch supply raids, council and faction missions
	if (MissionSourceTemplate.DataName == 'MissionSource_SupplyRaid')
	{
		MissionSourceTemplate.SpawnMissionsFn = class'X2StrategyElement_OverrideMissionSources'.static.SpawnSupplyRaidMission_Override;
		`AMLOG("Patched " $ MissionSourceTemplate.Name);
	}
	else if (MissionSourceTemplate.DataName == 'MissionSource_Council')
	{
		MissionSourceTemplate.SpawnMissionsFn = class'X2StrategyElement_OverrideMissionSources'.static.SpawnCouncilMission_Override;
		MissionSourceTemplate.OnSuccessFn = class'X2StrategyElement_OverrideMissionSources'.static.CouncilOnSuccess_Override;
		`AMLOG("Patched " $ MissionSourceTemplate.Name);
	}
	else if (MissionSourceTemplate.DataName == 'MissionSource_ResistanceOp')
	{
		MissionSourceTemplate.SpawnMissionsFn = class'X2StrategyElement_OverrideMissionSources'.static.SpawnResOpMission_Override;
		MissionSourceTemplate.OnSuccessFn = class'X2StrategyElement_OverrideMissionSources'.static.ResOpOnSuccess_Override;
		`AMLOG("Patched " $ MissionSourceTemplate.Name);
	}
}

// Patch covert action risk templates to disable ambush and capture risks
static private function PatchCovertActionRiskTemplates(X2DataTemplate DataTemplate)
{
	local X2CovertActionRiskTemplate CovertActionRiskTemplate;

	CovertActionRiskTemplate = X2CovertActionRiskTemplate(DataTemplate);

	// Only patch ambush and capture risks
	if (CovertActionRiskTemplate.DataName == 'CovertActionRisk_Ambush')
	{
		CovertActionRiskTemplate.ApplyRiskFn = class'X2StrategyElement_OverrideMissionSources'.static.CreateAmbushMission_Override;
		`AMLOG("Patched " $ CovertActionRiskTemplate.Name);
	}
	else if (CovertActionRiskTemplate.DataName == 'CovertActionRisk_SoldierCaptured')
	{
		CovertActionRiskTemplate.ApplyRiskFn = class'X2StrategyElement_OverrideMissionSources'.static.ApplySoldierCaptured_Override;
		`AMLOG("Patched " $ CovertActionRiskTemplate.Name);
	}
}

// Patch chosen hunt covert action templates to alter rewards
static private function PatchCovertActionTemplates(X2DataTemplate DataTemplate)
{
	local X2CovertActionTemplate	CovertActionTemplate;
	local array<name>				NewRewards;
	local array<name>				ChosenHuntNames;

	CovertActionTemplate = X2CovertActionTemplate(DataTemplate);

	NewRewards.AddItem('Reward_APChosenHunt');
	ChosenHuntNames.AddItem('CovertAction_RevealChosenMovements');
	ChosenHuntNames.AddItem('CovertAction_RevealChosenStrengths');
	ChosenHuntNames.AddItem('CovertAction_RevealChosenStronghold');

	// Only patch chosen hunt covert actions
	if (ChosenHuntNames.Find(CovertActionTemplate.DataName) != INDEX_NONE)
	{
		CovertActionTemplate.Rewards = NewRewards;
		`AMLOG("Patched " $ CovertActionTemplate.Name);
	}
}


//=======================================================================================
//                                       UPDATE
//---------------------------------------------------------------------------------------

// Triggered by Geoscape Tick
static event UpdateDLC()
{
	`APCLIENT.Update();
}


//=======================================================================================
//                                   HELPER FUCTIONS
//---------------------------------------------------------------------------------------

static private function IterateTemplatesAllDiff(class TemplateClass, delegate<ModifyTemplate> ModifyTemplateFn)
{
    local X2DataTemplate                            IterateTemplate;
    local X2DataTemplate                            DataTemplate;
    local array<X2DataTemplate>                     DataTemplates;
    local X2DLCInfo_WOTCArchipelago		            CDO;

    local X2ItemTemplateManager                     ItemMgr;
    local X2AbilityTemplateManager                  AbilityMgr;
    local X2CharacterTemplateManager                CharMgr;
    local X2StrategyElementTemplateManager          StratMgr;
    local X2SoldierClassTemplateManager             ClassMgr;

    if (ClassIsChildOf(TemplateClass, class'X2ItemTemplate'))
    {
        CDO = GetCDO();
        ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

        foreach ItemMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            ItemMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {   
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }
    else if (ClassIsChildOf(TemplateClass, class'X2AbilityTemplate'))
    {
        CDO = GetCDO();
        AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

        foreach AbilityMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            AbilityMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }
    else if (ClassIsChildOf(TemplateClass, class'X2CharacterTemplate'))
    {
        CDO = GetCDO();
        CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
        foreach CharMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            CharMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }
    else if (ClassIsChildOf(TemplateClass, class'X2StrategyElementTemplate'))
    {
        CDO = GetCDO();
        StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
        foreach StratMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            StratMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }
    else if (ClassIsChildOf(TemplateClass, class'X2SoldierClassTemplate'))
    {

        CDO = GetCDO();
        ClassMgr = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
        foreach ClassMgr.IterateTemplates(IterateTemplate)
        {
            if (!ClassIsChildOf(IterateTemplate.Class, TemplateClass)) continue;

            ClassMgr.FindDataTemplateAllDifficulties(IterateTemplate.DataName, DataTemplates);
            foreach DataTemplates(DataTemplate)
            {
                CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
            }
        }
    }    
}

static private function ModifyTemplateAllDiff(name TemplateName, class TemplateClass, delegate<ModifyTemplate> ModifyTemplateFn)
{
    local X2DataTemplate                           DataTemplate;
    local array<X2DataTemplate>                    DataTemplates;
    local X2DLCInfo_WOTCArchipelago                CDO;

    local X2ItemTemplateManager                    ItemMgr;
    local X2AbilityTemplateManager                 AbilityMgr;
    local X2CharacterTemplateManager               CharMgr;
    local X2StrategyElementTemplateManager         StratMgr;
    local X2SoldierClassTemplateManager            ClassMgr;

    if (ClassIsChildOf(TemplateClass, class'X2ItemTemplate'))
    {
        ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();
        ItemMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else if (ClassIsChildOf(TemplateClass, class'X2AbilityTemplate'))
    {
        AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
        AbilityMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else if (ClassIsChildOf(TemplateClass, class'X2CharacterTemplate'))
    {
        CharMgr = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();
        CharMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else if (ClassIsChildOf(TemplateClass, class'X2StrategyElementTemplate'))
    {
        StratMgr = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
        StratMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else if (ClassIsChildOf(TemplateClass, class'X2SoldierClassTemplate'))
    {
        ClassMgr = class'X2SoldierClassTemplateManager'.static.GetSoldierClassTemplateManager();
        ClassMgr.FindDataTemplateAllDifficulties(TemplateName, DataTemplates);
    }
    else return;

    CDO = GetCDO();
    foreach DataTemplates(DataTemplate)
    {
        CDO.CallModifyTemplateFn(ModifyTemplateFn, DataTemplate);
    }
}

static private function X2DLCInfo_WOTCArchipelago GetCDO()
{
    return X2DLCInfo_WOTCArchipelago(class'XComEngine'.static.GetClassDefaultObjectByName(default.Class.Name));
}

protected function CallModifyTemplateFn(delegate<ModifyTemplate> ModifyTemplateFn, X2DataTemplate DataTemplate)
{
    ModifyTemplateFn(DataTemplate);
}
