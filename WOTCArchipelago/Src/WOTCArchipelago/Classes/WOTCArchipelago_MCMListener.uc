class WOTCArchipelago_MCMListener extends UIScreenListener config(WOTCArchipelago_Settings);

var localized string strMenuPageTitle;
var localized string strSettingsPageTitle;

var localized string strGroupGeneralTitle;
var localized string strGroupReducedCampaignDuration;
var localized string strGroupCampaignCompletionRequirements;
var localized string strGroupMiscellaneous;

`include(WOTCArchipelago/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(WOTCArchipelago/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

// Enables debug logging to /Documents/My Games/XCOM2 War of the Chosen/XComGame/Logs/Launch.log
`MCM_API_CheckboxVars(DEBUG_LOGGING)

// Port of the local proxy
`MCM_API_SliderVars(PROXY_PORT, int)

// Skip certain time-consuming missions
`MCM_API_CheckboxVars(SKIP_SUPPLY_RAIDS)
`MCM_API_CheckboxVars(SKIP_COUNCIL_MISSIONS)
`MCM_API_CheckboxVars(SKIP_FACTION_MISSIONS)

// Disarm certain time-consuming covert op risks
`MCM_API_CheckboxVars(DISARM_AMBUSH_RISK)
`MCM_API_CheckboxVars(DISARM_CAPTURE_RISK)

// Skipped supply raid rewards
`MCM_API_SliderVars(SKIP_RAID_REWARD_MULT_BASE, float)
`MCM_API_SliderVars(SKIP_RAID_REWARD_MULT_ERR, float)

// Increase XP gain
`MCM_API_SliderVars(EXTRA_XP_MULT, float)

// Increase corpse gain
`MCM_API_SliderVars(EXTRA_CORPSES, int)

// Set story objective completion requirements
`MCM_API_CheckboxVars(REQ_PSI_GATE_OBJ)
`MCM_API_CheckboxVars(REQ_STASIS_SUIT_OBJ)
`MCM_API_CheckboxVars(REQ_AVATAR_CORPSE_OBJ)

// Disable day 1 traps
`MCM_API_CheckboxVars(NO_STARTING_TRAPS)

// MCM version
var config int CFG_VERSION;


`MCM_API_CheckboxFns(DEBUG_LOGGING)

`MCM_API_SliderFns(PROXY_PORT, int)

`MCM_API_CheckboxFns(SKIP_SUPPLY_RAIDS)
`MCM_API_CheckboxFns(SKIP_COUNCIL_MISSIONS)
`MCM_API_CheckboxFns(SKIP_FACTION_MISSIONS)

`MCM_API_CheckboxFns(DISARM_AMBUSH_RISK)
`MCM_API_CheckboxFns(DISARM_CAPTURE_RISK)

`MCM_API_SliderFns(SKIP_RAID_REWARD_MULT_BASE, float)
`MCM_API_SliderFns(SKIP_RAID_REWARD_MULT_ERR, float)

`MCM_API_SliderFns(EXTRA_XP_MULT, float)

`MCM_API_SliderFns(EXTRA_CORPSES, int)

`MCM_API_CheckboxFns(NO_STARTING_TRAPS)

`MCM_API_CheckboxFns(REQ_PSI_GATE_OBJ)
`MCM_API_CheckboxFns(REQ_STASIS_SUIT_OBJ)
`MCM_API_CheckboxFns(REQ_AVATAR_CORPSE_OBJ)

`MCM_API_VersionChecker(VERSION)


