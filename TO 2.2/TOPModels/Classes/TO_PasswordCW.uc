//=============================================================================
// TO_PasswordCW
//=============================================================================
//
// Tactical Ops
// - http://www.tactical-ops.net
//
// Source code rights:
// Copyright (C) 2000/2001 Laurent "SHAG" Delayen
//=============================================================================

class TO_PasswordCW expands UTPasswordCW;


///////////////////////////////////////
// Connect
///////////////////////////////////////

function Connect()
{
	local int i;
	local bool HistoryItem;
	local UWindowComboListItem Item;
	local string P;

	P = PasswordCombo.GetValue();

	if ( P == "" )
	{
		PasswordCombo.BringToFront();
		return;
	}

	i = InStr( P, " " );
	if ( i != -1 )
		P = Left(P, i);
	
	for (i=0; i<10; i++)
	{
		if (PasswordHistory[i] ~= P)
			HistoryItem = True;
	}

	if ( !HistoryItem )
	{
		PasswordCombo.InsertItem(P);

		while(PasswordCombo.List.Items.Count() > 10)
			PasswordCombo.List.Items.Last.Remove();

		Item = UWindowComboListItem(PasswordCombo.List.Items.Next);

		for (i=0; i<10; i++)
		{
			if(Item != None)
			{
				PasswordHistory[i] = Item.Value;
				Item = UWindowComboListItem(Item.Next);
			}
			else
				PasswordHistory[i] = "";
		}			
	}

	SaveConfig();
	PasswordCombo.ClearValue();
	GetParent(class'UWindowFramedWindow').Close();
	TO_Console(Root.Console).ConnectWithPassword(URL, P);
}

defaultproperties
{
}
