class AssaultWeaponsHandler extends TO_WeaponsHandler;

var() config string WeaponClass[32];

static function bool IsClassMatch(Pawn Other,byte numweapon)
{
	local byte i;
	local byte PC;

    if (AssaultPlayer(Other)!=None)
    	i=AssaultPlayer(Other).PlayerModel;
    else
        if (AssaultBot(Other)!=None)
        	i=AssaultBot(Other).PlayerModel;
        else return false;

	if (i!=0)
	{
		PC=class'AssaultModelHandler'.default.PClass[i];
		if (PC!=0)
		{
			if (instr(default.WeaponClass[numweapon],string(PC))>-1)
				return true;
		}
	}
    return false;
}

defaultproperties
{
	WeaponClass(1)="12"
	WeaponClass(2)="2"
	WeaponClass(3)="3"
	WeaponClass(4)="13"
	WeaponClass(5)="13"
	WeaponClass(6)="1"
	WeaponClass(7)="0"
	WeaponClass(8)="1"
	WeaponClass(9)="1"
	WeaponClass(10)="0"
	WeaponClass(11)="2"
	WeaponClass(12)="1"
	WeaponClass(13)="3"
	WeaponClass(14)="13"
	WeaponClass(15)="0"
	WeaponClass(16)="0"
	WeaponClass(17)="3"
	WeaponClass(18)="123"
	WeaponClass(19)="12"
	WeaponClass(20)="0"
	WeaponClass(21)="2"
	WeaponClass(22)="0"
	WeaponClass(23)="0"
	WeaponClass(24)="123"
}
