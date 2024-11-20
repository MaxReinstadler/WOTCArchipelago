class X2StrategyElement_APRewards extends X2StrategyElement_XpackRewards
	dependson(X2RewardTemplate);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Rewards;

	// Chosen Hunt Covert Action Replacement Reward
	Rewards.AddItem(CreateAPChosenHuntRewardTemplate());

	return Rewards;
}

static function X2DataTemplate CreateAPChosenHuntRewardTemplate()
{
	local X2RewardTemplate Template;

	`CREATE_X2Reward_TEMPLATE(Template, 'Reward_APChosenHunt');
	Template.IsRewardAvailableFn = IsAPChosenHuntRewardAvailable;
	return Template;
}

static function bool IsAPChosenHuntRewardAvailable(optional XComGameState NewGameState, optional StateObjectReference AuxRef)
{
	local XComGameState_ResistanceFaction	FactionState;
	local XComGameState_AdventChosen		ChosenState;

	FactionState = GetFactionState(NewGameState, AuxRef);
	if (FactionState != none)
	{
		ChosenState = FactionState.GetRivalChosen();
		if (FactionState.bMetXCom && ChosenState.bMetXCom)
		{
			return true;
		}
	}

	return false;
}
