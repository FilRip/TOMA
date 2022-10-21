class TO_IntroHUD extends Botpack.CHNullHUD;

var int Scale256;
var int Scale128;
var float XO;
var float YO;
var float LogoFadeTime;
enum ELogo {
	L_MP,
	L_KS,
	L_TOAoT
};
var ELogo CurrentLogo;
var float LogoTiming;
var float Scale;
var bool bLaunchMenu;
var float OldScale;

function Tick (float Delta)
{
}

function PostRender (Canvas Canvas)
{
}


defaultproperties
{
}

