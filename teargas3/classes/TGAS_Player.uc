class TGAS_Player extends MA_Player;

// Changes 7 June 2003:
// New buy menu added, Midnight Assault used as base
// Planning to take out no dynamic light support due to unfair advantages as in TO 3.40

// Changes 20 March 2003:
// New Thermal google, the classic Black White one. Currently made to show
// up as Terrorist, while the Navy Seals bluish one is used for SF
// Finer static noise on Thermal and NVG

// Changes 16 March 2003:
// Trimmed down to this functionality: Thermal scopes, Nightvision, Gasmask,
// Gas Effect(+blackout), FBeffect sound
// Each functionality moved to it's own function.
// Deleted unused variables
// Timer function reduced to gas functionality only, could be moved
// elsewhere for less messy code.

//#exec TEXTURE IMPORT NAME=TGAS_nvg  FILE=Textures\NVg.pcx  GROUP="Special" MIPS=off
#exec TEXTURE IMPORT NAME=TGAS_nvg16  FILE=Textures\NVg16.pcx  GROUP="Special" MIPS=off

#exec TEXTURE IMPORT NAME=gas0  FILE=Textures\gas0.pcx  GROUP="Special" FLAGS=2
#exec TEXTURE IMPORT NAME=gas1  FILE=Textures\gas1.pcx  GROUP="Special" FLAGS=2
#exec TEXTURE IMPORT NAME=gas2  FILE=Textures\gas2.pcx  GROUP="Special" FLAGS=2
#exec TEXTURE IMPORT NAME=gas3  FILE=Textures\gas3.pcx  GROUP="Special" FLAGS=2
#exec TEXTURE IMPORT NAME=TileWhite  FILE=Textures\TileWhite.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=scanlines FILE=Textures\scanlines.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=scan16 FILE=Textures\scan16.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=hex16 FILE=Textures\hexa16.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec AUDIO IMPORT FILE="Sounds\cough1.wav" NAME="cough1" GROUP="VoiceP1"
#exec AUDIO IMPORT FILE="Sounds\cough2.wav" NAME="cough2" GROUP="VoiceP1"

// Remarked due to 3.32 skinhack kick
#exec TEXTURE IMPORT NAME=jgasface  FILE=Textures\jillgasface.pcx  GROUP="Special"
#exec TEXTURE IMPORT NAME=tgasface  FILE=Textures\terrgasface.pcx  GROUP="Special"
//#exec TEXTURE IMPORT NAME=SFmaleNVG FILE=Textures\SFmalenvg.BMP  GROUP="Special"
//#exec TEXTURE IMPORT NAME=TerrmaleNVG FILE=Textures\Terrmalenvg.BMP  GROUP="Special"
//#exec TEXTURE IMPORT NAME=femaleNVG FILE=Textures\femaleNVG.bmp  GROUP="Special"

/*
#exec TEXTURE IMPORT NAME=g1  FILE=Textures\g1.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g2  FILE=Textures\g2.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g3  FILE=Textures\g3.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g4  FILE=Textures\g4.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g5  FILE=Textures\g5.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g6  FILE=Textures\g6.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g7  FILE=Textures\g7.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g8  FILE=Textures\g8.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g9  FILE=Textures\g9.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g10  FILE=Textures\g10.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g11  FILE=Textures\g11.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g12  FILE=Textures\g12.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g13  FILE=Textures\g13.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g14  FILE=Textures\g14.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=g15  FILE=Textures\g15.pcx  GROUP="Special" FLAGS=2 MIPS=off
*/
#exec TEXTURE IMPORT NAME=gwhite FILE=Textures\gwhite.pcx  GROUP="Special" FLAGS=2 MIPS=off
#exec TEXTURE IMPORT NAME=gblack FILE=Textures\gblack.pcx  GROUP="Special" FLAGS=2 MIPS=off

#exec TEXTURE IMPORT NAME=gasmask  FILE=Textures\gasmask.pcx  GROUP="Special"
#exec AUDIO IMPORT FILE="Sounds\breath.wav" NAME="breath" GROUP="VoiceP1"
#exec AUDIO IMPORT FILE="Sounds\underwater.wav" NAME="underwater" GROUP="VoiceP1"
#exec AUDIO IMPORT FILE="Sounds\fbeffect.wav" NAME="fbeffect" GROUP="VoiceP1"

var Bool bits16,bscrflash;
// Teargas replication info, used for the gassed time value....
var TGAS_PlyReplInfo TRI;
Var byte GasMaskEquipDelay,Fadeval;
var TO_NVLight NVLight;
var Bool bNVActive, bGmaskActive, bHasGasmask, bTGAS_HeatVision, bHVActive, bTGAS_Buymenu, bHasThermal, MAmode;
var Bool binitialized,bNightVision, bFadeOut, bFadeIn;
var byte tickCount, TGInfotimer;
var byte NVGIsCount, orgPlayermodel;
var TGAS_heat NVGis[32];
var Actor OtherHeats[32];
var int HeatCount;
var int OtherCount;
var float BreathBobTime;
var byte swimcounter;
var float Stuntime;
var float deaftime,xforce,yforce;
var TGAS_main tgmut;
var TGAS_Brightblinder brightblinders[32];

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		TRI,bHasGasmask,bHasThermal,tgmut, nadestun, bTGAS_HeatVision;
	// client send to server
	reliable if ( Role<ROLE_Authority )
		bGmaskActive,binitialized,GasMaskEquipDelay,bits16;

	// Functions clients can call on server
	reliable if( Role < ROLE_Authority)
		SetGasSkin, setorgskin,server_Gasanim,server_GasanimOff,ServerBuyGasmask,ServerBuyThermal,ServerNVG, NVGon, ServerThermal;

}

/*
function Destroyed()
{
    if (tgmut.Tearnades)
	{
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[25] = "";
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[25] = "";
	class'TOModels.TO_WeaponsHandler'.default.BotDesirability[25] = 0.10;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[25] = WT_none;
	class'TOModels.TO_WeaponsHandler'.default.NumWeapons -= 1;
	}
   if (tgmut.Nadetimer)
	{
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[12] = "s_SWAT.TO_Grenade";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[13] = "s_SWAT.s_GrenadeFB";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[14] = "s_SWAT.s_GrenadeConc";
	}
  super.destroyed();
}
*/

