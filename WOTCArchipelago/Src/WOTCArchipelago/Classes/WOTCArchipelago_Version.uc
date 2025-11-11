class WOTCArchipelago_Version extends Object config(WOTCArchipelago);

var config string ModVersion;
var config string MinimumClientVersion;
var config string ClientVersion;
var config string MinimumModVersion;

static function string GetModVersion()
{
	return "WOTCArchipelago " $ default.ModVersion;
}

static function bool CanCheckVersion()
{
	return !(default.ClientVersion == "" || default.MinimumModVersion == "");
}

static function bool IsVersionValid(string Version, string MinimumVersion)
{
	local array<string>		VersionValues;
	local array<string>		MinimumVersionValues;
	local int				Idx;

	VersionValues = SplitString(Version, ".", true);
	MinimumVersionValues = SplitString(MinimumVersion, ".", true);

	for (Idx = 0; Idx < Min(VersionValues.Length, MinimumVersionValues.Length); Idx++)
	{
		if (VersionValues[Idx] > MinimumVersionValues[Idx]) return true;
		else if (VersionValues[Idx] < MinimumVersionValues[Idx]) return false;
	}

	// All values are equal
	return true;
}

static function bool CheckVersion(optional bool bDebug = true)
{
	if (bDebug) `AMLOG(GetModVersion() $ " / Client " $ default.ClientVersion);

	if (!CanCheckVersion())
	{
		if (bDebug)
			`ERROR("Client version not set, connect to the server through the client and restart the game.");
		return false;
	}

	if (!IsVersionValid(default.ModVersion, default.MinimumModVersion))
	{
		if (bDebug)
			`ERROR("Client version " $ default.ClientVersion $ " requires at least mod version " $ default.MinimumModVersion);
		return false;
	}

	if (!IsVersionValid(default.ClientVersion, default.MinimumClientVersion))
	{
		if (bDebug)
			`ERROR("Mod version " $ default.ModVersion $ " requires at least client version " $ default.MinimumClientVersion);
		return false;
	}

	return true;
}
