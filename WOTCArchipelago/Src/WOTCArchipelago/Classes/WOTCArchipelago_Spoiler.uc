class WOTCArchipelago_Spoiler extends Object config(WOTCArchipelago_Spoiler);

struct native SpoilerEntry
{
	var name Location;
	var name Item;
	var name Player;
	var name Game;
	var bool bProgression;
	var bool bUseful;
	var bool bTrap;
};

var config array<SpoilerEntry> Spoiler;
