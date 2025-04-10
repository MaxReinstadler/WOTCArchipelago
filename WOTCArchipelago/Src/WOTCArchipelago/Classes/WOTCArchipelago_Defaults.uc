// Helper class for accessing debug values
class  WOTCArchipelago_Defaults extends Object config(WOTCArchipelago_Defaults);

// Enables debug logging to /Documents/My Games/XCOM2 War of the Chosen/XComGame/Logs/Launch.log
var config bool DEF_DEBUG_LOGGING;

// Port of the local proxy
var config int DEF_PROXY_PORT;

// Skip certain time-consuming missions
var config bool DEF_SKIP_SUPPLY_RAIDS;
var config bool DEF_SKIP_COUNCIL_MISSIONS;
var config bool DEF_SKIP_FACTION_MISSIONS;

// Disarm certain time-consuming covert op risks
var config bool DEF_DISARM_AMBUSH_RISK;
var config bool DEF_DISARM_CAPTURE_RISK;

// Skipped supply raid rewards
var config float DEF_SKIP_RAID_REWARD_MULT_BASE;
var config float DEF_SKIP_RAID_REWARD_MULT_ERR;

// Increase XP gain
var config float DEF_EXTRA_XP_MULT;

// Increase corpse gain
var config int DEF_EXTRA_CORPSES;

// Set story objective completion requirements
var config bool DEF_REQ_PSI_GATE_OBJ;
var config bool DEF_REQ_STASIS_SUIT_OBJ;
var config bool DEF_REQ_AVATAR_CORPSE_OBJ;

// Disable day 1 traps
var config bool DEF_NO_STARTING_TRAPS;

// MCM version
var config int DEF_VERSION;
