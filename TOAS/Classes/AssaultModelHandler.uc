class AssaultModelHandler extends TO_ModelHandler;

Enum PlayerClass
{
	PT_None,
	PT_Support,
	PT_Sniper,
	PT_Assault
};

var PlayerClass PClass[32];

static function string ReturnClassName(int i)
{
	local string retour;

	if (Default.PClass[i]==PT_None) retour="";
	if (Default.PClass[i]==PT_Support) retour="SUPPORT : ";
	if (Default.PClass[i]==PT_Sniper) retour="SNIPER : ";
	if (Default.PClass[i]==PT_Assault) retour="ASSAULT : ";

	return retour;
}

final static function int AssaultGetNextModel(int num,int team)
{
	num=Clamp(num,0,31);

	while (true)
	{
		num++;
		if (num>31)
			num=0;

		if (default.ModelName[num]!="")
		{
			if ((team==0) && (default.ModelType[num]==MT_Terrorist))
				return num;

			if ((team==1) && (default.ModelType[num]==MT_SpecialForces))
				return num;
		}
	}
}

final static function int AssaultGetPrevModel(int num,int team)
{
	num=Clamp(num,0,31);

	while (true)
	{
		num--;
		if (num<0)
			num=31;

		if (default.ModelName[num]!="")
		{
			if ((team==0) && (default.ModelType[num]==MT_Terrorist))
				return num;

			if ((team==1) && (default.ModelType[num]==MT_SpecialForces))
				return num;
		}
	}
}

defaultproperties
{
	PClass(0)=PT_None
	PClass(1)=PT_None
    ModelType(1)=MT_None
	PClass(2)=PT_Sniper
	PClass(3)=PT_Assault
	PClass(4)=PT_None
    ModelType(4)=MT_None
	PClass(5)=PT_Support
	PClass(6)=PT_None
    ModelType(6)=MT_None
	PClass(7)=PT_Sniper
	PClass(8)=PT_Assault
	PClass(9)=PT_None
    ModelType(9)=MT_None
	PClass(10)=PT_Sniper
	PClass(11)=PT_None
    ModelType(11)=MT_None
	PClass(12)=PT_Assault
	PClass(13)=PT_None
	PClass(14)=PT_None
    ModelType(14)=MT_None
	PClass(15)=PT_None
    ModelType(15)=MT_None
	PClass(16)=PT_Sniper
	PClass(17)=PT_Support
	PClass(18)=PT_Assault
}
