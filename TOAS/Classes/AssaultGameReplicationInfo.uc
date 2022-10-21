class AssaultGameReplicationInfo extends s_GameReplicationInfo;

var int SupportLimit,AssaultLimit,SniperLimit;
var int LimitBuyTime;

replication
{
	reliable if (Role==ROLE_Authority)
	   SupportLimit,AssaultLimit,SniperLimit,LimitBuyTime;
}

/*function int PlaceInClass(int p,byte t)
{
	local int i;
    local AssaultPRI ap;
    local AssaultBRI ab;

	if (p==0) return 0;
	if ((P==1) && (SupportLimit==0)) return 255;
	if ((P==2) && (SniperLimit==0)) return 255;
	if ((P==3) && (AssaultLimit==0)) return 255;
	i=0;
	for (i=0;i<32;i++)
	{
	   ap=AssaultPRI(PRIArray[i]);
	   if (ap!=None)
	   {
		if ((class'AssaultModelHandler'.default.PClass[ap.PlayerModel]==p) && (ap.Team==t))
            i++;
	   } else
	   {
	       ab=AssaultBRI(PRIArray[i]);
	       if (ab!=None)
    		if ((class'AssaultModelHandler'.default.PClass[ab.PlayerModel]==p) && (ab.Team==t))
                i++;
	   }
	}
	if (P==1) return SupportLimit-i;
	if (P==2) return SniperLimit-i;
	if (P==3) return AssaultLimit-i;
}*/

defaultproperties
{
}

