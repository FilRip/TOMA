class MA_BatteryModel extends s_Weapon;

#exec mesh import mesh=MAbattery anivfile=Models\MAbattery_a.3d datafile=Models\MAbattery_d.3d x=0 y=0 z=0 mlod=0
#exec mesh origin mesh=MAbattery x=0 y=0 z=0
#exec mesh sequence mesh=MAbattery seq=All startframe=0 numframes=1
#exec mesh sequence mesh=MAbattery seq=Still startframe=0 numframes=1

#exec meshmap new meshmap=MAbattery mesh=MAbattery
#exec meshmap scale meshmap=MAbattery x=0.13086 y=0.13086 z=0.26172

defaultproperties
{
    clipSize=250
    MaxClip=175
    RoundPerMin=300
    price=300
    MaxRange=10663.00
    WeaponDescription="Classification: Size D rechargeable battery."
    Mesh=Mesh'MAbattery'
}

