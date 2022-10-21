//------------------------------------------------------------------------------
// PROJECT : Tactical Ops ServerAdmin Tool
// FILE    : TOST_HUDModule.uc
// VERSION : 1.0
// INFO    : Handles Message displaying and other GFX
// AUTHOR  : Xian
//------------------------------------------------------------------------------
// CHANGES :
// v1.0     + Initial version
//------------------------------------------------------------------------------

class TOST_HUDModule expands TOST_Module;

// =============================================================================
// Message Helpers

var struct StructSM
{
   var color DrawColor;
   var string Message;
   var float LifeTime;
   var float FadeOutTime;
   var bool bCleared;
} SimpleMessage[4];                                                             // Pointer to Simple Messages

var struct StructCM
{
   var float PosX, PosY;
   var color DrawColor;
   var string Message;
   var float LifeTime;
   var float FadeOutTime;
   var bool bCleared;
} ComplexMessage[4];                                                            // Pointer to Complex Messages

var Font Font;                                                                  // Font Pointer

var color PurpleColor, GreenColor, WhiteColor, BlueColor, GoldColor, RedColor;  // Colors

// =============================================================================
// Init Options

var float InternalTick;                                                         // Message Tick
var bool bInitialized;                                                          // Us the HUD Module Initialized ?

// =============================================================================
// Attachments

var s_Player Player;                                                            // Pointer to the Player Owner
var s_HUD HUD;                                                                  // Pointer to the HUD Owner
var TOST_HUDModule NextModule;                                                  // Pointer to the Next Module
var TOST_ClientModule Module;                                                   // Pointer to the Module Owner

// =============================================================================
// TOST Engine Functions

// Called by TOST_HUDMutator.PostRender()
simulated function Render (Canvas Canvas)
{
   if (!bInitialized || (HUD == None))
      return;

   if (NextModule != None)
      NextModule.Render(Canvas);

   RenderSimpleMessage(Canvas);
   RenderComplexMessage(Canvas);
}

// =============================================================================
// Engine Specific Functions

// Called every frame
simulated function Tick (float Ticks)
{
   local int i;

   if (!bInitialized)
      return;

   InternalTick += (Ticks * 40);

   for (i = 0; i < 4; ++ i)
   {
      if (SimpleMessage[i].Message != "")
      {
         SimpleMessage[i].FadeOutTime = (FMax(0, SimpleMessage[i].FadeOutTime - Ticks));

         if (SimpleMessage[i].bCleared)
            ClearSimpleMessage(SimpleMessage[i]);
      }

      if (ComplexMessage[i].Message != "")
      {
         ComplexMessage[i].FadeOutTime = (FMax(0, ComplexMessage[i].FadeOutTime - Ticks));

         if (ComplexMessage[i].bCleared)
            ClearComplexMessage(ComplexMessage[i]);
      }
   }
}

// =============================================================================
// Message Handling

// Display a Simple Message
simulated function RenderSimpleMessage (Canvas Canvas)
{
   local int i, j;
   local float MsgTick;
   local string Text;
   local string DrawnText;
   local float FadeOut;
   local color FadeColor;

   for (i = 0; i < 4; ++ i)
      if (SimpleMessage[i].Message != "")
      {
         FadeOut = (SimpleMessage[i].FadeOutTime / 7);
         FadeColor = (SimpleMessage[i].DrawColor * FadeOut);
         MsgTick = (InternalTick - SimpleMessage[i].LifeTime);

         if ((MsgTick) <= (750 + (Len(SimpleMessage[i].Message))))
         {
             if (MsgTick < (Len(SimpleMessage[i].Message)))
             {
                Text = (Left(SimpleMessage[i].Message, MsgTick));

                for (j = 0; j < 5; ++ j)
                   Text = (Text $ (Chr(Asc(Mid(SimpleMessage[i].Message, MsgTick + 5 - j, 1)) - j)));

                DrawnText = ("[>" @ Text $ "_");
             }
             else
                DrawnText = ("[>" @ SimpleMessage[i].Message);

             if (FadeOut < 0.25)
             {
                Canvas.Style = ERenderStyle.STY_Translucent;
                SimpleMessage[i].bCleared = True;
             }
             else
                Canvas.Style = ERenderStyle.STY_Normal;

             Canvas.SetPos(Canvas.ClipX * 0.15, Canvas.ClipY * (80 - i * 2) / 100);
             Canvas.Font = Font;
             Canvas.DrawColor = FadeColor;
             Canvas.DrawText(DrawnText);
          }
      }
}

// Display a Complex Message
simulated function RenderComplexMessage (Canvas Canvas)
{
   local int i, j;
   local float MsgTick;
   local string Text;
   local string DrawnText;
   local float FadeOut;
   local color FadeColor;
   local float Xpos, Ypos;

   for (i = 0; i < 4; ++ i)
      if (ComplexMessage[i].Message != "")
      {
         FadeOut = (ComplexMessage[i].FadeOutTime / 7);
         FadeColor = (ComplexMessage[i].DrawColor * FadeOut);
         MsgTick = (InternalTick - ComplexMessage[i].LifeTime);
         Xpos = ComplexMessage[i].PosX;
         Ypos = ComplexMessage[i].PosY;

         if (MsgTick <= (750 + (Len(ComplexMessage[i].Message))))
         {
             if (MsgTick < (Len(ComplexMessage[i].Message)))
             {
                Text = (Left(ComplexMessage[i].Message, MsgTick));

                for (j = 0; j < 5; ++ j)
                   Text = (Text $ (Chr(Asc(Mid(ComplexMessage[i].Message, MsgTick + 5 - j, 1)) - j)));

                DrawnText = ("[>" @ Text $ "_");
             }
             else
                DrawnText = ("[>" @ ComplexMessage[i].Message);

             if (FadeOut < 0.25)
             {
                Canvas.Style = ERenderStyle.STY_Translucent;
                ComplexMessage[i].bCleared = True;
             }
             else
                Canvas.Style = ERenderStyle.STY_Normal;

             Canvas.SetPos(Xpos, (YPos * (i * 2)));
             Canvas.Font = Font;
             Canvas.DrawColor = FadeColor;
             Canvas.DrawText(DrawnText);
          }
      }
}

