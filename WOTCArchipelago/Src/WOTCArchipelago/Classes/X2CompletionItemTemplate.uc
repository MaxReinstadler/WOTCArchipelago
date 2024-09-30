class X2CompletionItemTemplate extends X2ItemTemplate;

var class						AssociatedClass;
var name						AssociatedTemplateName;

// Completion Item represents Tech
var delegate<TechDelegate>		AssociatedTechDelegate;

delegate TechDelegate(XComGameState NewGameState, XComGameState_Tech TechState);

static function X2CompletionItemTemplate GetCompletionItemTemplate(name TemplateName)
{
	local X2ItemTemplateManager			ItemMgr;
	local X2DataTemplate				IterateTemplate;
	local X2CompletionItemTemplate		CompletionItemTemplate;

	ItemMgr = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	foreach ItemMgr.IterateTemplates(IterateTemplate)
	{
		if (!ClassIsChildOf(IterateTemplate.Class, class'X2CompletionItemTemplate')) continue;

		CompletionItemTemplate = X2CompletionItemTemplate(IterateTemplate);
		if (CompletionItemTemplate.AssociatedTemplateName == TemplateName) return CompletionItemTemplate;
	}

	`AMLOG("No match for Template " $ TemplateName);
}

DefaultProperties
{
	CanBeBuilt = false;
	bOneTimeBuild = false;
	bBlocked = false;

	HideInInventory = true;
	HideInLootRecovered = true;
}
