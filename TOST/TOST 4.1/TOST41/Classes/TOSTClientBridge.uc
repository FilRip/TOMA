//----------------------------------------------------------------------------
// Project : TOST
// File    : TOSTClientBrigde.uc
// Version : 1.0
// Author  : BugBunny
//----------------------------------------------------------------------------
// Version	Changes
// 0.5		+ first release
// 0.6		+ first beta release
// 1.0		+ first public release
//----------------------------------------------------------------------------

class TOSTClientBridge expands TOSTPiece;

// special piece, only sends messages, but does not process events
// it is currently kept out of the normal piece chain

defaultproperties
{
	bHidden=True

	PieceName="TOST Client Bridge"
	PieceVersion="1.0.0.0"
	ServerOnly=false
}
