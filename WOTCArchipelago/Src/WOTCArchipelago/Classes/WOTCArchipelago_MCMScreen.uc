class WOTCArchipelago_MCMScreen extends Object config(WOTCArchipelago_Settings);


var localized string strMenuPageTitle;
var localized string strSettingsPageTitle;

var localized string strGroupGeneralTitle;
var localized string strGroupReducedCampaignDuration;
var localized string strGroupTraps;


`include(WOTCArchipelago/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(WOTCArchipelago/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)


// Unique AP generation ID set by the client
var config string CFG_AP_GEN_ID;

// Enable debug logging to /Documents/My Games/XCOM2 War of the Chosen/XComGame/Logs/Launch.log
`MCM_API_CheckboxVars(DEBUG_LOGGING);

// Skip certain time-consuming missions
`MCM_API_CheckboxVars(SKIP_SUPPLY_RAIDS);
`MCM_API_CheckboxVars(SKIP_COUNCIL_MISSIONS);
`MCM_API_CheckboxVars(SKIP_FACTION_MISSIONS);

// Disable certain time-consuming covert op risks
`MCM_API_CheckboxVars(DISABLE_AMBUSH_RISK);
`MCM_API_CheckboxVars(DISABLE_CAPTURE_RISK);

// Skipped supply raid rewards
`MCM_API_SliderVars(SKIP_RAID_REWARD_MULT_BASE, float);
`MCM_API_SliderVars(SKIP_RAID_REWARD_MULT_ERR, float);

// Increase XP gain
`MCM_API_SliderVars(EXTRA_XP_MULT, float);

// Increase corpse gain
`MCM_API_SliderVars(EXTRA_CORPSES, int);

// Disable day 1 traps
`MCM_API_CheckboxVars(NO_STARTING_TRAPS);

// MCM version
var config int CFG_VERSION;


`MCM_API_CheckboxFns(DEBUG_LOGGING);

`MCM_API_CheckboxFns(SKIP_SUPPLY_RAIDS);
`MCM_API_CheckboxFns(SKIP_COUNCIL_MISSIONS);
`MCM_API_CheckboxFns(SKIP_FACTION_MISSIONS);

`MCM_API_CheckboxFns(DISABLE_AMBUSH_RISK);
`MCM_API_CheckboxFns(DISABLE_CAPTURE_RISK);

`MCM_API_SliderFns(SKIP_RAID_REWARD_MULT_BASE, float);
`MCM_API_SliderFns(SKIP_RAID_REWARD_MULT_ERR, float);

`MCM_API_SliderFns(EXTRA_XP_MULT, float);

`MCM_API_SliderFns(EXTRA_CORPSES, int);

`MCM_API_CheckboxFns(NO_STARTING_TRAPS);

`MCM_API_VersionChecker(VERSION);


event OnInit(UIScreen Screen)
{
	`MCM_API_Register(Screen, ClientModCallback);
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsPage Page;
    local MCM_API_SettingsGroup GroupGeneral;
	local MCM_API_SettingsGroup GroupDuration;
	local MCM_API_SettingsGroup GroupTraps;
    
	LoadSavedSettings();
    
    Page = ConfigAPI.NewSettingsPage(default.strMenuPageTitle);
    Page.SetPageTitle(default.strSettingsPageTitle);
    Page.SetSaveHandler(SaveButtonClicked);
	Page.EnableResetButton(ResetButtonClicked);
	
    GroupGeneral = Page.AddGroup('General', default.strGroupGeneralTitle);
	`MCM_API_AddCheckbox(GroupGeneral, DEBUG_LOGGING);

	GroupDuration = Page.AddGroup('Duration', default.strGroupReducedCampaignDuration);
    `MCM_API_AddCheckbox(GroupDuration, SKIP_SUPPLY_RAIDS);
	`MCM_API_AddCheckbox(GroupDuration, SKIP_COUNCIL_MISSIONS);
	`MCM_API_AddCheckbox(GroupDuration, SKIP_FACTION_MISSIONS);
	`MCM_API_AddCheckbox(GroupDuration, DISABLE_AMBUSH_RISK);
	`MCM_API_AddCheckbox(GroupDuration, DISABLE_CAPTURE_RISK);
	`MCM_API_AddSlider(GroupDuration, SKIP_RAID_REWARD_MULT_BASE, 0.0f, 1.0f, 0.05f);
	`MCM_API_AddSlider(GroupDuration, SKIP_RAID_REWARD_MULT_ERR, 0.0f, 1.0f, 0.05f);
	`MCM_API_AddSlider(GroupDuration, EXTRA_XP_MULT, 0.0f, 2.0f, 0.05f);
	`MCM_API_AddSlider(GroupDuration, EXTRA_CORPSES, 0, 5, 1);

	GroupTraps = Page.AddGroup('Traps', default.strGroupTraps);
	`MCM_API_AddCheckbox(GroupTraps, NO_STARTING_TRAPS);

    Page.ShowSettings();
}

