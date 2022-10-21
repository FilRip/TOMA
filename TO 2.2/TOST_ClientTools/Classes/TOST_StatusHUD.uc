//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_StatusHUD.uc
// VERSION : 1.0
// INFO    : Handles Status Displays, such as Team Info or Weapon Info
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_StatusHUD expands TOST_HUDModule;

// =============================================================================
// Status Info Helpers

var int SWATCount;                                                              // Total Players: S.W.A.T.
var int TerrCount;                                                              // Terrorists
var int HossieCount;                                                            // Hostages
var int SWATAlive;                                                              // Alive Players: S.W.A.T.
var int TerrAlive;                                                              // Terrorists
var int HossieAlive;                                                            // Hostages

var Texture WeaponTexture[23];                                                  // Handler of Texture Classes
var Texture DotTexture;                                                         // Handler of Status Dot

var bool bTexInstalled;                                                         // Debug: Are the tex installed ?
var bool bTexInit;                                                              // Debug: Texture Routines

// =============================================================================
// TOST Engine Functions

// Called by Timer ()
simulated function GetTotalPlayers ()
{
   local s_GameReplicationInfo GRI;

   if ((Player == None) || (Player.GameReplicationInfo == None))
      return;

   GRI = s_GameReplicationInfo(Player.GameReplicationInfo);

   if (GRI == None)
      return;

   TerrCount = GRI.Teams[0].Size;
   SWATCount = GRI.Teams[1].Size;
   HossieCount = GRI.Teams[3].Size;
}

// Called by TOST_HUDMutator.PostRender()
simulated function Render (Canvas Canvas)
{
   DrawTeamInfo(Canvas);
   DrawWeaponInfo(Canvas);

   Super.Render(Canvas);
}

// Draw Team Info
simulated function DrawTeamInfo (Canvas Canvas)
{
   local float X, Y, CX, CY, LX, LY;

   if (Class 'TOST_UserInfo'.default.TeamInfo == 0)
      return;

   CX = Canvas.ClipX;
   CY = Canvas.ClipY;

   Canvas.Style = ERenderStyle.STY_Normal;
   Canvas.Font = HUD.MyFonts.GetSmallFont(CX);

   switch Class 'TOST_UserInfo'.default.TeamInfo
   {
      case 1 :
         X = 7;

         if (TerrCount > 0)
         {
            Y = 160;
            Canvas.DrawColor = RedColor;
            Canvas.TextSize("Terrorists: ", LX, LY);
            Canvas.SetPos(X, Y);
            Canvas.DrawText("Terrorists:");
            Canvas.SetPos(X + LX, Y);
            Canvas.DrawText(TerrAlive @ "(" $ TerrCount $ ")");
         }

         if (SWATCount > 0)
         {
            if (TerrCount > 0)
               Y = 180;
            else
               Y = 160;
            Canvas.DrawColor = BlueColor;
            Canvas.TextSize("S.W.A.T. : ", LX, LY);
            Canvas.SetPos(X, Y);
            Canvas.DrawText("S.W.A.T. :");
            Canvas.SetPos(X + LX, Y);
            Canvas.DrawText(SWATAlive @ "(" $ SWATCount $ ")");
         }

         if ((HossieCount > 0) && Class 'TOST_UserInfo'.default.DisplayHostages)
         {
            if (TerrCount > 0)
            {
               if (SWATCount > 0)
                  Y = 200;
               else
                  Y = 180;
            }
            else
            {
               if (SWATCount > 0)
                  Y = 180;
               else
                  Y = 160;
            }
            Canvas.DrawColor = GreenColor;
            Canvas.TextSize("Hostages: ", LX, LY);
            Canvas.SetPos(X, Y);
            Canvas.DrawText("Hostages:");
            Canvas.SetPos(X + LX, Y);
            Canvas.DrawText(HossieAlive @ "(" $ HossieCount $ ")");
         }
         break;

      case 2 :
         X = (CX - 40);

         if (TerrCount > 0)
         {
            Y = 160;
            Canvas.DrawColor = RedColor;
            Canvas.TextSize("Terrorists: ", LX, LY);
            Canvas.SetPos(X - LX, Y);
            Canvas.DrawText("Terrorists:");
            Canvas.SetPos(X, Y);
            Canvas.DrawText(TerrAlive @ "(" $ TerrCount $ ")");
         }

         if (SWATCount > 0)
         {
            if (TerrCount > 0)
               Y = 180;
            else
               Y = 160;
            Canvas.DrawColor = BlueColor;
            Canvas.TextSize("S.W.A.T. : ", LX, LY);
            Canvas.SetPos(X - LX, Y);
            Canvas.DrawText("S.W.A.T. :");
            Canvas.SetPos(X, Y);
            Canvas.DrawText(SWATAlive @ "(" $ SWATCount $ ")");
         }

         if ((HossieCount > 0) && Class 'TOST_UserInfo'.default.DisplayHostages)
         {
            if (TerrCount > 0)
            {
               if (SWATCount > 0)
                  Y = 200;
               else
                  Y = 180;
            }
            else
            {
               if (SWATCount > 0)
                  Y = 180;
               else
                  Y = 160;
            }
            Canvas.DrawColor = GreenColor;
            Canvas.TextSize("Hostages: ", LX, LY);
            Canvas.SetPos(X - LX, Y);
            Canvas.DrawText("Hostages:");
            Canvas.SetPos(X, Y);
            Canvas.DrawText(HossieAlive @ "(" $ HossieCount $ ")");
         }
         break;
   }
}