event OnInit(UIScreen Screen)
{
	if (MCM_API(Screen) != none)
	{
		`MCM_API_Register(Screen, ClientModCallback);
	}
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsPage Page;
    local MCM_API_SettingsGroup GroupGeneral;
	local MCM_API_SettingsGroup GroupDuration;
	local MCM_API_SettingsGroup GroupCompletion;
	local MCM_API_SettingsGroup GroupMiscellaneous;
    
    LoadSavedSettings();
    
    Page = ConfigAPI.NewSettingsPage(default.strMenuPageTitle);
    Page.SetPageTitle(default.strSettingsPageTitle);
    Page.SetSaveHandler(SaveButtonClicked);
	Page.EnableResetButton(ResetButtonClicked);
	
    GroupGeneral = Page.AddGroup('General', default.strGroupGeneralTitle);
	`MCM_API_AddCheckbox(GroupGeneral, DEBUG_LOGGING);
	`MCM_API_AddSlider(GroupGeneral, PROXY_PORT, 20028, 25028, 100);

	GroupDuration = Page.AddGroup('Duration', default.strGroupReducedCampaignDuration);
    `MCM_API_AddCheckbox(GroupDuration, SKIP_SUPPLY_RAIDS);
	`MCM_API_AddCheckbox(GroupDuration, SKIP_COUNCIL_MISSIONS);
	`MCM_API_AddCheckbox(GroupDuration, SKIP_FACTION_MISSIONS);
	`MCM_API_AddCheckbox(GroupDuration, DISARM_AMBUSH_RISK);
	`MCM_API_AddCheckbox(GroupDuration, DISARM_CAPTURE_RISK);
	`MCM_API_AddSlider(GroupDuration, SKIP_RAID_REWARD_MULT_BASE, 0.0f, 1.0f, 0.05f);
	`MCM_API_AddSlider(GroupDuration, SKIP_RAID_REWARD_MULT_ERR, 0.0f, 1.0f, 0.05f);
	`MCM_API_AddSlider(GroupDuration, EXTRA_XP_MULT, 0.0f, 2.0f, 0.05f);
	`MCM_API_AddSlider(GroupDuration, EXTRA_CORPSES, 0, 5, 1);

	GroupCompletion = Page.AddGroup('Completion', default.strGroupCampaignCompletionRequirements);
	`MCM_API_AddCheckbox(GroupCompletion, REQ_PSI_GATE_OBJ);
	`MCM_API_AddCheckbox(GroupCompletion, REQ_STASIS_SUIT_OBJ);
	`MCM_API_AddCheckbox(GroupCompletion, REQ_AVATAR_CORPSE_OBJ);

	GroupMiscellaneous = Page.AddGroup('Miscellaneous', default.strGroupMiscellaneous);
	`MCM_API_ADDCheckbox(GroupMiscellaneous, NO_STARTING_TRAPS);

    Page.ShowSettings();
}

simulated function LoadSavedSettings()
{
	`MCM_API_LoadSetting(DEBUG_LOGGING);

	`MCM_API_LoadSetting(PROXY_PORT);

	`MCM_API_LoadSetting(SKIP_SUPPLY_RAIDS);
	`MCM_API_LoadSetting(SKIP_COUNCIL_MISSIONS);
	`MCM_API_LoadSetting(SKIP_FACTION_MISSIONS);

	`MCM_API_LoadSetting(DISARM_AMBUSH_RISK);
	`MCM_API_LoadSetting(DISARM_CAPTURE_RISK);

	`MCM_API_LoadSetting(SKIP_RAID_REWARD_MULT_BASE);
	`MCM_API_LoadSetting(SKIP_RAID_REWARD_MULT_ERR);

	`MCM_API_LoadSetting(EXTRA_XP_MULT);

	`MCM_API_LoadSetting(EXTRA_CORPSES);

	`MCM_API_LoadSetting(REQ_PSI_GATE_OBJ);
	`MCM_API_LoadSetting(REQ_STASIS_SUIT_OBJ);
	`MCM_API_LoadSetting(REQ_AVATAR_CORPSE_OBJ);

	`MCM_API_LoadSetting(NO_STARTING_TRAPS);
}

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	`MCM_API_RestoreDefault(DEBUG_LOGGING);

	`MCM_API_RestoreDefault(PROXY_PORT);

	`MCM_API_RestoreDefault(SKIP_SUPPLY_RAIDS);
	`MCM_API_RestoreDefault(SKIP_COUNCIL_MISSIONS);
	`MCM_API_RestoreDefault(SKIP_FACTION_MISSIONS);

	`MCM_API_RestoreDefault(DISARM_AMBUSH_RISK);
	`MCM_API_RestoreDefault(DISARM_CAPTURE_RISK);

	`MCM_API_RestoreDefault(SKIP_RAID_REWARD_MULT_BASE);
	`MCM_API_RestoreDefault(SKIP_RAID_REWARD_MULT_ERR);

	`MCM_API_RestoreDefault(EXTRA_XP_MULT);

	`MCM_API_RestoreDefault(EXTRA_CORPSES);

	`MCM_API_RestoreDefault(REQ_PSI_GATE_OBJ);
	`MCM_API_RestoreDefault(REQ_STASIS_SUIT_OBJ);
	`MCM_API_RestoreDefault(REQ_AVATAR_CORPSE_OBJ);

	`MCM_API_RestoreDefault(NO_STARTING_TRAPS);
}

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    CFG_VERSION = `MCM_CH_GetCompositeVersion();
    SaveConfig();
}

defaultproperties
{
    ScreenClass = none;
}
