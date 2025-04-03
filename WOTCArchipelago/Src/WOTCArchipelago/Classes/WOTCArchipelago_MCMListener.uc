class WOTCArchipelago_MCMListener extends UIScreenListener config(WOTCArchipelago_Settings);

`include(WOTCArchipelago/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(WOTCArchipelago/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

// Enables debug logging to /Documents/My Games/XCOM2 War of the Chosen/XComGame/Logs/Launch.log
var config bool CFG_DEBUG_LOGGING;

// Port of the local proxy
var config int CFG_PROXY_PORT;

// Skip certain time-consuming missions
var config bool CFG_SKIP_SUPPLY_RAIDS;
var config bool CFG_SKIP_COUNCIL_MISSIONS;
var config bool CFG_SKIP_FACTION_MISSIONS;

// Disarm certain time-consuming covert op risks
var config bool CFG_DISARM_AMBUSH_RISK;
var config bool CFG_DISARM_CAPTURE_RISK;

// Increase XP gain
var config float CFG_EXTRA_XP_MULT;

// Increase corpse gain
var config int CFG_EXTRA_CORPSES;

// Set story objective completion requirements
var config bool CFG_REQ_PSI_GATE_OBJ;
var config bool CFG_REQ_STASIS_SUIT_OBJ;
var config bool CFG_REQ_AVATAR_CORPSE_OBJ;

// Disable day 1 traps
var config bool CFG_NO_STARTING_TRAPS;

var localized string strMenuPageTitle;
var localized string strSettingsPageTitle;

var localized string strGroupGeneralTitle;
var localized string strSettingDebugLoggingName;
var localized string strSettingDebugLoggingDetails;
var localized string strSettingProxyPortName;
var localized string strSettingProxyPortDetails;

var localized string strGroupReducedCampaignDuration;
var localized string strSettingSkipSupplyRaidsName;
var localized string strSettingSkipSupplyRaidsDetails;
var localized string strSettingSkipCouncilMissionsName;
var localized string strSettingSkipCouncilMissionsDetails;
var localized string strSettingSkipResistanceOpsName;
var localized string strSettingSkipResistanceOpsDetails;
var localized string strSettingDisarmAmbushName;
var localized string strSettingDisarmAmbushDetails;
var localized string strSettingDisarmCaptureName;
var localized string strSettingDisarmCaptureDetails;
var localized string strSettingIncreaseXPName;
var localized string strSettingIncreaseXPDetails;
var localized string strSettingIncreaseCorpseGainName;
var localized string strSettingIncreaseCorpseGainDetails;

var localized string strGroupCampaignCompletionRequirements;
var localized string strSettingPsiGateName;
var localized string strSettingPsiGateDetails;
var localized string strSettingStasisSuitName;
var localized string strSettingStasisSuitDetails;
var localized string strSettingAvatarCorpseName;
var localized string strSettingAvatarCorpseDetails;

var localized string strGroupMiscellaneous;
var localized string strSettingDisableDayOneTrapsName;
var localized string strSettingDisableDayOneTrapsDetails;

// MCM version
var config int CFG_VERSION;


`MCM_API_CheckboxFns(DEBUG_LOGGING)

`MCM_API_SliderFns(PROXY_PORT)

`MCM_API_CheckboxFns(SKIP_SUPPLY_RAIDS)
`MCM_API_CheckboxFns(SKIP_COUNCIL_MISSIONS)
`MCM_API_CheckboxFns(SKIP_FACTION_MISSIONS)

`MCM_API_CheckboxFns(DISARM_AMBUSH_RISK)
`MCM_API_CheckboxFns(DISARM_CAPTURE_RISK)

