class TOMAModMenu extends UMenuModMenuItem;

function Execute()
{
	local Class<UMenuStartGameWindow> StartTOMAGame;

	StartTOMAGame=Class<UMenuStartGameWindow>(DynamicLoadObject("TOMA21.TOMANewGame",Class'Class'));
	MenuItem.Owner.Root.CreateWindow(StartTOMAGame,100,100,200,200,,True);
}

defaultproperties
{
}
