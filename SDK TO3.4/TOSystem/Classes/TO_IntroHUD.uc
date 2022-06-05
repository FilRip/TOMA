class TO_IntroHUD extends CHNullHUD;

enum ELogo
{
	L_MP,
	L_KS,
	L_TOAoT
};

var float LogoFadeTime;
var float LogoTiming;
var float OldScale;
var float Scale;
var float XO;
var float YO;
var int Scale256;
var int Scale128;
var bool bLaunchMenu;
var ELogo CurrentLogo;

function PostRender (Canvas Canvas)
{
}

function Tick (float Delta)
{
}
