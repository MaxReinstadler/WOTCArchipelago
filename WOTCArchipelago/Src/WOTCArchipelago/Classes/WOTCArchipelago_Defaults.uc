// Helper class for accessing debug values
class WOTCArchipelago_Defaults extends Object config(WOTCArchipelago);

// Unique AP generation ID set by the client
var config string DEF_AP_GEN_ID;

// Enable debug logging to /Documents/My Games/XCOM2 War of the Chosen/XComGame/Logs/Launch.log
var config bool DEF_DEBUG_LOGGING;

// Hint research projects
var config bool DEF_HINT_TECH_LOC_PART;
var config bool DEF_HINT_TECH_LOC_FULL;

// Skip certain time-consuming missions
var config bool DEF_SKIP_SUPPLY_RAIDS;
var config bool DEF_SKIP_COUNCIL_MISSIONS;
var config bool DEF_SKIP_FACTION_MISSIONS;

// Disable certain time-consuming covert op risks
var config bool DEF_DISABLE_AMBUSH_RISK;
var config bool DEF_DISABLE_CAPTURE_RISK;

// Skipped supply raid rewards
var config float DEF_SKIP_RAID_REWARD_MULT_BASE;
var config float DEF_SKIP_RAID_REWARD_MULT_ERR;

// Increase XP gain
var config float DEF_EXTRA_XP_MULT;

// Increase corpse gain
var config int DEF_EXTRA_CORPSES;

// Instant rookie training
var config bool DEF_INSTANT_ROOKIE_TRAINING;

// Disable day 1 traps
var config bool DEF_NO_STARTING_TRAPS;

// MCM version
var config int DEF_VERSION;