// Draw Weapon Info
simulated function DrawWeaponInfo (Canvas Canvas)
{
   local float X, Y, Z, CX, CY, LX, LY, Scale;
   local int i, j, Index;
   local byte Ammo, ColorIndex;
   local s_Weapon Weapon;
   local Texture Texture;
   local bool bReload;

   if ((Class 'TOST_UserInfo'.default.WeaponInfo == 0) || (Player == None) || (Player.Weapon == None))
      return;

   CX = Canvas.ClipX;
   CY = Canvas.ClipY;

   Canvas.Style = ERenderStyle.STY_Normal;
   Canvas.Font = HUD.MyFonts.GetSmallFont(CX);
   Weapon = s_Weapon(Player.Weapon);
   Scale = HUD.Scale;

   switch Class 'TOST_UserInfo'.default.WeaponInfo
   {
      case 1 :
         X = 7; Y = 140;
         Canvas.DrawColor = PurpleColor;
         Canvas.TextSize("Weapon: ", LX, LY);
         Canvas.SetPos(X, Y);
         Canvas.DrawText("Weapon:");
         Canvas.SetPos(X + LX, Y);
         Canvas.DrawText(Weapon.ItemName);
         break;

      case 2 :
         X = CX - 10;
         Y = 140;
         Canvas.DrawColor = PurpleColor;
         Canvas.TextSize(("Weapon:" @ Weapon.ItemName), LX, LY);
         Canvas.SetPos(X - LX, Y);
         Canvas.DrawText("Weapon:" @ Weapon.ItemName);
         break;

      case 3 :
         X = (CX / 2 + 20 * Scale);
         Y = (CY / 2 + 20 * Scale);

         Canvas.DrawColor = PurpleColor;
         Canvas.TextSize("Weapon: ", LX, LY);
         Canvas.SetPos(X, Y);
         Canvas.DrawText("Weapon:");

         X = (CX / 2 + LX + 20 * Scale);

         Canvas.SetPos(X, Y);
         Canvas.DrawText(Weapon.ItemName);
         break;

      case 4 :
         if (bTexInstalled)
         {
            i = GetWeaponCount();
            j = 0;
            Y = (CY - 152 * Scale);

            Index = 1;

            do
            {
               Weapon = GetWeaponByIndex(Index);

               if (Weapon != None)
               {
                  X = ((200 * Scale) + ((CX - (512 * Scale)) / (i - 1)) * j);
                  ++ j;

                  Texture = GetWeaponTexture(Weapon);
                  Ammo = GetAmmo(Weapon);

                  if (Player.Weapon == Weapon)
                  {
                     ColorIndex = 255;
                     bReload = Weapon.bReloadingWeapon;
                  }
                  else
                  {
                     ColorIndex = 128;
                     bReload = False;
                  }

                  Canvas.DrawColor.R = (ColorIndex * (1 - Ammo));
                  Canvas.DrawColor.G = (ColorIndex * Ammo);
                  Canvas.DrawColor.B = 0;
                  Canvas.DrawColor.A = 0;

                  Canvas.Style = ERenderStyle.STY_Translucent;
                  Canvas.SetPos(X, Y);
                  Canvas.DrawIcon(Texture, Scale);

                  if (!bReload)
                  {
                     Ammo = GetClip(Weapon);

                     Canvas.DrawColor.R = (ColorIndex * (1 - Ammo));
                     Canvas.DrawColor.G = (ColorIndex * Ammo);
                     Canvas.DrawColor.B = 0;
                     Canvas.DrawColor.A = 0;
                  }
                  else
                  {
                     Canvas.DrawColor.R = 0;
                     Canvas.DrawColor.G = 0;
                     Canvas.DrawColor.B = 255;
                     Canvas.DrawColor.A = 0;
                  }

                  X += ((Scale * 128) - 96);
                  Z = (Y - 96);

                  Canvas.bNoSmooth = False;
                  Canvas.SetPos(X, Z);
                  Canvas.DrawIcon(DotTexture, 3);
                  Canvas.Style = ERenderStyle.STY_Normal;
               }

               ++ Index;
            } until ((j >= i) || (Index > 10))
         }
         break;
   }
}

