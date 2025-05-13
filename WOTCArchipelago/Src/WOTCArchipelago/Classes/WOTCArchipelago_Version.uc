class WOTCArchipelago_Version extends Object config(WOTCArchipelago);

var config string ModVersion;
var config string ClientVersion;
var config string RecModVersion;

static function string GetModVersion()
{
	return "WOTCArchipelago " $ default.ModVersion;
}

static function CheckVersion()
{
	local array<string>		ModVersionValues;
	local array<string>		RecModVersions;
	local array<string>		RecModVersionValues;
	local bool				bValid;
	local bool				bValidVersion;
	local int				Idx;
	local int				Jdx;

	if (default.ClientVersion == "" || default.RecModVersion == "")
	{
		`ERROR("Client version not set, connect to the server through the client and restart the game.");
		return;
	}

	ModVersionValues = SplitString(default.ModVersion, ".", true);
	RecModVersions = SplitString(default.RecModVersion, "/", true);

	bValid = false;
	for (Idx = 0; Idx < RecModVersions.Length; Idx++)
	{
		RecModVersionValues = SplitString(RecModVersions[Idx], ".", true);

		bValidVersion = true;
		for (Jdx = 0; Jdx < RecModVersionValues.Length; Jdx++)
			bValidVersion = ModVersionValues[Jdx] == RecModVersionValues[Jdx] || RecModVersionValues[Jdx] == "x";

		bValid = bValid || bValidVersion;
		if (bValid) break;
	}

	if (!bValid)
		`ERROR("Incompatible client (" $ default.ClientVersion $ ") and mod (" $ default.ModVersion $ ") versions.");
	else
		`AMLOG(GetModVersion() $ " / Client " $ default.ClientVersion);
}
