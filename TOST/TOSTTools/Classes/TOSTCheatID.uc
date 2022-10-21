// $Id: TOSTCheatID.uc 541 2004-04-11 03:23:49Z stark $
//----------------------------------------------------------------------------
// Project   : TOST
// File      : TOSTCheatID.uc
// Version   : 1.1
// Author    : BugBunny/Stark
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
// 1.1		+ added alot cheats
// 1.2		+ added Helios4.1
// 1.3		+ added some old MD5s
//----------------------------------------------------------------------------

class TOSTCheatID expands TOSTPiece;

function	CheatID(int InitCRC, int CRC, int FileSize, string Package, TOSTPiece Sender)
{
	// already identified ?
	if (Sender.Params.Param5)
		return;

	if (Caps(Package) == "S_SWAT")
	{
		// TO340 stuff
		if (FileSize == 1101952)
		{
			if ((InitCRC == 0x701337BB && CRC == 0xFF258825) || (InitCRC == 0x1337BB70 && CRC == 0xE402D55A) || (InitCRC == 0xBB701337 && CRC == 0xF81A4633))
			{
				Sender.Params.Param4 = "Helios Radar 4.0";
				Sender.Params.Param5 = true;
            	return;
			}
			else if ((InitCRC == 0x701337BB && CRC == 0x06109517) || (InitCRC == 0x1337BB70 && CRC == 0x1D37C868 ) || (InitCRC == 0xBB701337 && CRC == 0x099A7E86))
			{
				Sender.Params.Param4 = "BCC Hacks";
				Sender.Params.Param5 = true;
            	return;
			}
			else if ((InitCRC == 0x701337BB && CRC == 0xE33D1B4C) || (InitCRC == 0x1337BB70 && CRC == 0xF81A4633 ) || (InitCRC == 0xBB701337 && CRC == 0xEC67F0D0))
			{
				Sender.Params.Param4 = "BCC Hack Update";
				Sender.Params.Param5 = true;
            	return;
			}
			else if ((InitCRC == 0x701337BB && CRC == 0xFC712546) || (InitCRC == 0x1337BB70 && CRC == 0xE7567839 ) || (InitCRC == 0xBB701337 && CRC == 0xF3F6CEDA))
			{
				Sender.Params.Param4 = "cyfers ghostcam-hack";
				Sender.Params.Param5 = true;
            	return;
			}
			else if ((InitCRC == 0x701337BB && CRC == 0xFD708616) || (InitCRC == 0x1337BB70 && CRC == 0xE657D664 ) || (InitCRC == 0xBB701337 && CRC == 0xF2FA6087))
			{
				Sender.Params.Param4 = "Enemy–locator–by–BiAtCh–KiLlEr";
				Sender.Params.Param5 = true;
            	return;
			}
			else if ((InitCRC == 0x701337BB && CRC == 0xEFA5E4C5) || (InitCRC == 0x1337BB70 && CRC == 0xF482696A ) || (InitCRC == 0xBB701337 && CRC == 0xE02F0F59))
			{
				Sender.Params.Param4 = "Helios Radar 2.1";
				Sender.Params.Param5 = true;
            	return;
			}
			else if ((InitCRC == 0x701337BB && CRC == 0xF7E76967) || (InitCRC == 0x1337BB70 && CRC == 0xECC0E4C8 ) || (InitCRC == 0xBB701337 && CRC == 0xF86D522B))
			{
				Sender.Params.Param4 = "hex-day-vision";
				Sender.Params.Param5 = true;
            	return;
			}
			else if ((InitCRC == 0x701337BB && CRC == 0x026016CB) || (InitCRC == 0x1337BB70 && CRC == 0x19474664 ) || (InitCRC == 0xBB701337 && CRC == 0x0DEAFD57))
			{
				Sender.Params.Param4 = "hex-wipe-shoes";
				Sender.Params.Param5 = true;
            	return;
			}
			else if ((InitCRC == 0x701337BB && CRC == 0xE8F21268) || (InitCRC == 0x1337BB70 && CRC == 0xF3D54F17 ) || (InitCRC == 0xBB701337 && CRC == 0xE778F9F4))
			{
				Sender.Params.Param4 = "uxb-radar-0.9";
				Sender.Params.Param5 = true;
            	return;
			}
			else if ((InitCRC == 0x701337BB && CRC == 0xF2A58BD3) || (InitCRC == 0x1337BB70 && CRC == 0xE982D6AC ) || (InitCRC == 0xBB701337 && CRC == 0xFD2F6047))
			{
				Sender.Params.Param4 = "Weapon=Right demoplay (no cheat)";
				Sender.Params.Param5 = true;
            	return;
			}
			else if ((InitCRC == 0x701337BB && CRC == 0x1D0B5C29) || (InitCRC == 0x1337BB70 && CRC == 0x062C0156 ) || (InitCRC == 0xBB701337 && CRC == 0x1281B7B5 ))
			{
				Sender.Params.Param4 = "HelioS Radar 4.1";
				Sender.Params.Param5 = true;
            	return;
			}
			else if ((InitCRC == 0x701337BB && CRC == 0xED40DFE8) || (InitCRC == 0x1337BB70 && CRC == 0xF6678297 ) || (InitCRC == 0xBB701337 && CRC == 0xE2CA3474 ))
			{
				Sender.Params.Param4 = "HelioS Radar 4.2";
				Sender.Params.Param5 = true;
            	return;
			}
			else if ((InitCRC == 0x701337BB && CRC == 0xFF709823) || (InitCRC == 0x1337BB70 && CRC == 0xE457C55C ) || (InitCRC == 0xBB701337 && CRC == 0xF0FA73BF ))
			{
				Sender.Params.Param4 = "HelioS Radar 4.3";
				Sender.Params.Param5 = true;
            	return;
			}
		}
	}

	// Known Cheat MD5-sums:
	else if (Package == "b6d7c55b47272d43d06e4ed6d9e7f56a")
	{
		Sender.Params.Param4 = "HelioS Radar 4.1";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "8fa8a773bc066c1e45056c2f48663f37")
	{
		Sender.Params.Param4 = "HelioS Radar 4.2";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "557c23775afb9924caf6bfd1e8706fcd")
	{
		Sender.Params.Param4 = "HelioS Radar 4.3";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "cf48091db4c7a58b7e1ea93f3d4ce57b")
	{
		Sender.Params.Param4 = "Wallhack";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "1dae8e93627e6c2022c4b13d4482f044")
	{
		Sender.Params.Param4 = "HelioS Radar 4.0";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "c82b62c04f1889c6bc3550752a14ca17")
	{
		Sender.Params.Param4 = "HelioS Radar 1.2";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "3110214fc8b5c0a070dc3c72103bb05f")
	{
		Sender.Params.Param4 = "Shadowhack";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "bf176df23f93034f25c59a575d5e0aad")
	{
		Sender.Params.Param4 = "myswat from 1337h4xx0r";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "55e917b88f6330cdd6f1f6530e2e735e")
	{
		Sender.Params.Param4 = "Radar Hack";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "935517ce0a678f619d8bb46b1f23a986")
	{
		Sender.Params.Param4 = "AllPatcher";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "18d5fcaa26b3f51f5dc97fa64b4934a5")
	{
		Sender.Params.Param4 = "Ammo Hack Liquid";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "ebc11aadff33ef68414944b7c3b0e29d")
	{
		Sender.Params.Param4 = "1337's swat-file";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "66c0701ffaa694c502c3149a7271519a")
	{
		Sender.Params.Param4 = "ALL-IN-ONE-by-BiAtChKiLlEr";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "7aa15069da61525f70b6443143d50185")
	{
		Sender.Params.Param4 = "crosshairs-for-your-snipers-by-BiAtChKiLlEr";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "e4c04365e54b7475d8fa756c7dcd6a07")
	{
		Sender.Params.Param4 = "enemylocator-by-BiAtChKiLlEr";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "0a0bf7294b9c82e05f1fc9d84c80cb1a")
	{
		Sender.Params.Param4 = "No Black on HK or SIG";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "b068f656386d6bcaf05f7a6b47d3de71")
	{
		Sender.Params.Param4 = "CyFFLeR'S-Ghostcamhack";
		Sender.Params.Param5 = true;
    	return;
	}
	else if (Package == "977ee530cf8d12d31f94e60193cda1f0")
	{
		Sender.Params.Param4 = "LK Radar updated";
		Sender.Params.Param5 = true;
    	return;
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
	PieceVersion="1.0.1.2"
	ServerOnly=true
}
