class X2Item_APCounterResources extends X2Item;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> APCounterItems;

	// Items Received
	APCounterItems.AddItem(CreateCounterTemplate('ItemsReceivedStrategy'));
	APCounterItems.AddItem(CreateCounterTemplate('ItemsReceivedTactical'));

	// Story Objectives Completed
	APCounterItems.AddItem(CreateCounterTemplate('PsiGateObjectiveCompleted'));
	APCounterItems.AddItem(CreateCounterTemplate('StasisSuitObjectiveCompleted'));
	APCounterItems.AddItem(CreateCounterTemplate('AvatarCorpseObjectiveCompleted'));

	return APCounterItems;
}

static private function X2DataTemplate CreateCounterTemplate(name TemplateName)
{
	local X2ItemTemplate Template;

	`CREATE_X2TEMPLATE(class'X2ItemTemplate', Template, TemplateName);
	Template.CanBeBuilt = false;
	Template.HideInInventory = true;
	Template.ItemCat = 'resource';

	return Template;
}