simulated function LoadSavedSettings()
{
	`MCM_API_LoadSetting(DEBUG_LOGGING);

	`MCM_API_LoadSetting(SKIP_SUPPLY_RAIDS);
	`MCM_API_LoadSetting(SKIP_COUNCIL_MISSIONS);
	`MCM_API_LoadSetting(SKIP_FACTION_MISSIONS);

	`MCM_API_LoadSetting(DISABLE_AMBUSH_RISK);
	`MCM_API_LoadSetting(DISABLE_CAPTURE_RISK);

	`MCM_API_LoadSetting(SKIP_RAID_REWARD_MULT_BASE);
	`MCM_API_LoadSetting(SKIP_RAID_REWARD_MULT_ERR);

	`MCM_API_LoadSetting(EXTRA_XP_MULT);

	`MCM_API_LoadSetting(EXTRA_CORPSES);

	`MCM_API_LoadSetting(NO_STARTING_TRAPS);
}

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	`MCM_API_RestoreDefault(DEBUG_LOGGING);

	`MCM_API_RestoreDefault(SKIP_SUPPLY_RAIDS);
	`MCM_API_RestoreDefault(SKIP_COUNCIL_MISSIONS);
	`MCM_API_RestoreDefault(SKIP_FACTION_MISSIONS);

	`MCM_API_RestoreDefault(DISABLE_AMBUSH_RISK);
	`MCM_API_RestoreDefault(DISABLE_CAPTURE_RISK);

	`MCM_API_RestoreDefault(SKIP_RAID_REWARD_MULT_BASE);
	`MCM_API_RestoreDefault(SKIP_RAID_REWARD_MULT_ERR);

	`MCM_API_RestoreDefault(EXTRA_XP_MULT);

	`MCM_API_RestoreDefault(EXTRA_CORPSES);

	`MCM_API_RestoreDefault(NO_STARTING_TRAPS);
}

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    CFG_VERSION = `MCM_CH_GetCompositeVersion();
    SaveConfig();
}

static private function bool ShouldLoadAPDefaults()
{
	if (class'WOTCArchipelago_Defaults'.default.DEF_AP_GEN_ID == "")
	{
		`ERROR("AP generation ID not set, connect to the server through the client and restart the game.");
		return false;
	}

	return (class'WOTCArchipelago_Defaults'.default.DEF_AP_GEN_ID != default.CFG_AP_GEN_ID);
}

static function LoadAndSaveAPDefaults()
{
	if (!ShouldLoadAPDefaults()) return;

	`MCM_API_LoadAPDefault(AP_GEN_ID);

	default.CFG_DEBUG_LOGGING = `APCFG(DEBUG_LOGGING);

	`MCM_API_LoadAPDefault(SKIP_SUPPLY_RAIDS);
	`MCM_API_LoadAPDefault(SKIP_COUNCIL_MISSIONS);
	`MCM_API_LoadAPDefault(SKIP_FACTION_MISSIONS);

	`MCM_API_LoadAPDefault(DISABLE_AMBUSH_RISK);
	`MCM_API_LoadAPDefault(DISABLE_CAPTURE_RISK);

	`MCM_API_LoadAPDefault(SKIP_RAID_REWARD_MULT_BASE);
	`MCM_API_LoadAPDefault(SKIP_RAID_REWARD_MULT_ERR);

	`MCM_API_LoadAPDefault(EXTRA_XP_MULT);

	`MCM_API_LoadAPDefault(EXTRA_CORPSES);

	`MCM_API_LoadAPDefault(NO_STARTING_TRAPS);

	default.CFG_VERSION = `MCM_CH_GetCompositeVersion();
	class'WOTCArchipelago_MCMScreen'.static.StaticSaveConfig();
}
