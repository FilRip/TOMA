class PackageSniffer extends actor;

var string packages;

event spawned()
{
	local string avail;
	local class<s_weapon> buggy;

	packages = caps(ConsoleCommand("get GameEngine ServerPackages"));

	TOSTWeaponsServer(owner).bFamasPack = instr(packages,"FAMASPACK42") != -1;
	TOSTWeaponsServer(owner).bSteyrPack = instr(packages,"STEYRAUGPACK42") != -1;
	TOSTWeaponsServer(owner).bC4Pack = instr(packages,"C4PACK42") != -1;
	TOSTWeaponsServer(owner).bTearGasPack = instr(packages,"TEARGASPACK42") != -1;

	log("");
	log("---------------------------TOSTWeapons---------------------------");
	avail = "> ";
	log("The following gunpacks are available for use with TOSTWeapons:");
	if ( TOSTWeaponsServer(owner).bFamasPack )
		avail = avail $ "Famas, ";
	if ( TOSTWeaponsServer(owner).bSteyrPack )
		avail = avail $ "SteyrAug, ";
	if ( TOSTWeaponsServer(owner).bC4Pack )
		avail = avail $ "C4, ";
	if ( TOSTWeaponsServer(owner).bTearGasPack )
		avail = avail $ "TearGas";
	if ( avail ~= "> " )
		avail = "> None";
	else if ( right(avail,2) ~= ", " )
		avail = left(avail,len(avail)-2 );
	log(avail);

	avail = "> ";
	log("The following gunpacks are unavailable for use with TOSTWeapons:");
	if ( !TOSTWeaponsServer(owner).bFamasPack )
		avail = avail $ "Famas, ";
	if ( !TOSTWeaponsServer(owner).bSteyrPack )
		avail = avail $ "SteyrAug, ";
	if ( !TOSTWeaponsServer(owner).bC4Pack )
		avail = avail $ "C4, ";
	if ( !TOSTWeaponsServer(owner).bTearGasPack )
		avail = avail $ "TearGas";
	if ( avail ~= "> " )
		avail = "> None";
	else if ( right(avail,2) ~= ", " )
		avail = left(avail,len(avail)-2 );
	log(avail);
	log("-----------------------------------------------------------------");

	/* used to remove an ucc bug :( "cant assign byte = 0 in defproperties"*/
	buggy = class<s_weapon>(DynamicLoadObject("C4Pack42.TOST_C4Lazer",Class'Class'));
	if ( buggy != none)
		buggy.default.maxclip = 0;
	buggy = class<s_weapon>(DynamicLoadObject("C4Pack42.TOST_C4Timer",Class'Class'));
	if ( buggy != none)
		buggy.default.maxclip = 0;

	buggy = class<s_weapon>(DynamicLoadObject("TearGasPack42.TOST_GrenadeGas",Class'Class'));
	if ( buggy != none)
		buggy.default.maxclip = 0;

	class<s_weapon>(DynamicLoadObject("TOSTWeapons42.TOST_Grenade",Class'Class')).default.maxclip=0;
	class<s_weapon>(DynamicLoadObject("TOSTWeapons42.TOST_GrenadeConc",Class'Class')).default.maxclip=0;
	class<s_weapon>(DynamicLoadObject("TOSTWeapons42.TOST_GrenadeFB",Class'Class')).default.maxclip=0;
	class<s_weapon>(DynamicLoadObject("TOSTWeapons42.TOST_GrenadeSmoke",Class'Class')).default.maxclip=0;
	/* done */

	destroy();
}
