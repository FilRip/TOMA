class PathNodeGlowStick extends Mutator;

var() config byte GlowColor;
var int CurrentRound;

function DrawPath()
{
    local PathNode pn;
    local int i;
    local MA_Stick stick;

    foreach AllActors(class'PathNode',pn)
    {
        stick=Spawn(class'MA_Stick',,,pn.Location);
        stick.TimeToLive=s_SWATGame(Level.Game).RoundDuration*60+10;
        if (GlowColor==2)
        {
            i=Rand(2);
            if (i==0)
            {
                stick.LightHue=255;
                stick.Texture=Texture'AmmoCountJunk';
            }
        }
        else
        {
            if (GlowColor==0)
            {
                stick.LightHue=255;
                stick.Texture=Texture'AmmoCountJunk';
            }
        }
    }
}

function PreBeginPlay()
{
    SetTimer(1,true);
}

function Timer()
{
    if (s_SWATGame(Level.Game).GamePeriod==GP_PreRound)
    {
        if (s_SWATGame(Level.Game).RoundNumber!=CurrentRound)
        {
            CurrentRound=s_SWATGame(Level.Game).RoundNumber;
            DrawPath();
        }
    }
}

defaultproperties
{
    GlowColor=2
}

