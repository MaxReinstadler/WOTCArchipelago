class WOTCArchipelago_Version extends Object config(WOTCArchipelago);

var config string ModVersion;
var config string ClientVersion;
var config string RecModVersion;

static function string GetModVersion()
{
	return "WOTCArchipelago " $ default.ModVersion;
}

static function bool CanCheckVersion()
{
	return !(default.ClientVersion == "" || default.RecModVersion == "");
}

static function bool CheckVersion()
{
	local array<string>		ModVersionValues;
	local array<string>		RecModVersions;
	local array<string>		RecModVersionValues;
	local bool				bValid;
	local int				Idx;
	local int				Jdx;

	if (!CanCheckVersion())
	{
		`ERROR("Client version not set, connect to the server through the client and restart the game.");
		return false;
	}

	ModVersionValues = SplitString(default.ModVersion, ".", true);
	RecModVersions = SplitString(default.RecModVersion, "/", true);

	bValid = false;
	for (Idx = 0; Idx < RecModVersions.Length; Idx++)
	{
		RecModVersionValues = SplitString(RecModVersions[Idx], ".", true);

		for (Jdx = 0; Jdx < Min(ModVersionValues.Length, RecModVersionValues.Length); Jdx++)
		{
			bValid = ModVersionValues[Jdx] == RecModVersionValues[Jdx] || RecModVersionValues[Jdx] == "x";
			if (!bValid) break;
		}

		if (bValid) break;
	}

	if (!bValid)
		`ERROR("Incompatible client (" $ default.ClientVersion $ ") and mod (" $ default.ModVersion $ ") versions.");
	else
		`AMLOG(GetModVersion() $ " / Client " $ default.ClientVersion);

	return bValid;
}