simulated function SetMesh ()
{
  RemoveGasmask();
  super.SetMesh();
}

// Reverts a selected gas mask skin to it's normal one
simulated function RemoveGasmask()
{
 if (Playermodel == 19)
 	playermodel = 1;
 else if (Playermodel == 24)
 	playermodel = 2;
 else if (Playermodel == 26)
 	playermodel = 4;
 else if (Playermodel == 21)
 	playermodel = 5;
 else if (Playermodel == 20)
 	playermodel = 6;
 else if (Playermodel == 22)
 	playermodel = 7;
 else if (Playermodel == 23)
 	playermodel = 8;
 else if (Playermodel == 20)
 	playermodel = 10;
 else if (Playermodel == 27)
 	playermodel = 11;
 else if (Playermodel == 28)
 	playermodel = 12;
 else if (Playermodel == 29)
 	playermodel = 15;
 else if (Playermodel == 30)
 	playermodel = 16;
 else if (Playermodel == 25)
 	playermodel = 17;
 SetMultiSkin (self,"","",playermodel);
}

simulated function SetOrgSkin ()
{
 Playermodel = orgPlayermodel;
 s_ChangeTeam (Playermodel, PlayerReplicationInfo.Team, false);
}

simulated function SetGasSkin()
{
If (Playermodel <= 18 )
 orgPlayermodel = Playermodel;

 if (Playermodel == 1)
	 Playermodel = 19;
 else if (Playermodel == 2)
	 Playermodel = 24;
 else if (Playermodel == 3)
	 Playermodel = 25;
 else if (Playermodel == 4)
	 Playermodel = 26;
 else if (Playermodel == 5)
	 Playermodel = 21;
 else if (Playermodel == 6)
	 Playermodel = 20;
 else if (Playermodel == 7)
	 Playermodel = 22;
 else if (Playermodel == 8)
	 Playermodel = 23;
 else if (Playermodel == 10)
	 Playermodel = 20;
 else if (Playermodel == 11)
	 Playermodel = 27;
 else if (Playermodel == 12)
	 Playermodel = 28;
 else if (Playermodel == 15)
	 Playermodel = 29;
 else if (Playermodel == 16)
	 Playermodel = 30;
 else if (Playermodel == 17)
	 Playermodel = 25;
 else if (Playermodel == 18)
	 Playermodel = 19;

 SetMultiSkin (self,"","",playermodel);

//	tri.setgasskin();
}

//The typing effect is to simulate the player pawn fidling with something at his face
simulated function server_Gasanim()
{
	//false fidle with mask anim:
	bIsTyping=true;
}

simulated function server_GasanimOff()
{
	bNVon=False;
	bIsTyping=false;
}

Simulated Function setupclient()
{
	if (mamode)
		{
		class's_swat.TO_nvlight'.default.lightradius = 70;
		class's_swat.TO_nvlight'.default.lightbrightness = 230;
		}
	else
		{
		MA_FlashLight = true;
		bHasFL = true;
		BatLife=400;
		}

	if ( Level.Netmode == NM_DedicatedServer )
	  return;
    if (tgmut.Tearnades)
        {
	class'TOModels.TO_WeaponsHandler'.default.NumWeapons += 1;
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[25] = "teargas3.TGAS_Grenadegas";
	class'TOModels.TO_WeaponsHandler'.default.WeaponName[25] = "Tear Gas Grenade";
	class'TOModels.TO_WeaponsHandler'.default.BotDesirability[25] = 0.10;
	class'TOModels.TO_WeaponsHandler'.default.WeaponTeam[25] = WT_SpecialForces;
        }
   if (tgmut.Nadetimer)
	{
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[12] = "teargas3.NADE_TOGrenade";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[13] = "teargas3.NADE_GrenadeFB";
	class'TOModels.TO_WeaponsHandler'.default.WeaponStr[14] = "teargas3.NADE_GrenadeConc";
	}


if (TGmut.Clientside_Trace_Freq == 0)
	TGmut.Clientside_Trace_Freq = 1;
if (TGmut.Clientside_Trace_Freq > 14)
	TGmut.Clientside_Trace_Freq = 14;

	checks();
	// precache the skins at startup
	log("Teargas mutator- precaching skin:"$Texture(DynamicLoadObject("teargas3.jgasface",Class'Texture')) );
	log("Teargas mutator - precaching skin:"$Texture(DynamicLoadObject("teargas3.tgasface",Class'Texture')) );
	//Mutator initialized, used to prevent auto corpse spawning.
	
	binitialized = true;
}

function Gas_on()
{
	//false fidle with mask anim:
	bIsTyping=true;
	server_Gasanim();
	GasMaskEquipDelay=10;
	Soundpitch = 60 + (18 - (health * 0.18) );
	enable ('timer');
	SetTimer(0.1, true);
}

function Take_Gasmask_off()
{
	if (deaftime < 1)
		{
		AmbientSound=None;
		SoundDampening=1;
		}
 bGmaskActive=False;
 SetOrgSkin();
 GasMaskEquipDelay=0;
}

exec function gasmask ()
{
   enable ('timer');
   SetTimer(0.1, true);
if (!bHasGasmask)
	return;
if ( bNotPlaying )
	{
	bGmaskActive=False;
	AmbientSound=None;
	return;
	}
if ( bGmaskActive )
		Take_Gasmask_off();
	else
		gas_on();
}

Function ServerNVG(bool on)
{
bNVon = on;
}

Function ServerThermal(bool on)
{
bTGAS_HeatVision = on;
}

exec function s_kNightVision ()
{
// If no NVG key is relevant, function as gasmask key
If (!bhasnv && !bszoom)
	gasmask ();
if ( bGmaskActive )
		Take_Gasmask_off();

If (MAmode)
 {
	if ( !MA_NightVision )
	{
		ClientMessage("NightVision is Disabled");
		return;
	}
	else if ( !bNVon && BatLife < 40 )
	{
		ClientMessage("Not enough battery life");
		return;
	}
 }


   enable ('timer');
   SetTimer(0.1, true);
   if ( bNotPlaying )
	{
	ServerNVG(False);
	ServerThermal(False);
	return;
	}


   // The actual turn NVG on/off function is here, if a weapon is in scoped mode, this
   // is handled as Thermal on/off, otherwise NVG on/off.
   if ( bNVon )
	{
	ClientPlaySound(Sound'todatas.nv_off',,True);
	ServerNVG(False);
	}
   else if ( bTGAS_HeatVision )
	{
	ClientPlaySound(Sound'todatas.nv_off',,True);
	ServerThermal(False);
	if (bhasnv)
		NVGon();
	}
   else if ( bHasThermal && !bTGAS_HeatVision && bszoom)
	{
	If (MAmode && BatLife < 40)
		return;
	ClientPlaySound(Sound'todatas.NV_on',,True);
	ServerThermal(True);
	ServerNVG(False);
	fadeval = 40;
	bFadein = true;
	}
   else if ( bhasnv && !bNVon)
	NVGon();
}

