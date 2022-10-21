Class TOST_CliProtect extends TOST_ClientModule;

var string zzKnownPackage[50];	// contains all Trusted packages

// New FilRip
var string	SrvEncMsg[2];
var int		zzSelftestCount;

var byte toff,aa;
var int	zzPackageCount;
struct PackageData {
	var string	zzPkgName;
	var int		zzNames;
	var int		zzNameSpace;
	var int		zzImports;
	var int		zzExports;
	var int		zzGenerations;
	var int		zzLazy;
	var bool	zzKnown;
	var bool	zzVerified;
};
var PackageData		zzPackages[200];
// End New FilRip

simulated function Timer()
{
	local bool sh,th;

    toff++;
    if (toff==255)
    {
    	if ((Player!=None) && (!IsInState('zzServerKick')))
        {
            CheckActors();
            sh=false;
            th=false;
            if (Player.Physics==PHYS_Flying)
            {
                if (Player.IsInState('PlayerWalking'))
                {
                    TOST_Protect(Module).zzServerLogCheat(player,7,"Fly bug user","Fly bug user");
                    GotoState('zzServerKick');
                }
            }
            if ((Player!=None) && (Player.IsInState('PlayerWalking')))
            {
                if (Player.PlayerModel==1)
                    sh=true;
                if (Player.PlayerReplicationInfo.Team==0)
                    if (class'TO_ModelHandler'.Default.ModelType[Player.PlayerModel]!=MT_Terrorist) sh=true;
                if (Player.PlayerReplicationInfo.Team==1)
                    if (class'TO_ModelHandler'.Default.ModelType[Player.PlayerModel]!=MT_SpecialForces) sh=true;
                if (Player.PlayerReplicationInfo.Team>1)
                    th=true;
                if (th)
                {
                    TOST_Protect(Module).zzServerLogCheat(player,7,"Team Hack","Team Hack");
                    GotoState('zzServerKick');
                }
                if (sh)
                {
                    TOST_Protect(Module).zzServerLogCheat(player,7,"Team/Hostages Skin Hack","Team/Hostages Skin Hack");
                    GotoState('zzServerKick');
                }
            }
        }
        toff=0;
        aa=0;
    }
// End new stuff from FilRip
}

// New stuff from FilRip
final simulated function CheckActors()
{
    local Actor A;
    local string Package;
    local bool ok;
    local byte i;

    foreach Player.getEntryLevel().AllActors(class'Actor',A)
    {
        ok=false;
        Package=Left(Caps(String(A.Class)),Instr(Caps(String(A.Class)),"."));
        for (i=0;i<50;i++)
            if (Package==zzKnownPackage[i]) ok=true;
        if (!ok)
        {
            TOST_Protect(Module).zzServerLogCheat(Player,2,"Unknown actor "$Caps(string(A.Class)),"Unknown actor "$Caps(string(A.Class)));
            GotoState('zzServerKick');
        }
    }
}
// End new stuff from FilRip

// Added by FilRip, code from TOST 3.0
// Check Import/Export/Size of Known Packages

function xxVerifyPackages(string zzVerify)
{
	local string zzPackage;
	local int zzi, zzj, zzk;

	zzPackage = zzVerify;
	if (zzPackage == "")
		return;

	zzi = InStr(zzPackage, ";");
	while (zzi != -1)
	{
		zzj = TOST_Protect(Module).xxGetPackageData(Left(zzPackage, zzi));
		if (zzj == -1) {
//			TOST_Protect(Module).zzServerLog(SrvEncMsg[0]@Left(zzPackage, zzi));
		} else {
			zzSelftestCount += (TOST_Protect(Module).xxGetPackageVersionCount(zzj) - 1);
			for (zzk=0; zzk < TOST_Protect(Module).xxGetPackageVersionCount(zzj); zzk++)
				xxVerifyPackage(TOST_Protect(Module).xxGetPackageName(zzj),
						TOST_Protect(Module).xxGetPackageDataNames(zzj, zzk),
						TOST_Protect(Module).xxGetPackageDataNameSpace(zzj, zzk),
						TOST_Protect(Module).xxGetPackageDataImports(zzj, zzk),
						TOST_Protect(Module).xxGetPackageDataExports(zzj, zzk),
						TOST_Protect(Module).xxGetPackageDataGenerations(zzj, zzk),
						TOST_Protect(Module).xxGetPackageDataLazy(zzj, zzk),
						TOST_Protect(Module).xxGetPackageName(zzj) != TOST_Protect(Module).zzTOSTPackage );
		}
		zzPackage = Right(zzPackage, Len(zzPackage) - zzi - 1);
		zzi = InStr(zzPackage, ";");
	}
	zzj = TOST_Protect(Module).xxGetPackageData(zzPackage);
	if (zzj == -1) {
//		TOST_Protect(Module).zzSrvLog(SrvEncMsg[0]@zzPackage);
	} else {
		zzSelftestCount += (TOST_Protect(Module).xxGetPackageVersionCount(zzj) - 1);
		for (zzk=0; zzk < TOST_Protect(Module).xxGetPackageVersionCount(zzj); zzk++)
			xxVerifyPackage(TOST_Protect(Module).xxGetPackageName(zzj),
					TOST_Protect(Module).xxGetPackageDataNames(zzj, zzk),
					TOST_Protect(Module).xxGetPackageDataNameSpace(zzj, zzk),
					TOST_Protect(Module).xxGetPackageDataImports(zzj, zzk),
					TOST_Protect(Module).xxGetPackageDataExports(zzj, zzk),
					TOST_Protect(Module).xxGetPackageDataGenerations(zzj, zzk),
					TOST_Protect(Module).xxGetPackageDataLazy(zzj, zzk),
					TOST_Protect(Module).xxGetPackageName(zzj) != TOST_Protect(Module).zzTOSTPackage );
	}
}

