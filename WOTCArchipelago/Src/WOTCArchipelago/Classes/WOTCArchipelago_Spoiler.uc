class WOTCArchipelago_Spoiler extends Object config(WOTCArchipelago_Spoiler);

struct native SpoilerEntry
{
	var name Location;
	var string Item;
	var string Player;
	var string Game;
	var bool bProgression;
	var bool bUseful;
	var bool bTrap;
};

var config array<SpoilerEntry> Spoiler;

static function bool GetSpoilerEntryByLocation(name LocationName, out SpoilerEntry Entry)
{
	foreach default.Spoiler(Entry)
		if (Entry.Location == LocationName)
			return true;

	return false;
}