Function NVGon()
{
	If (MAmode && BatLife < 40)
		return;
	ClientPlaySound(Sound'todatas.NV_on',,True);
	bNVon=True;
	fadeval = 40;
	bFadein = true;
	if (bszoom)
		ServerThermal(False);
}

simulated function Gas_off()
{
	bHasGasmask=False;
	bHasThermal=false;
	bGmaskActive=False;
	SoundDampening=1;
	AmbientSound=None;
	TRI.teartime = 0;
}

Function TraceHeatSignatures ()
{
  local float Scale, CalcScaleGlow;
  local vector HitLocation, HitNormal, endtrace, StartTrace, x,y,z;
  local Actor HitActor;
  local Int HeatThickness;
  local byte i, r;
  local pawn P;
  local actor a;
  local TGAS_heat NVGi;

   if (tickCount == TGmut.Clientside_Trace_Freq)
	{
	// Calculate visibility
	tickCount = 0;
	for( i=0; i<Heatcount; i++ )
	   {
	   if (NVGIs[i] != none)
		{
		//check if Path to NVGI is blocked decide visibility by looking at range from blocker
		CalcScaleGlow = 1 - (VSize(Location - NVGIs[i].owner.location) * 0.0001);
		HeatThickness=120;

		//Randomize offsets on traces
		GetAxes(rotation,X,Y,Z);
		EndTrace = NVGis[i].owner.Location;
		EndTrace.Z += BaseEyeHeight - 10;
		StartTrace = Location;
		StartTrace.Z += BaseEyeHeight-8;
		r=frand() * 3;
		// r == 0 From head
		if (r == 1)
		   {
		   // From feets
		   EndTrace.Z -= (BaseEyeHeight+20);
		   StartTrace.Z -= (BaseEyeHeight+20);
		   }
		else if (r == 2)
		   {
		   starttrace -= (35*y);
		   Endtrace -= (30*y);
		   }
		else if (r == 3)
		   {
		   starttrace += (35*y);
		   Endtrace += (30*y);
		   }
		hitactor = Trace(HitLocation,HitNormal,EndTrace,StartTrace, True);
		//Ignore thin walls like windows:
		if (hitactor != NVGis[i].owner && VSize(HitLocation - NVGIs[i].owner.location) < 2500 )
		   {
		   StartTrace = HitLocation + (12 * x );
		   StartTrace.Z += BaseEyeHeight;
		   EndTrace = NVGis[i].owner.Location;
		   EndTrace.Z += BaseEyeHeight;
		   hitactor = Trace(HitLocation,HitNormal,EndTrace,StartTrace, True);
		   CalcScaleGlow -= 0.35;
		   if (Hitactor == NVGis[i].owner)
			CalcScaleGlow -= VSize(HitLocation - NVGIs[i].owner.location) * 0.0002;

		   }
		if (Pawn(NVGIs[i].owner).bFire == 1)
			CalcScaleGlow += 0.2;
		if (hitactor == NVGis[i].owner)
		   {
		   NVGIs[i].RenderMe=True;
		   NVGIs[i].bNoZBufferMe=True;
		   }
		else if (VSize(HitLocation - NVGIs[i].owner.location) < HeatThickness)
		   {
		   NVGIs[i].RenderMe=True;
		   CalcScaleGlow -= 0.25 + ( VSize(HitLocation - NVGIs[i].owner.location) * 0.005 );
		   NVGIs[i].bNoZBufferMe=True;
		   }
		else
		   {
		   NVGIs[i].RenderMe=False;
		   CalcScaleGlow = 0;
		   }
		// No abrupt dissapearance, fade out if out of view:
		if (CalcScaleGlow < NVGIs[i].scaleglow - 0.1)
		   {
		   CalcScaleGlow = NVGIs[i].scaleglow - 0.1;
		   NVGIs[i].RenderMe=True;
		   }
		NVGIs[i].Scaleglow = CalcScaleGlow;
		}
	   }
	}
}

Function RenderHeatSignatures (Canvas canvas)
{
  local byte i;

   //Decide what NVGIs needs rendering and draw them on the HUD
   for( i=0; i<Heatcount; i++ )
	{
	if (NVGIs[i] != None )
	   {
	   if ((pawn(NVGIs[i].owner).health > 0) &&(NVGIs[i].RenderMe == True))
		canvas.DrawActor( NVGIs[i], False, NVGIs[i].bNoZBufferMe );
	   }
	}
   for( i=0; i<OtherCount; i++ )
	{
	if (OtherHeats[i] != None )
	   canvas.DrawActor( OtherHeats[i], False, True );
	}
}

Function ActivateThermal (bool blueheat)
{
  local pawn P;
  local TGAS_heat NVGi;

	tickCount = TGmut.Clientside_Trace_Freq-1;
	bHVActive = True;
	weapon.AmbientGlow=10000;
	weapon.ScaleGlow=100.000000;
	Heatcount = 0;
        //Iterate through all pawns and spawn a heat signature for them
	foreach AllActors(class'Pawn', P)
	   {
	   if ((p != self) && (!p.bHidden) )
		{
		NVGi = Spawn(class'TGAS_heat', P);
		NVGi.SetOwner(P);
		NVGi.Mesh = P.Mesh;
		NVGi.DrawScale = P.DrawScale;
		NVGI.default.scaleglow = 0;
		NVGI.scaleglow = 0;
		NVGIs[Heatcount]=NVGi;
		if (blueheat)
			NVGi.texture = Texture'heat2';
		else
			NVGi.texture = Texture'heat';
		HeatCount++;
		// check if array limit has been reached and stop calculating then
		if (Heatcount == 33)
		   {
		   //Debug message:
		   log ("teargas notice - couldn't spawn all pawn NVGIs");
		   break;
		   }
		}
	   }
}