// Remove a Simple Message
simulated function ClearSimpleMessage (out StructSM Message)
{
   Message.Message = "";
   Message.LifeTime = 0;
   Message.FadeOutTime = 0;
   Message.bCleared = False;
   Message.DrawColor.R = 0;
   Message.DrawColor.G = 0;
   Message.DrawColor.B = 0;
   Message.DrawColor.A = 0;
}

// Remove a Complex Message
simulated function ClearComplexMessage (out StructCM Message)
{
   Message.Message = "";
   Message.LifeTime = 0;
   Message.FadeOutTime = 0;
   Message.bCleared = False;
   Message.DrawColor.R = 0;
   Message.DrawColor.G = 0;
   Message.DrawColor.B = 0;
   Message.DrawColor.A = 0;
   Message.PosX = 0;
   Message.PosY = 0;
}

// Adds a simple message
simulated function AddSimpleMsg (string Event, optional byte ColorType)
{
   local int i;
   local color DrawColor;

   if (Event == "")
      return;

   DrawColor = GetColor(ColorType);

   for (i = 3; i > 0; -- i)
   {
      SimpleMessage[i].Message = SimpleMessage[i - 1].Message;
      SimpleMessage[i].LifeTime = SimpleMessage[i - 1].LifeTime;
      SimpleMessage[i].FadeOutTime = SimpleMessage[i - 1].FadeOutTime;
      SimpleMessage[i].bCleared = SimpleMessage[i - 1].bCleared;
      SimpleMessage[i].DrawColor = SimpleMessage[i - 1].DrawColor;
   }

   SimpleMessage[0].Message = Event;
   SimpleMessage[0].FadeOutTime = 7;
   SimpleMessage[0].DrawColor = DrawColor;

   if (50 * (InternalTick - SimpleMessage[1].LifeTime) < 0.5)
      SimpleMessage[0].LifeTime += 1;
   else
      SimpleMessage[0].LifeTime = InternalTick;
}

// Adds a complex message
simulated function AddComplexMsg (string Event, float Xpos, float Ypos, optional byte ColorType)
{
   local int i;
   local color DrawColor;

   if (Event == "")
      return;

   DrawColor = GetColor(ColorType);

   for (i = 3; i > 0; -- i)
   {
      ComplexMessage[i].Message = ComplexMessage[i - 1].Message;
      ComplexMessage[i].LifeTime = ComplexMessage[i - 1].LifeTime;
      ComplexMessage[i].FadeOutTime = ComplexMessage[i - 1].FadeOutTime;
      ComplexMessage[i].bCleared = ComplexMessage[i - 1].bCleared;
      ComplexMessage[i].DrawColor = ComplexMessage[i - 1].DrawColor;
      ComplexMessage[i].PosX = ComplexMessage[i - 1].PosX;
      ComplexMessage[i].PosY = ComplexMessage[i - 1].PosY;
   }

   ComplexMessage[0].Message = Event;
   ComplexMessage[0].FadeOutTime = 7;
   ComplexMessage[0].DrawColor = DrawColor;
   ComplexMessage[0].PosX = Xpos;
   ComplexMessage[0].PosY = Ypos;

   if (50 * (InternalTick - ComplexMessage[1].LifeTime) < 0.5)
      ComplexMessage[0].LifeTime += 1;
   else
      ComplexMessage[0].LifeTime = InternalTick;
}

// Selects a Color, depending on its Index
simulated function color GetColor (byte Type)
{
   switch Type
   {
      case 0 : return WhiteColor; break;
      case 1 : return BlueColor; break;
      case 2 : return GoldColor; break;
      case 3 : return GreenColor; break;
      case 4 : return PurpleColor; break;
      case 5 : return RedColor; break;
   }
}

// =============================================================================
// Message Handling

// Checks if a specific Module is Attached
simulated function bool IsAttached (TOST_HUDModule HUDModule)
{
   local TOST_HUDModule Module;

   foreach AllActors (Class 'TOST_HUDModule', Module)
      if (Module == HUDModule)
         return True;

   return False;
}

// =============================================================================
// Initialization

// Called before Initialziation
simulated function Initialize ()
{
   if (bInitialized)
      return;

   InternalTick = 1.25;
   Font = Font(DynamicLoadObject("LadderFonts.UTLadder14", Class'Font'));
   bInitialized = True;
}

// =============================================================================
// Default Properties

defaultproperties
{
   RedColor=(R=235,G=60,B=60,A=0)
   GreenColor=(R=0,G=235,B=0,A=0)
   BlueColor=(R=10,G=50,B=235,A=0)
   GoldColor=(R=235,G=235,B=50,A=0)
   PurpleColor=(R=235,G=10,B=235,A=0)
   WhiteColor=(R=255,G=255,B=255,A=0)

   NetPriority=2.5
   ActorID="Unknown TOST HUD Module:"
}
