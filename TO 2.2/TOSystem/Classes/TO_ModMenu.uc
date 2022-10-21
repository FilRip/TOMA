class TO_ModMenu expands UMenuModMenu;

function Select(UWindowPulldownMenuItem I)
{
	local UMenuModMenuList L;

	for(L = UMenuModMenuList(ModList.Next); L != None; L = UMenuModMenuList(L.Next))
		if(I == L.MenuItem)
			TO_MenuBar(GetMenuBar()).SetHelp(L.MenuHelp);

	Super(UWindowPulldownMenu).Select(I);
}

defaultproperties
{
}