// * ColllectPackageData - collect all data
simulated function xxCollectPackageData()
{
	local string		zzUsedPackages, zzObjLinkers, zzPackage;
	local Actor		zzActor;
	local SpawnNotify	zzSN;

	zzPackageCount = 0;
	zzObjLinkers = "OBJ LINKERS";

	zzSN = Level.SpawnNotify;
	Level.SpawnNotify = None;
	zzActor = spawn(class'xxTOSTActor');
	Level.SpawnNotify = zzSN;

	zzUsedPackages = zzActor.ConsoleCommand(zzObjLinkers);
//	xxComparePackages(zzObjLinkers, zzActor.Class);

	zzActor.Destroy();

 	zzPackage = xxParsePackage(zzUsedPackages);
	while (zzPackage != "")
	{
		zzPackageCount++;
		xxParseLine(zzPackage, zzPackageCount);
		zzPackage = xxParsePackage(zzUsedPackages);
	}
}

// * ParsePackage - determines the package name
simulated function string xxParsePackage(out string zzUsedPackages)
{
	local int zzPos;
	local string zzPackage;

	zzPos = instr(zzUsedPackages,".u");
	if (zzPos != -1)
	{
		zzPackage = left(zzUsedPackages, zzPos);
		zzUsedPackages = mid(zzUsedPackages, zzPos+1);
	}
	else
	{
		zzPackage = zzUsedPackages;
		zzUsedPackages = "";
	}
	return zzPackage;
}

// * ParseLine - Gets all the values of 1 full line from the obj linker
simulated function xxParseLine(string zzpackage, out int zzPackageNo)
{
	zzPackages[zzPackageNo-1].zzPkgName = xxParsePart(zzpackage,"(Package ",")");
	zzPackages[zzPackageNo-1].zzNames = int(xxParsePart(zzpackage,"="," "));
	zzPackages[zzPackageNo-1].zzNameSpace = int(xxParsePart(zzpackage,"/","K"));
	zzPackages[zzPackageNo-1].zzImports = int(xxParsePart(zzpackage,"="," "));
	zzPackages[zzPackageNo-1].zzExports = int(xxParsePart(zzpackage,"="," "));
	zzPackages[zzPackageNo-1].zzGenerations = int(xxParsePart(zzpackage,"="," "));
	zzPackages[zzPackageNo-1].zzLazy = int(xxParsePart(zzpackage,"="," "));
	if (zzPackages[zzPackageNo-1].zzPkgName == "") {
		zzPackageNo--;
	}
}

// * ParsePart - Grabs the different potions of an obj linker entry
simulated function string xxParsePart(out string zzpackage, string zzbegin, string zzend)
{
	local int zzpos;
	local string zzpart;

	zzpos = Instr(zzpackage,zzbegin)+Len(zzbegin);
	zzpackage = Mid(zzpackage, zzpos); //shave off beginning
	zzpos = Instr(zzpackage,zzend);
	zzpart = Left(zzpackage,zzpos); //get the token until the end
	zzpackage = Mid(zzpackage, zzpos+Len(zzend)); //shave off token and end
	return zzpart;
}

simulated function xxVerifyPackage(string zzPackage, int zzNames, int zzNameSpace, int zzImports, int zzExports, int zzGenerations, int zzLazy, bool zzFlag)
{
	local int	zzI;

	for(zzI=0; zzI<zzPackageCount; zzI++)
	{
		if (zzI >= 200)
			break;
		if (Caps(zzPackages[zzI].zzPkgName) == Caps(zzPackage))
		{
			if ( (zzPackages[zzI].zzNames - zzPackages[zzI].zzGenerations) == (zzNames - zzGenerations)
				&& zzPackages[zzI].zzImports == zzImports
				&& zzPackages[zzI].zzExports == zzExports)
			{
				zzPackages[zzI].zzVerified = true;
				zzPackages[zzI].zzKnown = zzFlag;
				return;
			}
		}
	}
	TOST_Protect(Module).zzServerLogCheat(Player,6,zzPackage,zzPackage);
}

defaultproperties
{
}