Function DeactivateThermal()
{
  local byte i;
   //Thermal has been turned off, all heat signatures is destroyed.
   bHVActive = False;
   weapon.AmbientGlow=0;
   weapon.ScaleGlow=1;
       	for( i=0; i<Heatcount; i++ )
	{
	  if (NVGIs[i] != none)
		NVGIs[i].destroy();
	}
}

Function RenderNoise (byte noisestrength, canvas canvas)
{
   //Draw some static noise
   Canvas.SetPos(0, 0);
   canvas.drawcolor.r = noisestrength;
   canvas.drawcolor.g = noisestrength;
   canvas.drawcolor.b = noisestrength;
   Canvas.Style = ERenderStyle.STY_Translucent;
   Canvas.Drawpattern(Texture'Static_a00', Canvas.ClipX, Canvas.ClipY, 0.75);
   //Draw some scanlines
   canvas.drawcolor.r = 128;
   canvas.drawcolor.g = 128;
   canvas.drawcolor.b = 128;
   Canvas.SetPos(0.00,0.00);
   canvas.Style = ERenderStyle.STY_modulated ;
   if (!bits16)
	Canvas.DrawPattern(Texture'scanlines', canvas.clipx, canvas.clipy, 1);
   else
	{
   	canvas.drawcolor.r = 100;
   	canvas.drawcolor.g = 100;
   	canvas.drawcolor.b = 100;
	canvas.Style = ERenderStyle.STY_Translucent;
	Canvas.DrawPattern(Texture'scan16', canvas.clipx, canvas.clipy, 0.5);
	}
}

Function RenderThermalVision2 (canvas Canvas)
{
  local float Scale;
  local UT_SpriteBallExplosion AExpl;
  local s_Projectile AProj;

  if ( bHasThermal && bTGAS_HeatVision && bszoom)
   {
   canvas.Style = ERenderStyle.STY_modulated ;
   Scale = Canvas.ClipX/256;
   //Darken and dull the view a bit with a greyed color
   Canvas.SetPos(0, 0);
   Canvas.DrawPattern(Texture'g14', Canvas.ClipX, Canvas.ClipY, 1);
   //Blue tinting
   Canvas.SetPos(0.00,0.00);
   canvas.drawcolor.r = 0;
   canvas.drawcolor.g = 0;
   canvas.drawcolor.b = 50+(frand()*8);
   canvas.Style = ERenderStyle.STY_Translucent ;
   canvas.DrawTile(Texture'TileWhite', canvas.ClipX, canvas.ClipY, 0, 0, 32.0, 32.0);
   //Tickcount is a clientside value that ensures the traces and iterations run by
   //this fuction is spread out a bit and NOT run each tick.
   //It's also important to remember that this process is run while doing rendmap=2
   //The end result is that the client has a good portion of extra cpu power in
   //order to do these iterations and trace checks.
   tickCount++;
   // Make effect check for projectile (Balistics) heat and explosion heat!
   // A good place to start with a cleanup of this process is to remove
   // s_Projectile iterator.. balistics is rarily used.
   if (tickCount == TGmut.Clientside_Trace_Freq/2 )
	{
	Othercount = 0;
	foreach AllActors(class's_Projectile', AProj)
	   {
	   If (OtherCount < 33)
		OtherHeats[OtherCount] = AProj;
	   OtherCount++;
	   }
	foreach AllActors(class'UT_SpriteBallExplosion', AExpl)
	   {
	   If ((OtherCount < 33) && (VSize(Location - AExpl.location) < 3000) )
	   	OtherHeats[OtherCount] = AExpl;
	   OtherCount++;
	   }
	}
   TraceHeatSignatures ();
   RenderHeatSignatures (Canvas);
   RenderNoise ( 15+(swimcounter*2), canvas );
   if (!bHVActive)
	ActivateThermal(true);
   }
  else if (bHVActive)
	DeactivateThermal();
}

Function RenderThermalVision (canvas Canvas)
{
  local float Scale;
  local UT_SpriteBallExplosion AExpl;
  local s_Projectile AProj;

  if ( bHasthermal && bTGAS_HeatVision && bszoom)
   {

   //Tickcount is a clientside value that ensures the traces and iterations run by
   //this fuction is spread out a bit and NOT run each tick.
   //It's also important to remember that this process is run while doing rendmap=2
   //The end result is that the client has a good portion of extra cpu power in
   //order to do these iterations and trace checks.
   tickCount++;
   // Make effect check for projectile (Balistics) heat and explosion heat!
   // A good place to start with a cleanup of this process is to remove
   // s_Projectile iterator.. balistics is rarily used.
   if (tickCount == TGmut.Clientside_Trace_Freq/2 )
	{
	Othercount = 0;
	foreach AllActors(class's_Projectile', AProj)
	   {
	   If (OtherCount < 33)
		OtherHeats[OtherCount] = AProj;
	   OtherCount++;
	   }
	foreach AllActors(class'UT_SpriteBallExplosion', AExpl)
	   {
	   If ((OtherCount < 33) && (VSize(Location - AExpl.location) < 3000) )
	   	OtherHeats[OtherCount] = AExpl;
	   OtherCount++;
	   }
	}
   TraceHeatSignatures ();

   //Darken and dull the view with a greyed color
   //Since true greay scaling isn't possible, this is done a bit different:
   Scale = Canvas.ClipX/256;
   Canvas.SetPos(0, 0);
   canvas.Style = ERenderStyle.STY_modulated ;
   Canvas.DrawPattern(Texture'gblack', Canvas.ClipX, Canvas.ClipY, 1);
   Canvas.SetPos(0, 0);
   canvas.Style = ERenderStyle.STY_modulated ;
   Canvas.DrawPattern(Texture'gwhite', Canvas.ClipX, Canvas.ClipY, 1);
   Canvas.SetPos(0, 0);
   canvas.Style = ERenderStyle.STY_modulated ;
   Canvas.DrawPattern(Texture'g7', Canvas.ClipX, Canvas.ClipY, 1);
   canvas.drawcolor.r = 10;
   canvas.drawcolor.g = 10;
   canvas.drawcolor.b = 10;
   canvas.Style = ERenderStyle.STY_Translucent ;
   Canvas.SetPos(0, 0);
   canvas.DrawTile(Texture'TileWhite', canvas.ClipX, canvas.ClipY, 0, 0, 32.0, 32.0);
   RenderHeatSignatures (Canvas);
   RenderNoise ( 8+(swimcounter*2), canvas );
   if (!bHVActive)
	ActivateThermal(false);
   }
  else if (bHVActive)
	DeactivateThermal();
}