`MCM_API_FloatSliderFns(EXTRA_XP_MULT)

`MCM_API_SliderFns(EXTRA_CORPSES)

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
    
    GroupGeneral = Page.AddGroup('Group1', default.strGroupGeneralTitle);

	`MCM_API_AddCheckbox(GroupGeneral, DEBUG_LOGGING, default.strSettingDebugLoggingName, default.strSettingDebugLoggingDetails);

	`MCM_API_AddSlider(GroupGeneral, PROXY_PORT, default.strSettingProxyPortName, default.strSettingProxyPortDetails, 20028, 25028, 100);

	GroupDuration = Page.AddGroup('Group2', default.strGroupReducedCampaignDuration);
    
    `MCM_API_AddCheckbox(GroupDuration, SKIP_SUPPLY_RAIDS, default.strSettingSkipSupplyRaidsName, default.strSettingSkipSupplyRaidsDetails);
	`MCM_API_AddCheckbox(GroupDuration, SKIP_COUNCIL_MISSIONS, default.strSettingSkipCouncilMissionsName, default.strSettingSkipCouncilMissionsDetails);
	`MCM_API_AddCheckbox(GroupDuration, SKIP_FACTION_MISSIONS, default.strSettingSkipResistanceOpsName, default.strSettingSkipResistanceOpsDetails);

	`MCM_API_AddCheckbox(GroupDuration, DISARM_AMBUSH_RISK, default.strSettingDisarmAmbushName, default.strSettingDisarmAmbushDetails);
	`MCM_API_AddCheckbox(GroupDuration, DISARM_CAPTURE_RISK, default.strSettingDisarmCaptureName, default.strSettingDisarmCaptureDetails);

	`MCM_API_AddSlider(GroupDuration, EXTRA_XP_MULT, default.strSettingIncreaseXPName, default.strSettingIncreaseXPDetails, 0.0f, 2.0f, 0.05f);

	`MCM_API_AddSlider(GroupDuration, EXTRA_CORPSES, default.strSettingIncreaseCorpseGainName, default.strSettingIncreaseCorpseGainDetails, 0, 5, 1);

	GroupCompletion = Page.AddGroup('Group3', default.strGroupCampaignCompletionRequirements);

	`MCM_API_AddCheckbox(GroupCompletion, REQ_PSI_GATE_OBJ, default.strSettingPsiGateName, default.strSettingPsiGateDetails);
	`MCM_API_AddCheckbox(GroupCompletion, REQ_STASIS_SUIT_OBJ, default.strSettingStasisSuitName, default.strSettingStasisSuitDetails);
	`MCM_API_AddCheckbox(GroupCompletion, REQ_AVATAR_CORPSE_OBJ, default.strSettingAvatarCorpseName, default.strSettingAvatarCorpseDetails);

	GroupMiscellaneous = Page.AddGroup('Group4', default.strGroupMiscellaneous);

	`MCM_API_ADDCheckbox(GroupMiscellaneous, NO_STARTING_TRAPS, default.strSettingDisableDayOneTrapsName, default.strSettingDisableDayOneTrapsDetails);
    
    Page.ShowSettings();
}

simulated function LoadSavedSettings()
{
	CFG_DEBUG_LOGGING = `APCFG(DEBUG_LOGGING);

	CFG_PROXY_PORT = `APCFG(PROXY_PORT);

    CFG_SKIP_SUPPLY_RAIDS = `APCFG(SKIP_SUPPLY_RAIDS);
	CFG_SKIP_COUNCIL_MISSIONS = `APCFG(SKIP_COUNCIL_MISSIONS);
	CFG_SKIP_FACTION_MISSIONS = `APCFG(SKIP_FACTION_MISSIONS);

	CFG_DISARM_AMBUSH_RISK = `APCFG(DISARM_AMBUSH_RISK);
	CFG_DISARM_CAPTURE_RISK = `APCFG(DISARM_CAPTURE_RISK);

	CFG_EXTRA_XP_MULT = `APCFG(EXTRA_XP_MULT);

	CFG_EXTRA_CORPSES = `APCFG(EXTRA_CORPSES);

	CFG_REQ_PSI_GATE_OBJ = `APCFG(REQ_PSI_GATE_OBJ);
	CFG_REQ_STASIS_SUIT_OBJ = `APCFG(REQ_STASIS_SUIT_OBJ);
	CFG_REQ_AVATAR_CORPSE_OBJ = `APCFG(REQ_AVATAR_CORPSE_OBJ);

	CFG_NO_STARTING_TRAPS = `APCFG(NO_STARTING_TRAPS);
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
