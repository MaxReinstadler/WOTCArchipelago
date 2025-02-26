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
    
    LoadSavedSettings();
    
    Page = ConfigAPI.NewSettingsPage("X2WOTC Archipelago");
    Page.SetPageTitle("XCOM 2 WOTC Archipelago");
    Page.SetSaveHandler(SaveButtonClicked);
    
    GroupGeneral = Page.AddGroup('Group1', "General");

	`MCM_API_AddCheckbox(GroupGeneral, DEBUG_LOGGING, "Debug Logging", "Enables debug logging to Launch.log.");

	`MCM_API_AddSlider(GroupGeneral, PROXY_PORT, "Proxy Port", "Sets the port of the local proxy.", 20028, 25028, 100);

	GroupDuration = Page.AddGroup('Group2', "Reduced Campaign Duration");
    
    `MCM_API_AddCheckbox(GroupDuration, SKIP_SUPPLY_RAIDS, "Skip Supply Raids", "Automatically skips supply raids.");
	`MCM_API_AddCheckbox(GroupDuration, SKIP_COUNCIL_MISSIONS, "Skip Council Missions", "Automatically skips council missions.");
	`MCM_API_AddCheckbox(GroupDuration, SKIP_FACTION_MISSIONS, "Skip Resistance Ops", "Automatically skips resistance ops.");

	`MCM_API_AddCheckbox(GroupDuration, DISARM_AMBUSH_RISK, "Disarm Ambush Risk", "Disables effects of covert op ambush risk.");
	`MCM_API_AddCheckbox(GroupDuration, DISARM_CAPTURE_RISK, "Disarm Capture Risk", "Disables effects of covert op soldier capture risk.");

	`MCM_API_AddSlider(GroupDuration, EXTRA_XP_MULT, "Increase XP Gain", "All soldiers passively gain extra XP on missions.", 0.0f, 2.0f, 0.05f);

	`MCM_API_AddSlider(GroupDuration, EXTRA_CORPSES, "Increase Corpse Gain", "Gain additional corpses for each enemy killed.", 0, 5, 1);

	GroupCompletion = Page.AddGroup('Group3', "Campaign Completion Requirements");

	`MCM_API_AddCheckbox(GroupCompletion, REQ_PSI_GATE_OBJ, "Require Psi Gate Objective", "Final mission requires completion of psi gate research to unlock.");
	`MCM_API_AddCheckbox(GroupCompletion, REQ_STASIS_SUIT_OBJ, "Require Stasis Suit Objective", "Final mission requires completion of stasis suit research to unlock.");
	`MCM_API_AddCheckbox(GroupCompletion, REQ_AVATAR_CORPSE_OBJ, "Require Avatar Corpse Objective", "Final mission requires acquisition of avatar corpse to unlock.");
    
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