Function RenderNightvision( canvas Canvas )
{
  local float Scale;
  local vector HitLocation;
  local byte i;
  local MA_stick mastick;

  if ( bhasnv && bNVon && !bShowScores)
   {
   if (tickCount == TGmut.Clientside_Trace_Freq )
  	{
 Tickcount = 0;
	Othercount = 0;
	foreach VisibleActors (class'MA_stick', mastick, 1700, location)
	   {
	   If (OtherCount < 32)
		{
		brightblinders[OtherCount].setlocation (mastick.location);
		brightblinders[OtherCount].bRenderme = True;
		brightblinders[OtherCount].scaleglow = (1700 - vsize (brightblinders[i].location - location) ) / 3400;
		OtherCount++;
		}
	   }
	for( i=othercount; i<32; i++ )
    {
    if (brightblinders[i].scaleglow < 0.05)
	    brightblinders[i].bRenderme = False;
    }
   }
 Tickcount+=1;

 for( i=0; i<32; i++ )
	{
	if ((brightblinders[i] != None) && (brightblinders[i].bRenderme) )
	   {
    brightblinders[i].drawscale = 1 + vsize (brightblinders[i].location - location) / 260;
    brightblinders[i].Scaleglow *= 0.983;
  		canvas.DrawActor( brightblinders[i], False, True  );
	   }
	}


   Scale = Canvas.ClipX/256;

   canvas.drawcolor.r = 1;
   canvas.drawcolor.g = 1;
   Canvas.drawcolor.b = 1;
   canvas.Style = ERenderStyle.STY_Translucent;
   Canvas.SetPos(0, 0);
   Canvas.DrawPattern(Texture'hex16', canvas.clipx, canvas.clipy, 0.75);

   //Draw some static noise
   Canvas.SetPos(0, 0);
   canvas.drawcolor.r = 5+(swimcounter*2);
   canvas.drawcolor.g = 5+(swimcounter*2);
   canvas.drawcolor.b = 5+(swimcounter*2);
   Canvas.Style = ERenderStyle.STY_Translucent;
   Canvas.Drawpattern(Texture'Static_a00', Canvas.ClipX, Canvas.ClipY, 0.75);


   Canvas.SetPos(0.5 * Canvas.ClipX - 128 * Scale, 0.5 * Canvas.ClipY - 128 * Scale );
   canvas.Style = ERenderStyle.STY_Modulated;
	Canvas.DrawIcon(Texture'TGAS_nvg16', Scale);

   //Recalculate the new artificial NVG light position
   hitlocation = location - (2 * Vector(viewrotation));
   hitlocation.z += BaseEyeHeight;

   if (  !bNVActive || (NVLight == None) )
	{
        //If the NVG has just been activated, spawn an artificial NVG light
        //and up glow effect of the held weapon (Maybe drop this one, if held wpn.
        //is changed the new weapon wont have these values anyway.
	bNVActive = True;
	NVLight=Spawn(Class'TO_NVLight',self,'none',HitLocation);
	weapon.AmbientGlow=24;
	weapon.ScaleGlow=2.000000;
  //Spawn corona blinders
	for( i=0; i<32; i++ )
	   {
	   brightblinders[i] = Spawn(class'TGAS_BrightBlinder');
    }
	}
   else
	{
        //If an artificial NVG light already exists redo it's position.
	NVLight.SetLocation(HitLocation);
	NVLight.SetRotation(Viewrotation);
	}
   }
  else if (bNVActive)
   {
   //NVG has just been turned off, kill the artificial NVG light
   bNVActive = False;
   NVLight.Destroy();
   weapon.AmbientGlow=0;
   weapon.ScaleGlow=1;
   Tickcount = 0;
 	for( i=0; i<32; i++ )
	   {
	   brightblinders[i].destroy();
    }
  }

}

Function RenderGasEffect( canvas Canvas )
{
  local float scale, col;
  canvas.DrawColor.R = 128;
  canvas.DrawColor.G = 128;
  canvas.DrawColor.B = 128;
  Scale = canvas.ClipX/256;
  canvas.SetPos(0.5 * canvas.ClipX - 128 * Scale, 0.5 * canvas.ClipY - 128 * Scale );
  canvas.Style = ERenderStyle.STY_Modulated;
  If (tri.Teartime > 120)
	canvas.DrawIcon(Texture'gas3', Scale);
  else If (tri.Teartime > 80)
	canvas.DrawIcon(Texture'gas2', Scale);
  else If (tri.Teartime > 40)
	canvas.DrawIcon(Texture'gas1', Scale);
  else if (tri.Teartime > 0)
	canvas.DrawIcon(Texture'gas0', Scale);
  canvas.Style = ERenderStyle.STY_Translucent ;
  if ( tri.TearTime < 235 )
	col = tri.TearTime+20;
  else
	col = 255;
  canvas.DrawColor.R = col;
  canvas.DrawColor.G = ( ( Frand() * col) / 100 );
  canvas.DrawColor.B = ( ( Frand() * col) / 100 );
  canvas.SetPos(0, 0);
  if (tri.teartime > 0)
	canvas.DrawTile(Texture'TileWhite', canvas.ClipX, canvas.ClipY, 0, 0, 32.0, 32.0);
}

Function RenderGasMask( canvas Canvas )
{
  local float scale;
  if ( bGmaskActive && !bShowScores)
    {
    Scale = Canvas.ClipX/256;
    Canvas.Style = ERenderStyle.STY_modulated;
    Canvas.SetPos(0.5 * Canvas.ClipX - 128 * Scale, 0.5 * Canvas.ClipY - 128 * Scale );
    Canvas.DrawIcon(Texture'gasmask', Scale);
    }
}