// =============================================================================
// Texture Handling

// Loads all textures
simulated function LoadTextures ()
{
   local int Test;

   WeaponTexture[0] = Texture (DynamicLoadObject("TOSTTex.Glock", Class 'Texture'));
   WeaponTexture[1] = Texture (DynamicLoadObject("TOSTTex.DEagle", Class 'Texture'));
   WeaponTexture[2] = Texture (DynamicLoadObject("TOSTTex.Mac10", Class 'Texture'));
   WeaponTexture[3] = Texture (DynamicLoadObject("TOSTTex.MP5Navy", Class 'Texture'));
   WeaponTexture[4] = Texture (DynamicLoadObject("TOSTTex.Mossberg", Class 'Texture'));
   WeaponTexture[5] = Texture (DynamicLoadObject("TOSTTex.Benelli", Class 'Texture'));
   WeaponTexture[6] = Texture (DynamicLoadObject("TOSTTex.AK47", Class 'Texture'));
   WeaponTexture[7] = Texture (DynamicLoadObject("TOSTTex.Steyr", Class 'Texture'));
   WeaponTexture[8] = Texture (DynamicLoadObject("TOSTTex.FAMAS", Class 'Texture'));
   WeaponTexture[9] = Texture (DynamicLoadObject("TOSTTex.HKsr9", Class 'Texture'));
   WeaponTexture[10] = Texture (DynamicLoadObject("TOSTTex.HK33", Class 'Texture'));
   WeaponTexture[11] = Texture (DynamicLoadObject("TOSTTex.PSG1", Class 'Texture'));
   WeaponTexture[12] = Texture (DynamicLoadObject("TOSTTex.HE", Class 'Texture'));
   WeaponTexture[13] = Texture (DynamicLoadObject("TOSTTex.Flash", Class 'Texture'));
   WeaponTexture[14] = Texture (DynamicLoadObject("TOSTTex.Concussion", Class 'Texture'));
   WeaponTexture[15] = Texture (DynamicLoadObject("TOSTTex.PH85", Class 'Texture'));
   WeaponTexture[16] = Texture (DynamicLoadObject("TOSTTex.Saiga", Class 'Texture'));
   WeaponTexture[17] = Texture (DynamicLoadObject("TOSTTex.MP5kPDW", Class 'Texture'));
   WeaponTexture[18] = Texture (DynamicLoadObject("TOSTTex.Berreta", Class 'Texture'));
   WeaponTexture[19] = Texture (DynamicLoadObject("TOSTTex.Smoke", Class 'Texture'));
   WeaponTexture[20] = Texture (DynamicLoadObject("TOSTTex.M4", Class 'Texture'));
   WeaponTexture[21] = Texture (DynamicLoadObject("TOSTTex.OICW", Class 'Texture'));
   WeaponTexture[22] = Texture (DynamicLoadObject("TOSTTex.Knife", Class 'Texture'));

   DotTexture = Texture (DynamicLoadObject("Botpack.CHair8", Class 'Texture'));

   bTexInit = True;

   Test = Rand(22);

   if (WeaponTexture[Test] == None)
   {
      Module.ClientDebugLog("Weapon Textures are not installed - Rendering disabled", 'Error', Self);
      AddSimpleMsg(ActorID @ "Weapon Textures are not installed - Rendering disabled",0);
   }
   else
      bTexInstalled = True;
}

// Finds the Weapon Texture
simulated function Texture GetWeaponTexture (s_Weapon Weapon)
{
   local int Index;

   Index = GetWeaponIndex(Weapon);

   if (Index != -1)
      return WeaponTexture[Index];
   else
      return None;
}

