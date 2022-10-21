//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTCheatID.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTCheatID expands TOSTPiece;

function	CheatID(int InitCRC, int CRC, int FileSize, string Package, TOSTPiece Sender)
{
	// already identified ?
	if (Sender.Params.Param5)
		return;

	if (Caps(Package) == "S_SWAT")
	{
		if (FileSize == 1088992)
		{
			if ((InitCRC == 0x701337BB && CRC == 0x062C5850) || (InitCRC == 0x1337BB70 && CRC == 0xE2625FFE) || (InitCRC == 0xBB701337 && CRC == 0xF0D3CCA3))
			{
				Sender.Params.Param4 = "Helios Radar 1.2";
				Sender.Params.Param5 = true;
				return;
			}
			if ((InitCRC == 0x701337BB && CRC == 0xEF6EDA71) || (InitCRC == 0x1337BB70 && CRC == 0x0B20DDDF) || (InitCRC == 0xBB701337 && CRC == 0x19914E82))
			{
				Sender.Params.Param4 = "Shadow Hack";
				Sender.Params.Param5 = true;
            	return;
			}
			if ((InitCRC == 0x701337BB && CRC == 0x02799CA9) || (InitCRC == 0x1337BB70 && CRC == 0xE6379B07) || (InitCRC == 0xBB701337 && CRC == 0xF486085A))
			{
				Sender.Params.Param4 = "l33t Patch";
				Sender.Params.Param5 = true;
            	return;
			}
			if ((InitCRC == 0x701337BB && CRC == 0xE9222770) || (InitCRC == 0x1337BB70 && CRC == 0x0D6C20DE) || (InitCRC == 0xBB701337 && CRC == 0x1FDDB383))
			{
				Sender.Params.Param4 = "All Patcher";
				Sender.Params.Param5 = true;
            	return;
			}
			if ((InitCRC == 0x701337BB && CRC == 0x16A8AF4E) || (InitCRC == 0x1337BB70 && CRC == 0xF2E6A8E0) || (InitCRC == 0xBB701337 && CRC == 0xE0573BBD))
			{
				Sender.Params.Param4 = "All-in-one Patcher";
				Sender.Params.Param5 = true;
            	return;
			}
			if ((InitCRC == 0x701337BB && CRC == 0x1C4BF871) || (InitCRC == 0x1337BB70 && CRC == 0xF805FFDF) || (InitCRC == 0xBB701337 && CRC == 0xEAB46C82))
			{
				Sender.Params.Param4 = "Crosshair";
				Sender.Params.Param5 = true;
            	return;
			}
			if ((InitCRC == 0x701337BB && CRC == 0xE03155A3) || (InitCRC == 0x1337BB70 && CRC == 0x047F520D) || (InitCRC == 0xBB701337 && CRC == 0x16CEC150))
			{
				Sender.Params.Param4 = "Enemy Locator";
				Sender.Params.Param5 = true;
            	return;
			}
			if ((InitCRC == 0x701337BB && CRC == 0x148AB98F) || (InitCRC == 0x1337BB70 && CRC == 0xF0C4BE21) || (InitCRC == 0xBB701337 && CRC == 0xE2752D7C))
			{
				Sender.Params.Param4 = "Scope Patch";
				Sender.Params.Param5 = true;
            	return;
			}
			if ((InitCRC == 0x701337BB && CRC == 0x15E25DBC) || (InitCRC == 0x1337BB70 && CRC == 0xF1AC5A12) || (InitCRC == 0xBB701337 && CRC == 0xE31DC94F))
			{
				Sender.Params.Param4 = "Ghostcam Hack";
				Sender.Params.Param5 = true;
            	return;
			}
			if ((InitCRC == 0x701337BB && CRC == 0x05F12753) || (InitCRC == 0x1337BB70 && CRC == 0xF39CCDFD) || (InitCRC == 0xBB701337 && CRC == 0xE12D5EA0))
			{
				Sender.Params.Param4 = "l337h4xx0r Hack";
				Sender.Params.Param5 = true;
            	return;
			}
			if ((InitCRC == 0x701337BB && CRC == 0xE2BB33AC) || (InitCRC == 0x1337BB70 && CRC == 0x06F53402) || (InitCRC == 0xBB701337 && CRC == 0x1444A75F))
			{
				Sender.Params.Param4 = "Radar Hack";
				Sender.Params.Param5 = true;
            	return;
			}
		}
	}
}

function	EventMessage(TOSTPiece Sender, int MsgIndex)
{
	switch (MsgIndex)
	{
		// CheatID
		case 190 :	CheatID(Sender.Params.Param1, Sender.Params.Param2, Sender.Params.Param3, Sender.Params.Param4, Sender);
					break;
	}
	super.EventMessage(Sender, MsgIndex);
}

defaultproperties
{
	bHidden=True

	PieceName="TOST Cheat ID"
	PieceVersion="1.0.0.0"
	ServerOnly=true
}