Function RenderBlackOut( canvas Canvas )
{
  //blackout effect, used when gassed or when NVGs are turned on to create fadein effect
  //Since I couldn't find a way to recreate scaled darkening of the HUD this has been
  //done by using several small greyscale bitmaps with varying dark factor.
  if (bFadeout || bFadein)
  {
  if (bFadeout)
    {
    fadeval -= 1;
    if (fadeval == 0)
	{
	bFadeout = False;
	bFadeIn = True;
	}
    }
  else
    {
    fadeval += 1;
    if (fadeval == 128)
	{
	bFadeout = False;
	bFadeIn = False;
	}
    }
  canvas.Style = ERenderStyle.STY_Modulated;
  Canvas.DrawColor.R = 127;
  Canvas.DrawColor.G = 127;
  Canvas.DrawColor.B = 127;
  Canvas.SetPos(0.00,0.00);
  if (Fadeval < 32)
	Canvas.DrawPattern(Texture'g15', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 40)
	Canvas.DrawPattern(Texture'g14', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 48)
	Canvas.DrawPattern(Texture'g13', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 56)
	Canvas.DrawPattern(Texture'g12', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 64)
	Canvas.DrawPattern(Texture'g11', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 72)
	Canvas.DrawPattern(Texture'g10', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 78)
	Canvas.DrawPattern(Texture'g9', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 84)
	Canvas.DrawPattern(Texture'g8', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 90)
	Canvas.DrawPattern(Texture'g7', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 96)
	Canvas.DrawPattern(Texture'g6', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 102)
	Canvas.DrawPattern(Texture'g5', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 108)
	Canvas.DrawPattern(Texture'g4', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 114)
	Canvas.DrawPattern(Texture'g3', canvas.clipx, canvas.clipy, 1);
  else if (Fadeval < 120)
	Canvas.DrawPattern(Texture'g2', canvas.clipx, canvas.clipy, 1);
  else 
	Canvas.DrawPattern(Texture'g1', canvas.clipx, canvas.clipy, 1);
  }
}

Function PostRenderThermalvision(Canvas canvas)
{
  //Rendmap=2 for Thermal mode
  if ( bHVActive && bszoom)
	{
	RendMap=2;
	}
}

Function AmbientSounds()
{
  if (Deaftime > 0)
	{
	AmbientSound=Sound'fbeffect';
	Soundpitch = 64;
	soundvolume=min (255, 35 * deaftime);
	soundradius=3;
	SoundDampening= 1 - ( deaftime / 10);
	}
  else if (HeadRegion.Zone.bWaterZone)
	{
	AmbientSound=Sound'underwater';
	soundvolume=128;
	soundradius=32;
	SoundDampening=0.25;
  }
  else if (bGmaskActive)
	{
	AmbientSound=Sound'breath';
	soundvolume=128;
	SoundDampening=0.5;
        soundradius=20;
	//Pitch the breathing ambient to the current health
	Soundpitch = 60 + (18 - (health * 0.18) );
	}
  else 
	{
	AmbientSound=none;
	SoundDampening=1;
	}
}

Function WaterRender(canvas canvas)
{
  if (HeadRegion.Zone.bWaterZone)
  {
   if (swimcounter<35)
	swimcounter+=1;
   else
	{
	if (bNVon)
      		ServerNVG(False);
	if (bTGAS_HeatVision)
      		ServerThermal(False);
	}
  }
  else
  {
   if (swimcounter>0)
     swimcounter-=1;
  }
  if ( swimcounter > 0 && (!bscrflash) )
   {
    canvas.Style = ERenderStyle.STY_Translucent ;
    canvas.DrawColor.R = 0.25*(swimcounter);
    canvas.DrawColor.G = 1*(swimcounter);
    canvas.DrawColor.B = 1.5*(swimcounter);
    canvas.SetPos(0, 0);
    canvas.DrawTile(Texture'TileWhite', canvas.ClipX, canvas.ClipY, 0, 0, 32.0, 32.0);
   }
}

Function CheckDeath()
{
 if (health <= 0)
	{
	Blindtime=0;
	AmbientSound=None;
	SoundVolume=128;
	deaftime = 0;
	stuntime=0;
	xforce=0;
	yforce=0;
	ShakeView(0,0,0);
	}
}

event UpdateEyeHeight (float DeltaTime)
{
	super.UpdateEyeHeight (DeltaTime);
	//Change the FOV slightly when using NVG
	if ( bhasnv && bNVon && !bShowScores && !bszoom)
	   {
	    FovAngle=96;
	   }
}

function checks()
{
   Local Bool b;
   local float bits;

   bits = float(ConsoleCommand("get ini:Engine.Engine.ViewportManager FullscreenColorBits"));
   bscrflash = Bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager ScreenFlashes"));
   if (bits != 16)
	bits16=false;
   else
	bits16=true;
   if (bHasGasMask)
	{
	bGmaskActive=False;
	Take_Gasmask_off();
	}
   if ( bNVon )
	ServerNVG(False);
   if ( bTGAS_HeatVision)
	ServerThermal(False);
   SoundDampening=1;
   AmbientSound=None;
   SoundVolume=128;
   swimcounter = 0;
   deaftime = 0;
   stuntime=0;
   xforce=0;
   yforce=0;
   ShakeView(0,0,0);

   if ( Level.Netmode == NM_DedicatedServer )
	return;
   enable ('timer');
	SetTimer(0.1, true);
}

//Functionality that needs to be done at ended round
function CheckEndGame()
{
}

function Endroundcleanup()
{
   local s_GameReplicationInfo GRI;
   local TGAS_ProjgasGren GasGren;

   GRI=s_GameReplicationInfo(GameReplicationInfo);
//   if ( (GRI != None) && GRI.bPreRound && (GRI.RoundNumber != OldRoundNumber) )
   if ( GRI != None)
	{
//	OldRoundNumber = GRI.RoundNumber;
	TRI.Teartime = 0;
	foreach AllActors(class'TGAS_ProjgasGren', GasGren)
		{
		GasGren.Destroy();
		}
	}
  enable ('timer');
  SetTimer(0.1, true);
  checks();
  if ( bHasEB )
	BatLife=250;
  else
	BatLife=175;
}

function RoundEnded ()
{
  Endroundcleanup();
  super.RoundEnded();
}

function ClientRoundEnded ()
{
  Endroundcleanup();
  super.ClientRoundEnded ();
}

exec function EndRound ()
{
  Endroundcleanup();
  ServerEndRound();
}


