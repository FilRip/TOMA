class TOSTItemListBox extends TO_GUIImageListbox;

simulated function showNormal()
{
	NumVisItems = 4;
	ItemHeight=0.80 * ClientWidth;
	ClientHeight=NumVisItems * (ItemHeight + 2);
	WinHeight=ClientHeight + 4;
}

simulated function showAdvanced()
{
    NumVisItems = 5;
	ItemHeight=0.64 * ClientWidth;
	ClientHeight=NumVisItems * (ItemHeight + 2);
	WinHeight=ClientHeight + 4;
}
