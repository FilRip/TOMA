class TOSTWeaponMessages extends CriticalEventPlus;

var localized string Message[10];

static function string GetString (optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	return Default.Message[Switch];
}

static simulated function ClientReceive (PlayerPawn P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	Super.ClientReceive(P,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
}

static function float GetOffset (int Switch, float YL, float ClipY)
{
	return ClipY * 6 / 8;
}

defaultproperties
{
    Message(0)="Time: 10 Seconds"
    Message(1)="Time: 15 Seconds"
    Message(2)="Time: 20 Seconds"
    Message(3)="Range: 5 Meters"
    Message(4)="Range: 10 Meters"
    Message(5)="Range: 15 Meters"
    Message(6)="Time: 3 Seconds"
    Message(7)="Time: 5 Seconds"
    Message(8)="Time: 7 Seconds"
    Message(9)=""
    FontSize=4
    bBeep=False
    DrawColor=(R=254,G=254,B=254,A=0)
}