//The timer function includes some gas functionality
simulated function Timer()
{
   local vector i;

   //Check if we're currently equiping a gas mask
   if (GasMaskEquipDelay > 0)
	{
	if (GasMaskEquipDelay == 1)
	   {
	   //Gas mask is now beeing taken on, set up vars, activate it, and start a breathing ambient
	   SetGasSkin();
	   bIsTyping=False;
	   server_GasanimOff();
	   bGmaskActive=true;
	   }
	GasMaskEquipDelay -= 1;
	}
   //The playerpawn uses the timer when dying:
   if (GetStateName() == 'Dying')
	super.Timer();
   if (tri == none)
	{
	log ("Teargas mutator - warning - TRI dissapeared, respawning...");
	TRI=Spawn(Class'teargas3.TGAS_plyReplInfo',self);
	return;
	}
   //Chances for coughing and get blackouts when gassed:
   If (tri.Teartime > 0)
	{
	If (Frand() <0.14)
		{
		If (Frand() < 0.5)
			{
			PlayOwnedSound(Sound'cough1',SLOT_Talk,1.0, true,600);
			}
		else
			PlayOwnedSound(Sound'cough2', SLOT_Talk, 1.0, true,600);
		ShakeView(1, tri.teartime*6, tri.teartime * 0.2);
		}
	If ( (Frand() <0.03) && (!bFadeout) && (!bFadeIn) )
		{
		bFadeOut = True;
		fadeval = 128;
		}

	}

if ((Deaftime <= 0) && (Ambientsound == Sound'FBEffect') )
	{
	AmbientSound=none;
	SoundDampening=1;
	}
if ((health < 15) && (health > 0) && (!bFadeout) && (!bFadeIn) && (tgmut.ImpactReaction) )
	{
	If (Frand() <0.01)
		{
		bFadeOut = True;
		fadeval = 128;
		}
	}
if (TGInfotimer > 0)
	TGInfotimer -= 1;
if (Stuntime > 4)
  stuntime -= 0.025;
else if (Stuntime > 0)
	Stuntime = 0;

   enable ('timer');
   SetTimer(0.1, true);

If (!tgmut.ImprovedFB)
	return;
if (Blindtime > 1)
  {
  Deaftime = Blindtime+10;
  if (Blindtime > 4)
  	Stuntime = 19;
  }
else
if (Deaftime > 0)
  {
  Deaftime -= 0.2;
  }

}

//Prevent auto corpse spawn:
function Carcass SpawnCarcass ()
{
  if (!binitialized)
	return none;
  super.SpawnCarcass();
  checks();
}

simulated function ServerBuyGasmask (bool eGasmask)
{
	if ( bHasGasmask && !eGasmask )
	{
		Take_Gasmask_off();
		bHasGasmask=False;
		AddMoney(800);
		bGmaskActive=False;
	}
	else if ( !bHasGasmask && eGasmask )
	{
		bHasGasmask=True;
		AddMoney(-800);
	}
}


function BuyGasmask (bool eGasmask)
{
	if ( bHasGasmask && !eGasmask )
		bGmaskActive=False;
  ServerBuyGasmask (eGasmask);
}

simulated function ServerBuyThermal (bool eThermal)
{
	if ( bHasThermal && !eThermal )
	{
		bHasThermal=False;
		ServerThermal(False);
		AddMoney(800);
	}
	else if ( !bHasThermal && eThermal )
	{
		bHasThermal=True;
		AddMoney(-800);
	}
}


function BuyThermal (bool eThermal)
{
	if ( bHasThermal && !eThermal )
		ServerThermal(False);
  ServerBuyThermal (eThermal);
}

simulated function CalculateWeight ()
{
   local float Weight;
   Local Inventory inv;

   If (TGmut.InvWeights)
      {
	foreach AllActors(class'Inventory', inv)
	{
	if ( (inv.owner == self) && (inv.isa('s_Weapon') ) )
	   Weight += s_weapon(inv).WeaponWeight/2;
	}
	if ( (Weapon != None) && Weapon.IsA('S_Weapon') )
	{
		Weight += S_Weapon(Weapon).WeaponWeight/2;
	}
      }
   else
      {
	if ( (Weapon != None) && Weapon.IsA('S_Weapon') )
	{
		Weight += S_Weapon(Weapon).WeaponWeight;
	}
      }
   if ( bNotPlaying )
	return;
   if ( bSpecialItem )
	Weight += Class's_SpecialItem'.Default.Weight;
   if ( HelmetCharge > 0 )
	Weight += 5;
   if ( VestCharge > 0 )
		Weight += 10;
   if ( LegsCharge > 0 )
		Weight += 10;
   if ( bIsCrouching )
	{
	PrePivot.Z=Default.CollisionHeight - CrouchHeight - 2.00;
	Weight += 200;
	}
   else
	PrePivot.Z=0.00;
   if ( Weight > 220 )
		Weight=220.00;

   If (TGmut.MoveDecrease)
      {
	if ( bIsCrouching )
		GroundSpeed=280.00 - Weight - ( min (100, (100 - health) / 3.5) );
	else
		GroundSpeed=280.00 - Weight - ( min (100, (100 - health) / 1.4) );
	AirSpeed=300.00 + Weight;
	AccelRate=2048.00 - Weight - ( (100 - health) * 18 );
	AirControl=0.30 - Weight / 1000;
      }
   else
      {
	if ( bIsCrouching )
		GroundSpeed=280.00 - Weight;
	else
		GroundSpeed=280.00 - Weight;
	AirSpeed=300.00 + Weight;
	AccelRate=2048.00 - Weight;
	AirControl=0.30 - Weight / 1000;
      }

}

event PlayerInput (float DeltaTime)
{
If ((stuntime > 1) && (tgmut.ImpactReaction) )
	{
//	aMouseX *= (130 - DesiredFOV) / 40;
	XForce=XForce + aMouseX * (1 - (stuntime/20) );
	YForce=YForce + aMouseY * (1 - (stuntime/20) );
	aMouseX=XForce;
	aMouseY=YForce;
	XForce *= (stuntime/20);
	YForce *= (stuntime/20);
	}
super.playerinput (DeltaTime);
}

Function NadeStun(float damage)
{
	deaftime = min ( 18, (damage / 4));
	stuntime = min (19, damage / 3.5);
}