// =============================================================================
// Weapon Handling

simulated function int GetWeaponCount ()
{
   local Inventory Inventory;
   local int i, j;

   for (Inventory = Player.Inventory; Inventory != None; Inventory = Inventory.Inventory)
   {
      if (Inventory.IsA('s_Weapon') && !Inventory.IsA('s_C4'))
         ++ i;

      if (++ j > 23)
         break;
   }

   return i;
}

simulated function int GetAmmo (s_Weapon Weapon)
{
   local int ClipSize, ClipAmmo;

   if (Weapon.IsA('TO_Grenade') || Weapon.IsA('s_Knife'))
      return 1;
   else
   {
      ClipSize = ((Weapon.MaxClip + 1) * Weapon.ClipSize);
      ClipAmmo = ((Weapon.RemainingClip * Weapon.ClipSize) + Weapon.ClipAmmo);

      return (ClipAmmo / ClipSize);
   }

   return 0;
}

simulated function int GetClip (s_Weapon Weapon)
{
   local int ClipSize, ClipAmmo;

   if (Weapon.IsA('TO_Grenade') || Weapon.IsA('s_Knife'))
      return 1;
   else
   {
      ClipSize = Weapon.ClipSize;
      ClipAmmo = Weapon.ClipAmmo;

      return (ClipAmmo / ClipSize);
   }

   return 0;
}

simulated function s_Weapon GetWeaponByIndex (int Index)
{
   local Inventory Inventory;
   local s_Weapon Weapon;
   local int i;

   for (Inventory = Player.Inventory; Inventory != None; Inventory = Inventory.Inventory)
   {
      if (Inventory.IsA('s_Weapon') && !Inventory.IsA('s_C4'))
      {
         Weapon = s_Weapon(Inventory);

         if (Weapon != None)
         {
            if ((Weapon.InventoryGroup == Index) && !Weapon.IsA('s_OICW'))
               return Weapon;

            if ((Index == 6) && Weapon.IsA('s_OICW'))
               return Weapon;
         }
      }

      if (++ i > 23)
         break;
   }

   return None;
}

simulated function int GetWeaponIndex (s_Weapon Weapon)
{
   local string WeaponClass;
   local int i, j;

   WeaponClass = (string(Weapon.Class));

   j = -1;

   if (WeaponClass != "")
   {
      if (WeaponClass ~= "s_SWAT.s_OICW")
         j = 21;
      else if (WeaponClass ~= "s_SWAT.s_Knife")
         j = 22;
      else
      {
         for (i = 0; i < 32; ++ i)
         {
            if (Class 'TO_WeaponsHandler'.default.WeaponStr[i] ~= WeaponClass)
            {
               j = i;
               break;
            }
         }
      }
   }

   return j;
}

// =============================================================================
// Engine Specific Functions

// Called after a specific delay
simulated function Timer ()
{
   local Pawn Pawn;

   // Reset 'Total' Count

   SWATCount = 0;
   TerrCount = 0;
   HossieCount = 0;
   GetTotalPlayers();

   // Reset 'Alive' Count

   SWATAlive = 0;
   TerrAlive = 0;
   HossieAlive = 0;

   // Start the Search
   foreach AllActors (Class 'Pawn', Pawn)
   {
      if ((Pawn != None) && (Pawn.PlayerReplicationInfo != None))
      {
         switch Pawn.PlayerReplicationInfo.Team
         {
            case 0 :                                                            // Terrorist
               if (Pawn.Health > 0)
                  ++ TerrAlive;                                                 // Increase alive count
               break;

            case 1 :                                                            // Special Forces
               if (Pawn.Health > 0)
                  ++ SWATAlive;                                                 // Increase alive count
               break;

            default :                                                           // Hostages
               if (Pawn.Health > 0)
                  ++ HossieAlive;                                               // Increase alive count
               break;
         }
      }
   }

   SetTimer (2 * FRand(), False);                                               // Run Timer() on Random occasions

   if (!bTexInit)
      LoadTextures();
}

// =============================================================================
// Initialization

// Called before Initialziation
simulated function Initialize ()
{
   SetTimer (5, False);                                                         // Run Timer() on Random occasions

   Super.Initialize();                                                          // Call Super
}

// =============================================================================
// Default Properties

defaultproperties
{
   ActorID="TOST Status HUD:"
}
