class TOSTWeaponsListBox extends TO_GUITextListbox;

simulated function Paint (Canvas Canvas, float X, float Y)
{
	NumVisItems=max(NumItems,8);
	ClientHeight=NumVisItems * (ItemHeight + ItemSpacing);
	WinHeight=ClientHeight + 44;
	super.Paint(Canvas,X,Y);
}

defaultproperties
{
    NumVisItems=12
}