function PlayHit (float Damage, Vector HitLocation, name DamageType, Vector Momentum)
{
super.PlayHit (Damage, HitLocation, DamageType, Momentum);
if ((tgmut.Sniperskills) && (bszoom))
		ToggleSZoom();
if (tgmut.ImpactReaction)
	{
	if ((DamageType == 'Explosion') || (DamageType == 'Thunder'))
		ShakeView(min (50,Damage) *0.16,Damage * 15,0.15 * Damage);
	else
		ShakeView(0.15 * min (30,Damage),Damage * 30,0.30 * Damage);
	if (( (DamageType == 'Explosion') || (DamageType == 'Thunder') ) && (health > 0) && (tgmut.ImprovedFB) )
		Nadestun(damage);
	}
CalculateWeight();
}

function CheckBob(float DeltaTime, float Speed2D, vector Y)
{
super.checkbob (Deltatime, Speed2d, Y);
If (weapon.itemname == "Binoculars")
	return;

if ((bszoom) && (tgmut.sniperskills))
	{
	BreathBobTime += 0.1 * DeltaTime;
	if ( bIsCrouching )
		WalkBob.Z += 5 * sin(14 * BreathBobTime);
	else WalkBob.Z += 10 * sin(14 * BreathBobTime);
	}
}

function DrawInfo (canvas canvas)
{
 if (TGInfotimer > 0)
	{
	Canvas.SetPos(Canvas.ClipX-180, 270);
        Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.Font = Canvas.SmallFont;
	If (TGInfotimer > 50)
		{
		Canvas.DrawColor.R = 128;
		Canvas.DrawColor.G = 128;
		Canvas.DrawColor.B = 128;
		}
	else
		{
		Canvas.DrawColor.R = TGInfotimer*2+26;
		Canvas.DrawColor.G = TGInfotimer*2+26;
		Canvas.DrawColor.B = TGInfotimer*2+26;
		}
	Canvas.DrawText("Teargas mutator 3 running");
	Canvas.SetPos(Canvas.ClipX-180, 280);
	Canvas.DrawText("Improved Flashbangs: " $ tgmut.ImprovedFB);
	Canvas.SetPos(Canvas.ClipX-180, 290);
	Canvas.DrawText("Movement Decreasing: "$ tgmut.MoveDecrease);
	Canvas.SetPos(Canvas.ClipX-180, 300);
	Canvas.DrawText("Impact reactions: " $ tgmut.ImpactReaction);
	Canvas.SetPos(Canvas.ClipX-180, 310);
	Canvas.DrawText("Sniper Skills: " $ tgmut.SniperSkills);
	Canvas.SetPos(Canvas.ClipX-180, 320);
	Canvas.DrawText("Teargas nades: " $ tgmut.tearnades);
	Canvas.SetPos(Canvas.ClipX-180, 330);
	Canvas.DrawText("Inventory Weights: " $ TGmut.InvWeights);
	Canvas.SetPos(Canvas.ClipX-180, 340);
	Canvas.DrawText("Nade timers: " $ tgmut.Nadetimer);

	}
}

Function PostRender( canvas Canvas )
{

  if ( (MAmode) && (!bDrawnLogo) )
	MA_DrawLogo(Canvas);
  WaterRender(canvas);
  RenderNightvision(Canvas);
  RenderGasEffect(Canvas);
  RenderGasMask(Canvas);
  If (tgmut.Clientside_thermal_prefference == 0)
  {
  If (PlayerReplicationInfo.Team == 1)
	RenderThermalVision2 (canvas);
  else
	RenderThermalVision (canvas);
  }
  else If (tgmut.Clientside_thermal_prefference == 1)
	RenderThermalVision2 (canvas);
  else
	RenderThermalVision (canvas);
  RenderBlackOut(Canvas);

  // Render buy menu additions
	if ( s_HUD(myHUD) != None && s_HUD(myHUD).bToggleBuymenu )
	{
		if ( !bTGAS_Buymenu )
		{
			if (MAmode)
				s_HUD(MyHud).UserInterface.TOUI_Tool_AddTab(138,Class'TGAS_BuyMenu_MA');
			else
				s_HUD(MyHud).UserInterface.TOUI_Tool_AddTab(138,Class'TGAS_BuyMenu');
			bTGAS_Buymenu=True;
		}
		s_HUD(myHUD).bToggleBuymenu=False;
		s_HUD(myHud).UserInterface.ToggleTab(138);
	}

	if ( myHud != None )	
		myHUD.PostRender(Canvas);
	else if ( (Viewport(Player) != None) && (HUDType != None) )
		myHUD = spawn(HUDType, self);

//  super.PostRender( Canvas );

  PostRenderThermalvision(Canvas);
  AmbientSounds();
  CheckDeath();
  CheckEndGame();
  if ( MAmode)
	DrawMAIcons(Canvas);
  DrawInfo(canvas);
}

function DrawMAIcons (Canvas Canvas)
{
bownsnv = bhasnv;
   if (bTGAS_HeatVision)
	ServerNVG(True);
   MA_DrawIcons (Canvas);
   if (bTGAS_HeatVision)
	ServerNVG(False);
}

function MACalcBatConsumption()
{
BatConsumption=0;	
	
	if ( bNVon )
	{
		BatConsumption-=4;
	}
	if ( bTGAS_HeatVision )
	{
		BatConsumption-=5;
	}
	if ( bHasFL )
	{
		BatConsumption-=3;
	}
	if ( !bNVon && !bHasFL && !bTGAS_HeatVision )
	{
		BatConsumption=6;
	}
}

Function SecondTimer()
{
super.secondtimer();
if ( BatLife <= 0)
	{
	ServerNVG(False);
	ServerThermal(False);
	}
}

/*
function ForceOFF()
{
super.ForceOFF();
	if ( bNVon || bTGAS_HeatVision )
	{
		ClientPlaySound(Sound'NV_off',,True);
	}
}
*/

function Died (Pawn Killer, name DamageType, Vector HitLocation)
{
 gas_off();
 Super.Died(Killer,DamageType,HitLocation);
}

simulated function ResetTime (float nrt)
{
 gas_off();
 super.ResetTime (nrt);
}

simulated function s_ChangeTeam (int Num, int Team, bool bDie)
{
super.s_ChangeTeam (Num, Team, bDie);
orgPlayermodel=num;
}


defaultproperties
{
    TGInfotimer=150
    AmbientGlow=1
    SoundRadius=3
    SoundVolume=128
}
