//-----------------------------------------------------------
//    DialogClientWindow KeyBinder
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbDCWKeyBinder expands UWindowDialogClientWindow
    config;

#exec TEXTURE IMPORT NAME=SuperTeamLogo FILE=Textures\superteamlogo.pcx  MIPS=OFF
#exec OBJ LOAD FILE=..\TacticalOps\Sounds\VoiceFemaleSF1.uax PACKAGE=VoiceFemaleSF1
#exec OBJ LOAD FILE=..\TacticalOps\Sounds\VoiceMaleSF1.uax PACKAGE=VoiceMaleSF1
#exec OBJ LOAD FILE=..\TacticalOps\Sounds\VoiceFemaleT1.uax PACKAGE=VoiceFemaleT1
#exec OBJ LOAD FILE=..\TacticalOps\Sounds\VoiceMaleT1.uax PACKAGE=VoiceMaleT1

//var UBrowserMainWindow      BrowserWindow;
//var config string           UBrowserClassName;

//==================================================
//var string						ServerListClassName;
//var class<UBrowserServerList>	ServerListClass;

//var UBrowserServerListFactory	Factory;
//var UBrowserServerList			PingedList;
//var UBrowserServerList			UnpingedList;

//enum EPingState
//{
//	PS_QueryServer,
//	PS_QueryFailed,
//	PS_Pinging,
//	PS_RePinging,
//	PS_Done
//};
//
//var EPingState					PingState;
//var string                      ErrorString;
//var bool						bNoSort;

//==================================================
enum EMsgBoxMode
{
    mbmNone,
	mbmConsoleKey,
	mbmSpeechKey,
	mbmUseKey
};

enum EVoiceType
{
    vtNone,
    vtFemaleT,
	vtMaleT,
	vtFemaleSF,
	vtMaleSF
};

enum EKeyboardLayout
{
    klDanish,
    klEnglishUS,
    klFinnish,
    klFrenchBelgium,
    klFrenchCanada,
    klFrenchFrance,
    flFrenchSwitzerland,
    klGerman,
    klItalian,
    klNorwegian,
    klPortugues,
    klSpanish,
    klSwedish
};

const  csbtnBind=900;
const  csbtnClear=901;
const  csbtnClearBind=902;
const  csbtnTest=903;
const  csbtnCustomAdd=904;
const  csbtnCustomDelete=905;
//const  csbtnServer=906;
const  csbtnVoiceTFemale=907;
const  csbtnVoiceTMale=908;
const  csbtnVoiceSFFemale=909;
const  csbtnVoiceSFMale=910;

var UWindowSmallButton      btns[139];
var UWindowSmallButton      btnVoices[4];
var UWindowSmallButton      btnBind;
var UWindowSmallButton      btnClear;
var UWindowSmallButton      btnClearBind;
var UWindowSmallButton      btnCustomAdd;
var UWindowSmallButton      btnCustoms[2];
var UWindowSmallButton      btnTest;
var UWindowSmallButton      btnServer;
var UWindowCheckBox         chkNumLock;
var UWindowComboControl     cboCategory;
var UWindowComboControl     cboKeyboard;
var stkbGridCommands        grdCommands;

var stkbEditControl         edcNewBinding;

var stkbRCMOptions          rcmOptions;
var stkbCommandList         clCommands;

var float                   m_fTopLower;

var string                  m_sCurrentKeyBinding;
var string                  m_sNewKeyBinding;
var string                  m_sSelectedKeyName;
var int                     m_iSelectedKeyCode;
var string                  m_sDebugInfo;

var string                  m_asCategories[8];
var string                  m_asKeyboards[13];

var config bool             mc_bNumLock;
var config int              mc_iSelectedKeyboardLayout;
var config int              mc_lSelectedCategory;
var config string           mc_asCustomCommands[255];
var config int              mc_lColumn1Width;
var config int              mc_lColumn2Width;

var sound                   sndVoicesFemaleT[43];
var sound                   sndVoicesMaleT[43];
var sound                   sndVoicesFemaleSF[43];
var sound                   sndVoicesMaleSF[43];

var UWindowMessageBox       MsgBox;
var EMsgBoxMode             m_eMsgBoxMode;

//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//
//          O V E R R I D E   F U N C T I O N S
//
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//------------------------------------------
//       Created (Override)
//------------------------------------------
function Created()
{
    local float ftop;
    local int   i;

    super.Created();

    clCommands = new class'stkbCommandList';
    clCommands.SetupSentinel();

    //---------------------------------------------------------
    //                         KEYBOARD
    //---------------------------------------------------------
    /*---- Top Row ----*/
    fTop = 16;
    btns[0]  = CreateButton( 16, fTop, 24, "Esc",      27);
    btns[1]  = CreateButton( 56, fTop, 24, "F1",      112);
    btns[2]  = CreateButton( 80, fTop, 24, "F2",      113);
    btns[3]  = CreateButton(104, fTop, 24, "F3",      114);
    btns[4]  = CreateButton(128, fTop, 24, "F4",      115);

    btns[5]  = CreateButton(164, fTop, 24, "F5",      116);
    btns[6]  = CreateButton(188, fTop, 24, "F6",      117);
    btns[7]  = CreateButton(212, fTop, 24, "F7",      118);
    btns[8]  = CreateButton(236, fTop, 24, "F8",      119);

    btns[9]  = CreateButton(272, fTop, 24, "F9",      120);
    btns[10] = CreateButton(296, fTop, 24, "F10",     121);
    btns[11] = CreateButton(320, fTop, 24, "F11",     122);
    btns[12] = CreateButton(344, fTop, 24, "F12",     123);

    btns[13] = CreateButton(380, fTop, 24, "PrScr",    44);
    btns[14] = CreateButton(404, fTop, 24, "ScrLck",  145);
    btns[15] = CreateButton(428, fTop, 24, "Pause",    19);

    /*---- Second Row ----*/
    fTop = 44;
    btns[16] = CreateButton( 16, fTop, 24, "'",       192);
    btns[17] = CreateButton( 40, fTop, 24, "1",        49);
    btns[18] = CreateButton( 64, fTop, 24, "2",        50);
    btns[19] = CreateButton( 88, fTop, 24, "3",        51);
    btns[20] = CreateButton(112, fTop, 24, "4",        52);
    btns[21] = CreateButton(136, fTop, 24, "5",        53);
    btns[22] = CreateButton(160, fTop, 24, "6",        54);
    btns[23] = CreateButton(184, fTop, 24, "7",        55);
    btns[24] = CreateButton(208, fTop, 24, "8",        56);
    btns[25] = CreateButton(232, fTop, 24, "9",        57);
    btns[26] = CreateButton(256, fTop, 24, "0",        48);
    btns[27] = CreateButton(280, fTop, 24, "-",       189);
    btns[28] = CreateButton(304, fTop, 24, "=",       187);
    btns[29] = CreateButton(328, fTop, 40, "Back",      8);

    btns[30] = CreateButton(380, fTop, 24, "Insert",   45);
    btns[31] = CreateButton(404, fTop, 24, "Home",     36);
    btns[32] = CreateButton(428, fTop, 24, "PgUp",     33);

    btns[33] = CreateButton(464, fTop, 24, "NumLock", 144);
    btns[34] = CreateButton(488, fTop, 24, "/",       111);
    btns[35] = CreateButton(512, fTop, 24, "*",       106);
    btns[36] = CreateButton(536, fTop, 24, "-",       109);

    /*---- Third Row ----*/
    fTop = 60;
    btns[37] = CreateButton( 16, fTop, 40, "Tab",       9);
    btns[38] = CreateButton( 56, fTop, 24, "Q",        81);
    btns[39] = CreateButton( 80, fTop, 24, "W",        87);
    btns[40] = CreateButton(104, fTop, 24, "E",        69);
    btns[41] = CreateButton(128, fTop, 24, "R",        82);
    btns[42] = CreateButton(152, fTop, 24, "T",        84);
    btns[43] = CreateButton(176, fTop, 24, "Y",        89);
    btns[44] = CreateButton(200, fTop, 24, "U",        85);
    btns[45] = CreateButton(224, fTop, 24, "I",        73);
    btns[46] = CreateButton(248, fTop, 24, "O",        79);
    btns[47] = CreateButton(272, fTop, 24, "P",        80);
    btns[48] = CreateButton(296, fTop, 24, "[",       219);
    btns[49] = CreateButton(320, fTop, 24, "]",       221);
    btns[50] = CreateButton(344, fTop, 24, "\\",      220);

    btns[51] = CreateButton(380, fTop, 24, "Delete",   46);
    btns[52] = CreateButton(404, fTop, 24, "End",      35);
    btns[53] = CreateButton(428, fTop, 24, "PgDn",     34);

    btns[54] = CreateButton(464, fTop, 24, "7",       103);
    btns[55] = CreateButton(488, fTop, 24, "8",       104);
    btns[56] = CreateButton(512, fTop, 24, "9",       105);
    btns[57] = CreateButton(536, fTop + 8, 24, "+",   107);

    /*---- Fourth Row ----*/
    fTop = 76;
    btns[58] = CreateButton( 16, fTop, 48, "Caps Lock",20);
    btns[59] = CreateButton( 64, fTop, 24, "A",        65);
    btns[60] = CreateButton( 88, fTop, 24, "S",        83);
    btns[61] = CreateButton(112, fTop, 24, "D",        68);
    btns[62] = CreateButton(136, fTop, 24, "F",        70);
    btns[63] = CreateButton(160, fTop, 24, "G",        71);
    btns[64] = CreateButton(184, fTop, 24, "H",        72);
    btns[65] = CreateButton(208, fTop, 24, "J",        74);
    btns[66] = CreateButton(232, fTop, 24, "K",        75);
    btns[67] = CreateButton(256, fTop, 24, "L",        76);
    btns[68] = CreateButton(280, fTop, 24, ";",       186);
    btns[69] = CreateButton(304, fTop, 24, "'",       222);
    btns[70] = CreateButton(328, fTop, 40, "Enter",    13);

    btns[71] = CreateButton(464, fTop, 24, "4",       100);
    btns[72] = CreateButton(488, fTop, 24, "5",       101);
    btns[73] = CreateButton(512, fTop, 24, "6",       102);

    /*---- Fifth Row ----*/
    fTop = 92;
    btns[74] = CreateButton( 16, fTop, 56, "Shift",    16);
    btns[75] = CreateButton( 72, fTop, 24, "Z",        90);
    btns[76] = CreateButton( 96, fTop, 24, "X",        88);
    btns[77] = CreateButton(120, fTop, 24, "C",        67);
    btns[78] = CreateButton(144, fTop, 24, "V",        86);
    btns[79] = CreateButton(168, fTop, 24, "B",        66);
    btns[80] = CreateButton(192, fTop, 24, "N",        78);
    btns[81] = CreateButton(216, fTop, 24, "M",        77);
    btns[82] = CreateButton(240, fTop, 24, ",",       188);
    btns[83] = CreateButton(264, fTop, 24, ".",       190);
    btns[84] = CreateButton(288, fTop, 24, "/",       191);
    btns[85] = CreateButton(312, fTop, 56, "Shift",    16);

    btns[86] = CreateButton(404, fTop, 24, "u",        38);

    btns[87] = CreateButton(464, fTop, 24, "1",        97);
    btns[88] = CreateButton(488, fTop, 24, "2",        98);
    btns[89] = CreateButton(512, fTop, 24, "3",        99);
    btns[90] = CreateButton(536, fTop + 8, 24, "Enter",13);

    /*---- Bottom Row ----*/
    fTop = 108;
    btns[91] = CreateButton( 16, fTop, 36, "Ctrl",     17);
    btns[92] = CreateButton( 52, fTop, 36, "Win",      91);
    btns[93] = CreateButton( 88, fTop, 36, "Alt",      18);
    btns[94] = CreateButton(124, fTop, 100, "",        32);
    btns[95] = CreateButton(224, fTop, 36, "Alt",      18);
    btns[96] = CreateButton(260, fTop, 36, "Win",      92);
    btns[97] = CreateButton(296, fTop, 36, "Menu",     93);
    btns[98] = CreateButton(332, fTop, 36, "Ctrl",     17);

    btns[99] =  CreateButton(380, fTop, 24, "l",       37);
    btns[100] = CreateButton(404, fTop, 24, "d",       40);
    btns[101] = CreateButton(428, fTop, 24, "r",       39);

    btns[102] = CreateButton(464, fTop, 48, "0",       96);
    btns[103] = CreateButton(512, fTop, 24, ".",      110);

    //---------------------------------------------------------
    //           SET THE TOP FOR THE LOWER PART
    //---------------------------------------------------------
    m_fTopLower = 132;

    //---------------------------------------------------------
    //                         MOUSE
    //---------------------------------------------------------
    /*---- Wheel ----*/
    btns[104] = CreateButton(76, m_fTopLower + 18, 24, "u", 236);
    btns[105] = CreateButton(76, m_fTopLower + 34, 24, "d", 237);

    /*---- Buttons ----*/
    ftop = m_fTopLower + 62;
    btns[106] = CreateButton(52,  ftop, 24, "L", 1);
    btns[107] = CreateButton(76,  ftop, 24, "M", 4);
    btns[108] = CreateButton(100, ftop, 24, "R", 2);

    /*---- Axis ----*/
    ftop = m_fTopLower + 94;
    btns[135] = CreateButton(28, ftop, 24, "X", 228);
    btns[136] = CreateButton(52, ftop, 24, "Y", 229);
    btns[137] = CreateButton(76, ftop, 24, "Z", 230);
    btns[138] = CreateButton(100, ftop, 24, "W", 231);

    //---------------------------------------------------------
    //                       JOYSTICK
    //---------------------------------------------------------
    /*---- POV ----*/
    btns[109] = CreateButton(416, m_fTopLower + 26, 24, "l", 242);
    btns[110] = CreateButton(440, m_fTopLower + 18, 24, "u", 240);
    btns[111] = CreateButton(464, m_fTopLower + 26, 24, "r", 243);
    btns[112] = CreateButton(440, m_fTopLower + 34, 24, "d", 241);

    /*---- Buttons 1-6 ----*/
    ftop = m_fTopLower + 62;
    btns[113] = CreateButton(416, ftop, 24, "1",  200);
    btns[114] = CreateButton(440, ftop, 24, "2",  201);
    btns[115] = CreateButton(464, ftop, 24, "3",  202);
    btns[116] = CreateButton(488, ftop, 24, "4",  203);
    btns[117] = CreateButton(512, ftop, 24, "5",  204);
    btns[118] = CreateButton(536, ftop, 24, "6",  205);
    /*---- Buttons 7-12 ----*/
    ftop = m_fTopLower + 78;
    btns[119] = CreateButton(416, ftop, 24, "7",  206);
    btns[120] = CreateButton(440, ftop, 24, "8",  207);
    btns[121] = CreateButton(464, ftop, 24, "9",  208);
    btns[122] = CreateButton(488, ftop, 24, "10", 209);
    btns[123] = CreateButton(512, ftop, 24, "11", 210);
    btns[124] = CreateButton(536, ftop, 24, "12", 211);
    /*---- Buttons 13-16 ----*/
    ftop = m_fTopLower + 94;
    btns[125] = CreateButton(416, ftop, 24, "13", 212);
    btns[126] = CreateButton(440, ftop, 24, "14", 213);
    btns[127] = CreateButton(464, ftop, 24, "15", 214);
    btns[128] = CreateButton(488, ftop, 24, "16", 215);

    /*---- Axis ----*/
    ftop = m_fTopLower + 122;
    btns[129] = CreateButton(416, ftop, 24, "X", 224);
    btns[130] = CreateButton(440, ftop, 24, "Y", 225);
    btns[131] = CreateButton(464, ftop, 24, "Z", 226);
    btns[132] = CreateButton(488, ftop, 24, "R", 227);
    btns[133] = CreateButton(512, ftop, 24, "U", 232);
    btns[134] = CreateButton(536, ftop, 24, "V", 233);

    //---------------------------------------------------------
    //                   VOICE BUTTONS
    //---------------------------------------------------------
    //The width of the buttons is set in 'ShowVoiceButtons'
    btnVoices[0] = CreateButton(420, 292, 1, "T Female",       csbtnVoiceTFemale);
    btnVoices[1] = CreateButton(420, 292 + 16, 1, "T Male",    csbtnVoiceTMale);
    btnVoices[2] = CreateButton(420, 292 + 32, 1, "SF Female", csbtnVoiceSFFemale);
    btnVoices[3] = CreateButton(420, 292 + 48, 1, "SF Male",   csbtnVoiceSFMale);

    //---------------------------------------------------------
    //                   CUSTOM DELETE BUTTON
    //---------------------------------------------------------
    btnCustoms[0] = CreateButton(420, 292, 1, "Delete",        csbtnCustomDelete);

    //---------------------------------------------------------
    //                 EDITBOX/BIND BUTTONS
    //---------------------------------------------------------
    btnBind = CreateButton(216, m_fTopLower + 74, 33, "Bind", csbtnBind);
    btnClear = CreateButton(250, m_fTopLower + 74, 33, "Clear", csbtnClear);
    btnClearBind = CreateButton(324, m_fTopLower + 5, 33, "Clear", csbtnClearBind);
    btnCustomAdd = CreateButton(284, m_fTopLower + 74, 33, "Custom", csbtnCustomAdd);
//    btnTest = CreateButton(316, m_fTopLower + 74, 33, "Test", csbtnTest);
//    btnServer = CreateButton(260, m_fTopLower + 74, 33, "Server", csbtnServer);
//    mbCommands = tobkMenuBar(CreateWindow(class'stkbMenuBar', 140, 252, 217, 16));
    edcNewBinding = stkbEditControl(CreateControl(class'stkbEditControl', 140, m_fTopLower + 94, 217, 17));
    edcNewBinding.SetNumericOnly(False);
    edcNewBinding.EditBoxWidth= edcNewBinding.WinWidth;
    edcNewBinding.editbox.bSelectOnFocus = False;
    //Set NO KEY selected
    ShowKeyBinding(0);

    rcmOptions = stkbRCMOptions(Root.CreateWindow(class'stkbRCMOptions', 0, 0, 100, 100, Self));
    rcmOptions.HideWindow();

    //---------------------------------------------------------
    //                CBO KEYBOARD LAYOUT
    //---------------------------------------------------------
    cboKeyboard = UWindowComboControl(CreateControl(class'UWindowComboControl', 464, 12, 96, 1));
    cboKeyboard.EditBoxWidth = 96;
    cboKeyboard.SetText("");
    cboKeyboard.SetHelpText("Select the keyboard layout you want");
    cboKeyboard.SetFont(F_Normal);
    cboKeyboard.SetEditable(False);
    for (i=0; i<ArrayCount(m_asKeyboards); i++)
    {
        if (m_asKeyboards[i] != "")
            cboKeyboard.AddItem(m_asKeyboards[i]);
    }
    cboKeyboard.SetSelectedIndex(mc_iSelectedKeyboardLayout);

    //---------------------------------------------------------
    //                CHECKBOX NUMLOCK
    //---------------------------------------------------------
    chkNumLock = UWindowCheckBox(CreateControl(class'UWindowCheckBox', 464, 30, 60, 1));
    chkNumlock.Align = TA_RIGHT;
    chkNumLock.SetText("NumLock");
    chkNumLock.bChecked = mc_bNumLock;
    chkNumlock_Change();

    //---------------------------------------------------------
    //                        GRID/CBO COMMANDS
    //---------------------------------------------------------
    grdCommands = stkbGridCommands(CreateWindow(class'stkbGridCommands', 14, 292, 400, 100));
    grdCommands.GridName = "Commands";
    if(mc_lColumn1Width!=0 || mc_lColumn2Width!=0)
    {
        grdCommands.FirstColumn.WinWidth = mc_lColumn1Width;
        grdCommands.LastColumn.WinWidth = mc_lColumn2Width;
    };

    cboCategory = UWindowComboControl(CreateControl(class'UWindowComboControl', 14, 268, 100, 1));
    cboCategory.EditBoxWidth = 100;
    cboCategory.SetText("");
    cboCategory.SetHelpText("Select the command selection you want");
    cboCategory.SetFont(F_Normal);
    cboCategory.SetEditable(False);
    for (i=0; i<ArrayCount(m_asCategories); i++)
    {
        if (m_asCategories[i] != "")
            cboCategory.AddItem(m_asCategories[i]);
    }
    cboCategory.SetSelectedIndex(mc_lSelectedCategory);

    m_sDebugInfo = "";

//    //=====================================================================
//	ServerListClass = class<UBrowserServerList>(DynamicLoadObject("TOSystem.TO_BrowserServerList", class'Class'));
//    RefreshServerList(False, True);
}

//------------------------------------------
//       MessageBoxDone (Override)
//------------------------------------------
function MessageBoxDone(UWindowMessageBox W, MessageBoxResult Result)
{
    switch(m_eMsgBoxMode)
    {
//        case mbmNone:
//            //Do Nothing;
//            break;
        case mbmConsoleKey:
    		if(Result == MR_Yes)
    		  BindConsoleKey(m_iSelectedKeyCode);
    	    break;
        Case mbmSpeechKey:
    		if(Result == MR_Yes)
    		  BindSpeechKey(m_iSelectedKeyCode);
            break;
    	Case mbmUseKey:
    		if(Result == MR_Yes)
    		  BindUseKey(m_iSelectedKeyCode);
            break;
	}
	MsgBox = None;
	m_eMsgBoxMode = mbmNone;
}

//------------------------------------------
//       Click (Override)
//------------------------------------------
function Click(float X, float Y)
{
    local float fMenuX, fMenuY;

    if(X > 498 && X< 564 && Y>294 && Y<294+64)
        ShowAboutBox();
}


//------------------------------------------
//       Close (Override)
//------------------------------------------
function Close(optional bool bByParent)
{
    if(mc_lSelectedCategory!=7)
    {
        mc_lColumn1Width= grdCommands.FirstColumn.WinWidth;
        mc_lColumn2Width= grdCommands.LastColumn.WinWidth;
        SaveConfig();
    };

	if(!bByParent)
		ParentWindow.Close(bByParent);

	Super.Close(bByParent);
}


//------------------------------------------
//       Notify (Override)
//------------------------------------------
function Notify(UWindowDialogControl C, byte E)
{
    local float  fX, fY;
//    m_sDebugInfo = string(C.Class) $ "[" $ string(E) $ "]" $ chr(13) $ m_sDebugInfo;
    switch(C.Class)
    {
    //----------------------------------------------
    case class'UWindowCheckBox':
        switch(E)
        {
        //----------------------------------------------
        case DE_Change:
            switch(C)
            {
            case chkNumLock:
                chkNumLock_Change();
                break;
            };
            break;
        };
        break;
    //----------------------------------------------
    Case class'UWindowComboControl':
        switch(E)
        {
        //----------------------------------------------
        case DE_Change:
            switch(C)
            {
            case cboCategory:
                cboCategory_Change();
                break;
            case cboKeyboard:
                cboKeyboard_Change();
                break;
            }
            break;
        };
        break;
    //----------------------------------------------
    case class'UWindowSmallButton':
        switch(E)
        {
        //----------------------------------------------
        Case DE_Click:
            switch(int(UWindowSmallButton(C).ToolTipString))
            {
                case csbtnBind:
                    btnBind_Click();
                    break;
                Case csbtnClear:
                    edcNewBinding.EditBox.Clear();
                    break;
                Case csbtnClearBind:
                    btnClearBind_Click();
                    break;
                Case csbtnTest:
                    btnTest_Click();
                    break;
                Case csbtnCustomAdd:
                    btnCustomAdd_Click();
                    break;
                Case csbtnCustomDelete:
                    btnCustomDelete_Click();
                    break;
//                case csbtnServer:
//                    MessageBox("Servers", "Pinged:" $ PingedList.Count() $ " Unpinged:" $ UnpingedList.Count() , MB_OK, MR_OK, MR_OK);
//                    break;
                Case csbtnVoiceTFemale:
                    PlayVoice(vtFemaleT, grdCommands.GetSelectedRow());
                    break;
                case csbtnVoiceTMale:
                    PlayVoice(vtMaleT, grdCommands.GetSelectedRow());
                    break;
                case csbtnVoiceSFFemale:
                    PlayVoice(vtFemaleSF, grdCommands.GetSelectedRow());
                    break;
                case csbtnVoiceSFMale:
                    PlayVoice(vtMaleSF, grdCommands.GetSelectedRow());
                    break;
                default:
                    btns_Click(UWindowSmallButton(C));
                    break;
            };
            break;
        };
        break;
    //----------------------------------------------
    case class'stkbEditControl':
        switch(E)
        {
        //----------------------------------------------
        case DE_Change:
            edcNewBinding_Change();
            break;
        //----------------------------------------------
//        case DE_RClick:
//            MessageBox("Message", "Editcontrol RightClicked.", MB_OK, MR_OK, MR_OK);
//            break;
        //----------------------------------------------
//        case DE_Click:
        case DE_RClick:
            If(bUWindowActive)
            {
                GetMouseXY(fX, fY);
                RClick(fX,fY);
            };
            break;
//        default:
//            m_sDebugInfo = "E:" $ string(E) $ chr(13) $ m_sDebugInfo;
        };
        break;
    //----------------------------------------------
    default:
        //All other components
        switch(E)
        {
        //----------------------------------------------
        Case DE_Created:
            break;
        Case DE_Change:
            break;
        Case DE_Click:
            break;
        Case DE_Enter:
            break;
        Case DE_Exit:
            break;
        Case DE_MClick:
            break;
        Case DE_RClick:
            break;
        Case DE_EnterPressed:
            break;
        Case DE_MouseMove:
            break;
        Case DE_MouseLeave:
            break;
        Case DE_LMouseDown:
            break;
        Case DE_DoubleClick:
            if(grdCommands.SelectedListItem != none)
                InsertCommand(grdCommands.SelectedListItem.Command);
            break;
        Case DE_MouseEnter:
            break;
        Case DE_HelpChanged:
            break;
        Case DE_WheelUpPressed:
            break;
        Case DE_WheelDownPressed:
            break;
        };
        break;
    };
}

//------------------------------------------
//       RClick (Override)
//------------------------------------------
function RClick(float X, float Y)
{
    local float fMenuX, fMenuY;

    WindowToGlobal(X, Y, fMenuX, fMenuY);
    rcmOptions.WinLeft = fMenuX;
    rcmOptions.WinTop = fMenuY;
    rcmOptions.STParent = Self;
    rcmOptions.ShowWindow();
}

//------------------------------------------
//       Resized (Override)
//------------------------------------------
function Resized()
{
    local float fHeight;

    fHeight = WinHeight - grdCommands.WinTop - 16;

	if(fHeight > (grdCommands.RowHeight * 3))
	   grdCommands.WinHeight = fHeight;
}

//------------------------------------------
//       Paint (Override)
//------------------------------------------
function Paint(Canvas C, float X, float Y)
{
    local Texture   T;
    local color     BlackColor;

    Super.Paint(C, X, Y);

    C.Font = Root.Fonts[F_Normal];
    WrapClipText_(C, 140, m_fTopLower + 26, 217, 41, m_sCurrentKeyBinding);

    WrapClipText_(C, 140, m_fTopLower + 114, 217, 41, m_sNewKeyBinding);
    T = GetLookAndFeelTexture();
    DrawMiscBevel(C, 228, m_fTopLower + 6, 94, 14, T, 3);

//   T = GetLookAndFeelTexture();
//   DrawUpBevel(C, 462, 290, 68, 68, T);
	T = LookAndFeel.Misc;
    DrawMiscBevel(C, 496, 292, 68, 68, T, 2);
	DrawStretchedTexture(C, 498, 294, 64, 64, Texture'SuperTeamLogo');

    C.DrawColor.R = 0;
    C.DrawColor.G = 0;
    C.DrawColor.B = 0;
    C.Font = Root.Fonts[F_Bold];

    DrawFrame(C, 10, 3 + 6, 554, 122, "Keyboard");
    DrawFrame(C, 10, m_fTopLower + 12, 120, 104, "Mouse");
    DrawFrame(C, 364, m_fTopLower + 12, 200, 132, "Joystick");

//    DrawText(C, 14, 3, 1, 12, "Keyboard", TA_Left);
//    DrawText(C, 14, m_fTopLower, 1, 12, "Mouse", TA_Left);
//    DrawText(C, 370, m_fTopLower, 1, 12, "Joystick", TA_Left);
    DrawText(C, 140, m_fTopLower + 6, 1, 14, "Current Binding", TA_Left);
    DrawText(C, 228, m_fTopLower + 6, 94, 14, m_sSelectedKeyName, TA_Center);
    DrawText(C, 140, m_fTopLower + 74, 1, 14, "New Binding", TA_Left);

    C.Font = Root.Fonts[F_Normal];
    DrawText(C, 14, m_fTopLower + 26, 1, 16, "Wheel", TA_Left);
    DrawText(C, 14, m_fTopLower + 62, 1, 16, "Buttons", TA_Left);

    DrawText(C, 372, m_fTopLower + 26, 1, 16, "POV", TA_Left);
    DrawText(C, 372, m_fTopLower + 62, 1, 16, "Buttons", TA_Left);
    DrawText(C, 372, m_fTopLower + 122, 1, 16, "Axis", TA_Left);

    //Draw VoiceButton Captions
//    if(mc_lSelectedCategory==1)
//    {
//        DrawText(C, 420, 292, 1, 16, "F T", TA_Left);
//        DrawText(C, 420, 292+16, 1, 16, "M T", TA_Left);
//        DrawText(C, 420, 292+32, 1, 16, "F SF", TA_Left);
//        DrawText(C, 420, 292+48, 1, 16, "M SF", TA_Left);
//    };

    DrawText(C, 14, WinHeight - 16, 1, 16, "Use Right mousebutton for Optionsmenu", TA_Left);

    //Show Debug Information
    if(m_sDebugInfo != "")
        WrapClipText_(C, 1, 329, self.WinWidth, self.WinHeight, m_sDebugInfo);
}

//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//
//          C O N T R O L  'E V E N T S'
//
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//------------------------------------------
//       chkNumLock_Change
//------------------------------------------
function chkNumLock_Change()
{
    mc_bNumLock = chkNumLock.bChecked;
    SaveConfig();
    if(mc_bNumLock)
        SetKeyboard_KeyPadNumlockOn();
    else
        SetKeyboard_KeyPadNumlockOff();
}

//------------------------------------------
//       btnBind_Click
//------------------------------------------
function btnBind_Click()
{
    local string    sKeyBinding;

    if(m_iSelectedKeyCode == 0)
    {
        MessageBox("Error binding key", "No key selected.", MB_OK, MR_OK, MR_OK);
    }
    else
    {
        sKeyBinding = lower(trim(m_sNewKeyBinding));
        if(instr(sKeyBinding,"consolekey")!=-1)
            sKeyBinding="consolekey";
        if(instr(sKeyBinding,"speechkey")!=-1)
            sKeyBinding="speechkey";
        if(instr(sKeyBinding,"usekey")!=-1)
            sKeyBinding="usekey";
        switch(sKeyBinding)
        {
            case "consolekey":
                if((m_iSelectedKeyCode==1) || (m_iSelectedKeyCode==27))
                {
                    MessageBox("Error binding key", "Cannot Assign the ConsoleKey to the specified Key.", MB_OK, MR_OK, MR_OK);
                }
                else if(Root.Console.ConsoleKey==0)
                {
    		        BindConsoleKey(m_iSelectedKeyCode);
                }
                else if(Root.Console.ConsoleKey!=m_iSelectedKeyCode)
                {
                    m_eMsgBoxMode = mbmConsoleKey;
                    MsgBox = MessageBox("Error binding key", "ConsoleKey is already assigned, Reassign?.", MB_YesNo, MR_No, MR_Yes);
                };
                break;
            case "speechkey":
                if((m_iSelectedKeyCode==1) || (m_iSelectedKeyCode==27))
                {
                    MessageBox("Error binding key", "Cannot Assign the SpeechKey to the specified Key.", MB_OK, MR_OK, MR_OK);
                }
                else if(TO_Console(Root.Console).SpeechKey==0)
                {
    		        BindSpeechKey(m_iSelectedKeyCode);
                }
                else if(TO_Console(Root.Console).SpeechKey!=m_iSelectedKeyCode)
                {
                    m_eMsgBoxMode = mbmSpeechKey;
                    MsgBox = MessageBox("Error binding key", "SpeechKey is already assigned, Reassign?.", MB_YesNo, MR_No, MR_Yes);
                };
                break;
            case "usekey":
                if((m_iSelectedKeyCode==1) || (m_iSelectedKeyCode==27))
                {
                    MessageBox("Error binding key", "Cannot Assign the UseKey to the specified Key.", MB_OK, MR_OK, MR_OK);
                }
                else if(TO_Console(Root.Console).UseKey==0)
                {
    		        BindUseKey(m_iSelectedKeyCode);
                }
                else if(TO_Console(Root.Console).UseKey!=m_iSelectedKeyCode)
                {
                    m_eMsgBoxMode = mbmUseKey;
                    MsgBox = MessageBox("Error binding key", "UseKey is already assigned, Reassign?.", MB_YesNo, MR_No, MR_Yes);
                };
                break;
            default:
                if(m_iSelectedKeyCode == Root.Console.ConsoleKey)
                    BindConsoleKey(0);
                if(m_iSelectedKeyCode == TO_Console(Root.Console).SpeechKey)
                    BindSpeechKey(0);
                if(m_iSelectedKeyCode == TO_Console(Root.Console).UseKey)
                    BindUseKey(0);
                if(m_sNewKeyBinding == "<Empty>")
                    sKeyBinding = "";
                else
                    sKeyBinding = m_sNewKeyBinding;
                BindKeyBinding(m_iSelectedKeyCode, sKeyBinding);
                break;
        };
    };
}

//------------------------------------------
//       btnClearBind_Click
//------------------------------------------
function btnClearBind_Click()
{
    local string    sKeyBinding;

    if(m_iSelectedKeyCode == 0)
    {
        MessageBox("Error binding key", "No key selected.", MB_OK, MR_OK, MR_OK);
    }
    else
    {
        switch(m_iSelectedKeyCode)
        {
            case Root.Console.ConsoleKey:            BindConsoleKey(0); break;
            case TO_Console(Root.Console).SpeechKey: BindSpeechKey(0);  break;
            case TO_Console(Root.Console).UseKey:    BindUseKey(0);     break;
            default:                                 BindKeyBinding(m_iSelectedKeycode, ""); break;
        };
    };
}

//------------------------------------------
//       btnCustomAdd_Click
//------------------------------------------
function btnCustomAdd_Click()
{
    local int       i;
    local int       iIndex;
    local string    sKeyBinding;

    if(m_sNewKeyBinding == "<Empty>")
        sKeyBinding = "";
    else
        sKeyBinding = m_sNewKeyBinding;

    if(trim(sKeybinding)!="")
    {
        iIndex = -1;
        for (i=0; i<ArrayCount(mc_asCustomCommands); i++)
        {
            if (trim(mc_asCustomCommands[i])=="")
            {
                iIndex=i;
                i = ArrayCount(mc_asCustomCommands)+1;
            };
        };
        if(iIndex==-1)
            MessageBox("Error adding custom command", "No free Custom slots available.", MB_OK, MR_OK, MR_OK);
        else
        {
            mc_asCustomCommands[iIndex]=sKeyBinding;
            SaveConfig();
            if(cboCategory.GetSelectedIndex()==7)
                cboCategory_Change();
            MessageBox("Adding custom command", "New custom command added.", MB_OK, MR_OK, MR_OK);
        };
    };
}

//------------------------------------------
//       btnCustomDelete_Click
//------------------------------------------
function btnCustomDelete_Click()
{
    local string    sCommand;
    local int       i;

    sCommand = "";
    if(grdCommands.SelectedListItem != none)
        sCommand = grdCommands.SelectedListItem.Command;

    if(sCommand!="")
    {
        for (i=0; i<ArrayCount(mc_asCustomCommands); i++)
        {
            if (mc_asCustomCommands[i] == sCommand)
            {
                mc_asCustomCommands[i] = "";
                SaveConfig();
                i = ArrayCount(mc_asCustomCommands)+1;
            };
        };
        cboCategory_Change();
    };
}

//------------------------------------------
//       btnTest_Click
//------------------------------------------
function btnTest_Click()
{
    local int       iKeyCode;
    local string    s;
//    iKeyCode = GetCurrentUseKey();
   //TestBrowser();
//    iKeyCode = TOPModels.TO_Console(Root.Console).UseKey;
    if(edcNewBinding.GetValue()=="")
        edcNewBinding.SetValue("get ini:STKeybinder.stkbFWKeyBinder 01_Hoi");
    s = GetPlayerOwner().ConsoleCommand(edcNewBinding.GetValue());
//    s = GetPlayerOwner().ConsoleCommand("get ini:STKeybinder.stkbFWKeyBinder 01_Hoi");
//    s = GetPlayerOwner().ConsoleCommand("get ini:STKeybinder.stkbFWKeyBinder 01_Hoi");

    MessageBox("Test", "return[" $ s $ "]", MB_OK, MR_OK, MR_OK);

}

//------------------------------------------
//       btns_Click
//------------------------------------------
function btns_Click(UWindowSmallButton btn)
{
    ShowKeyBinding(int(btn.ToolTipString));
}

//------------------------------------------
//       cboCategory_Change
//------------------------------------------
function cboCategory_Change()
{
    local stkbCommandList   cl;
    local int               i;

    clCommands.Clear();
    grdCommands.List.Clear();
    grdCommands.SelectedListItem = none;

    if(mc_lSelectedCategory!=7)
    {
        mc_lColumn1Width= grdCommands.FirstColumn.WinWidth;
        mc_lColumn2Width= grdCommands.LastColumn.WinWidth;
    };

    mc_lSelectedCategory = cboCategory.GetSelectedIndex();
    SaveConfig();
    if(mc_lSelectedCategory==7)
    {
        grdCommands.FirstColumn.WinWidth = 0;
        grdCommands.LastColumn.WinWidth = grdCommands.WinWidth;
    }
    else
    {
        if(mc_lColumn1Width==0 && mc_lColumn2Width==0)
        {
            mc_lColumn1Width= grdCommands.WinWidth / 2;
            mc_lColumn2Width= mc_lColumn1Width;
            SaveConfig();
        };

        grdCommands.FirstColumn.WinWidth = mc_lColumn1Width;
        grdCommands.LastColumn.WinWidth = mc_lColumn2Width;
    };

    ShowVoiceButtons((mc_lSelectedCategory==1));
    ShowCustomButtons((mc_lSelectedCategory==7));
    switch(mc_lSelectedCategory)
    {
    //---------- BUY ----------
    Case 0:
        grdCommands.List.Add("Sell current weapon",             "k_SellWeapon");
        grdCommands.List.Add("","");
        grdCommands.List.Add("Needed armor (All armor is better)", "s_kAmmoAuto 333 'Buy Needed Armor");
        grdCommands.List.Add("All armor",                       "s_kAmmoAuto 304 'Buy All Armor");
        grdCommands.List.Add("Kevlar vest",                     "s_kAmmoAuto 301 'Buy Kevlar Vest");
        grdCommands.List.Add("Helmet",                          "s_kAmmoAuto 302 'Buy Helmet");
        grdCommands.List.Add("Thigh pads",                      "s_kAmmoAuto 303 'Buy Thigh Pads");
        grdCommands.List.Add("","");
        grdCommands.List.Add("Nighvision goggles",              "s_kAmmoAuto 401 'Buy Nightvision");
        grdCommands.List.Add("","");
        grdCommands.List.Add("Ammo for weapon in hand",         "s_kAmmo 999");
        grdCommands.List.Add("Ammo clip",                       "s_kAmmo");
        grdCommands.List.Add("","");
        grdCommands.List.Add("Flashbang grenade",               "s_kAmmoAuto 114 'Buy Flashbang Grenade");
        grdCommands.List.Add("Concussion grenade",              "s_kAmmoAuto 115 'Buy Concussion Grenade");
        grdCommands.List.Add("Smoke grenade",                   "s_kAmmoAuto 120 'Buy Smoke Grenade");
        grdCommands.List.Add("HE grenade",                      "s_kAmmoAuto 113 'Buy HE Grenade");
        grdCommands.List.Add("","");
        grdCommands.List.Add("t   Glock",                       "s_kAmmoAuto 101 'Buy Glock");
        grdCommands.List.Add("s   Beretta 92F",                 "s_kAmmoAuto 119 'Buy Beretta");
        grdCommands.List.Add("t/s Black Hawk (Desert Eagle)",   "s_kAmmoAuto 102 'Buy Black Hawk");
        grdCommands.List.Add("s   Raging Cobra (Raging Bull)",  "s_kAmmoAuto 123 'Buy Raging Cobra");
        grdCommands.List.Add("","");
        grdCommands.List.Add("t   UZI (Ingram mac10)",          "s_kAmmoAuto 103 'Buy UZI");
        grdCommands.List.Add("s   APII (HK SMGII)",             "s_kAmmoAuto 122 'Buy APII");
        grdCommands.List.Add("t   HK MP5A2 (Navy)",             "s_kAmmoAuto 104 'Buy MP5A2");
        grdCommands.List.Add("s   HK MP5 SD",                   "s_kAmmoAuto 118 'Buy MP5SD");
        grdCommands.List.Add("t   MossBerg shotgun",            "s_kAmmoAuto 105 'Buy Mossberg Shotgun");
        grdCommands.List.Add("s   BW SPS 12 (Spas 12 shotgun)", "s_kAmmoAuto 106 'Buy Spas Shotgun");
        grdCommands.List.Add("t   AS 12 (Saiga)",               "s_kAmmoAuto 117 'Buy Saiga");
        grdCommands.List.Add("","");
        grdCommands.List.Add("t   AK47",                        "s_kAmmoAuto 107 'Buy AK-47");
        grdCommands.List.Add("s   M4A1",                        "s_kAmmoAuto 109 'Buy M4A1");
        grdCommands.List.Add("t/s M16 + Laserattachment",       "s_kAmmoAuto 110 'Buy M16");
        grdCommands.List.Add("t/s SR 90 (MSG 90)",              "s_kAmmoAuto 112 'Buy SR 90");
        grdCommands.List.Add("s   HK33 Rifle",                  "s_kAmmoAuto 111 'Buy HK 33");
        grdCommands.List.Add("s   SW Commando (SG 551)",        "s_kAmmoAuto 108 'Buy SWCommando");
        grdCommands.List.Add("s   Parker-Hale 85 sniperrifle",  "s_kAmmoAuto 116 'Buy Parker-Hale Sniper Rifle");
        grdCommands.List.Add("t   M60",                         "s_kAmmoAuto 124 'Buy M60");
        grdCommands.List.Add("s   M4A2m203",                    "s_kAmmoAuto 121 'Buy M4A2m203");
        break;
    //---------- SPEECH ----------
    Case 1:
        grdCommands.List.Add("I copy",                      "speech 0 0 0 'I Copy");
        grdCommands.List.Add("Roger that",                  "speech 0 1 0 'Roger that");
        grdCommands.List.Add("You got it",                  "speech 0 2 0 'You got it");
        grdCommands.List.Add("Negative",                    "speech 0 3 0 'Negative");
        grdCommands.List.Add("","");
        grdCommands.List.Add("Hey! Friendly fire!",         "speech 1 0 0 'Hey! Friendly fire!");
        grdCommands.List.Add("Watch who you shoot!",        "speech 1 1 0 'Watch who you shoot!");
        grdCommands.List.Add("","");
        grdCommands.List.Add("5 Seconds before assault!",   "Speech 5 0 0 'Assault in 5");
        grdCommands.List.Add("Get in position",             "Speech 5 1 0 'Get in position");
        grdCommands.List.Add("Keep moving",                 "Speech 5 2 0 'Keep moving");
        grdCommands.List.Add("Meet at rendez-vous point",   "Speech 5 3 0 'Meet at rendezvous");
        grdCommands.List.Add("Split in pairs",              "Speech 5 4 0 'Split in pairs");
        grdCommands.List.Add("Stay together team",          "Speech 5 5 0 'Stay together team");
        grdCommands.List.Add("","");
        grdCommands.List.Add("Return to base",              "speech 2 0 -1 'Return to base!");
        grdCommands.List.Add("Hold this position",          "speech 2 1 -1 'Hold this position");
        grdCommands.List.Add("Let's clean this place out",  "speech 2 2 -1 'Let's clean this place out");
        grdCommands.List.Add("Cover me",                    "speech 2 3 -1 'Cover me");
        grdCommands.List.Add("Attack main target",          "speech 2 4 -1 'Attack main target");
        grdCommands.List.Add("","");
        grdCommands.List.Add("Enemy down",                  "speech 3 0 0 'Enemy down");
        grdCommands.List.Add("Hostage rescued",             "Speech 4 0 0 'Hostage resqued");
        grdCommands.List.Add("Bomb has been planted",       "Speech 4 1 0 'Bomb has been planted");
        grdCommands.List.Add("Fire in the hole!",           "Speech 4 2 0 'Fire in the hole!");
        grdCommands.List.Add("I've got your back",          "speech 4 3 0 'I've got your back");
        grdCommands.List.Add("I'm hit",                     "speech 4 4 0 'I'm hit");
        grdCommands.List.Add("Emergency! Man Down",         "speech 4 5 0 'Emergency! Man Down");
        grdCommands.List.Add("Cover your eyes",             "speech 4 11 0 'Cover your eyes");
        grdCommands.List.Add("Area cleared",                "speech 6 0 0 'Area cleared");
        grdCommands.List.Add("Enemy spotted",               "speech 6 2 0 'Enemy spotted");
        grdCommands.List.Add("I'll keep them busy",         "Speech 6 3 0 'Ill keep them busy");
        grdCommands.List.Add("I'm going in",                "Speech 6 4 0 'Im going in");
        grdCommands.List.Add("I'm in position",             "speech 6 5 0 'I'm in position");
        grdCommands.List.Add("Objective accomplished",      "speech 6 7 0 'Objective accomplished");
        grdCommands.List.Add("Target in sight",             "speech 6 8 0 'Target in sight");
        grdCommands.List.Add("","");
        grdCommands.List.Add("Emergency!",                  "speech 7 0 0 'Emergency!");
        grdCommands.List.Add("Falling back",                "Speech 7 1 0 'falling back");
        grdCommands.List.Add("I'm hit",                     "speech 7 2 0 'I'm hit");
        grdCommands.List.Add("I'm under heavy attack!",     "speech 7 3 0 'I'm under heavy attack!");
        grdCommands.List.Add("I need some backup fast!",    "speech 7 4 0 'I need some backup fast!");
        grdCommands.List.Add("Watch for cover",             "speech 7 5 0 'Watch for cover");
        break;
    //---------- GESTURES ----------
    Case 2:
        grdCommands.List.Add("Chicken dance", "taunt victory1");
        grdCommands.List.Add("Bow",           "taunt taunt1");
        grdCommands.List.Add("Wave",          "taunt wave");
        break;
    //---------- WEAPONS ----------
    Case 3:
        grdCommands.List.Add("Use",                      "UseKey");
        grdCommands.List.Add("Flashlight On/Off",        "s_kFlashlight");
        grdCommands.List.Add("Nightvision On/Off",       "s_kNightVision");
        grdCommands.List.Add("Fire",                     "Fire");
        grdCommands.List.Add("Alternate fire",           "AltFire");
        grdCommands.List.Add("Reload weapon",            "s_kReload");
        grdCommands.List.Add("Throw weapon",             "ThrowWeapon");
        grdCommands.List.Add("Switch firemode",          "s_kChangeFireMode");
        grdCommands.List.Add("Switch to next weapon",    "NextWeapon");
        grdCommands.List.Add("Switch to prev weapon",    "PrevWeapon");
        grdCommands.List.Add("Switch to best weapon",    "SwitchToBestWeapon");
        grdCommands.List.Add("Switch to knife",          "SwitchWeapon 1");
        grdCommands.List.Add("Switch to pistol",         "SwitchWeapon 2");
        grdCommands.List.Add("Switch to SMG/shotgun",    "SwitchWeapon 3");
        grdCommands.List.Add("Switch to rifle",          "SwitchWeapon 4");
        grdCommands.List.Add("Switch to grenade",        "SwitchWeapon 5");
        grdCommands.List.Add("Switch to weapon 6",       "SwitchWeapon 6");
        grdCommands.List.Add("Switch to weapon 7",       "SwitchWeapon 7");
        grdCommands.List.Add("Switch to weapon 8",       "SwitchWeapon 8");
        grdCommands.List.Add("Switch to weapon 9",       "SwitchWeapon 9");
        grdCommands.List.Add("Switch to C4",             "SwitchWeapon 10");
        grdCommands.List.Add("Automatic reload ON (only offline)",      "set s_SWAT.s_Player_T bAutomaticReload True");
        grdCommands.List.Add("Automatic reload OFF (only offline)",     "set s_SWAT.s_Player_T bAutomaticReload False");
        break;
    //---------- MOVEMENT ----------
    Case 4:
        grdCommands.List.Add("Move forward",          "Axis aBaseY  Speed=+300.0");
        grdCommands.List.Add("Move backward",         "Axis aBaseY  Speed=-300.0");
        grdCommands.List.Add("Turn left",             "Axis aBaseX Speed=-150.0");
        grdCommands.List.Add("Turn Right",            "Axis aBaseX  Speed=+150.0");
        grdCommands.List.Add("Strafe",                "Button bStrafe");
        grdCommands.List.Add("Strafe left",           "Axis aStrafe Speed=-300.0");
        grdCommands.List.Add("Strafe right",          "Axis aStrafe Speed=+300.0");
        grdCommands.List.Add("Walking",               "Button bRun");
        grdCommands.List.Add("Jump",                  "Axis aUp Speed=+300.0");
        grdCommands.List.Add("Duck",                  "Button bDuck | Axis aUp Speed=-300.0");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("Mouse look",            "Look");
        grdCommands.List.Add("Mouse look Up/Down",    "Axis aMouseY Speed=6.0");
        grdCommands.List.Add("Mouse look Left/Right", "Axis aMouseX Speed=6.0");
        grdCommands.List.Add("Look up",               "Axis aLookUp Speed=+100.0");
        grdCommands.List.Add("Look down",             "Axis aLookUp Speed=-100.0");
        grdCommands.List.Add("Look ???",              "Axis aturn speed=5.9");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("(Movement using Aliases)", "");
        grdCommands.List.Add("Move forward",          "MoveForward");
        grdCommands.List.Add("Move backward",         "MoveBackward");
        grdCommands.List.Add("Turn left",             "TurnLeft");
        grdCommands.List.Add("Turn Right",            "TurnRight");
        grdCommands.List.Add("Strafe",                "Strafe");
        grdCommands.List.Add("Strafe left",           "StrafeLeft");
        grdCommands.List.Add("Strafe right",          "StrafeRight");
        grdCommands.List.Add("Walking",               "Walking");
        grdCommands.List.Add("Jump",                  "Jump");
        grdCommands.List.Add("Duck",                  "Duck");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("Look up",               "LookUp");
        grdCommands.List.Add("Look down",             "LookDown");
        break;
    //---------- TOST ----------
    Case 5:
        grdCommands.List.Add("Echo <message>",           "Echo ");
        grdCommands.List.Add("GetNextMap",               "GetNextMap");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("xSay <message>",           "xSay ");
        grdCommands.List.Add("xTeamsay <message>",       "xTeamSay ");
        grdCommands.List.Add("#W (players weapon)",      "#W");
        grdCommands.List.Add("#T (players target name)", "#T");
        grdCommands.List.Add("#N (players name)",        "#N");
        grdCommands.List.Add("#L (players location)",    "#L");
        grdCommands.List.Add("#H (players health)",      "#H");
        grdCommands.List.Add("#B (players buddies)",     "#B");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("Admin log in <password>",  "salogin ");
        grdCommands.List.Add("Admin log out",            "salogout");
        grdCommands.List.Add("ShowAdminTab",             "ShowAdminTab");
        grdCommands.List.Add("ShowGameTab",              "ShowGameTab");
        grdCommands.List.Add("showIRCTab",               "ShowIRCTab");
        grdCommands.List.Add("ShowIP <id>",              "ShowIP ");
        grdCommands.List.Add("SASay <message>",          "SASay ");
        grdCommands.List.Add("SASetGamePW <password>",   "SASetGamePW ");
        grdCommands.List.Add("Punish <id>",              "Punish ");
        grdCommands.List.Add("KickTK",                   "kicktk");
        grdCommands.List.Add("mkteams",                  "mkteams");
        grdCommands.List.Add("fteamchg <id>",            "fteamchg ");
        grdCommands.List.Add("xKick <id>",               "xkick ");
        grdCommands.List.Add("xpKick <id>",              "xpkick ");
        grdCommands.List.Add("Protectsrv",               "protectsrv");
        grdCommands.List.Add("Skip",                     "Skip");
        grdCommands.List.Add("Switch level <mapname>",   "SwitchLevel ");
        grdCommands.List.Add("Switch map <mapname>",     "saMapChg ");
        grdCommands.List.Add("Set next map <mapname>",   "saSetNextMap ");
        grdCommands.List.Add("Admin reset",              "AdminReset");
        grdCommands.List.Add("End round",                "EndRound");
        grdCommands.List.Add("Mirror damage on",         "AdminSet 1 mirrordamage");
        grdCommands.List.Add("Mirror damage off",        "AdminSet 0 mirrordamage");
        grdCommands.List.Add("Ballistics on",            "AdminSet 1 enableballistics");
        grdCommands.List.Add("Ballistics off",           "AdminSet 0 enableballistics");
        grdCommands.List.Add("Enhanced vote on/off",     "EnhVoteSystem");
        grdCommands.List.Add("Remember stats on/off",    "RememberStats");
        grdCommands.List.Add("Allow ext. HUD on/off",    "AllowHUD");
        break;
    //---------- VARIOUS ----------
    Case 6:
        grdCommands.List.Add("Next Command | ",       " | ");
        grdCommands.List.Add("onrelease",             "onrelease ");
        grdCommands.List.Add("Set input",             "Set input ");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("Suicide",               "Suicide");
        grdCommands.List.Add("Say",                   "Say ");
        grdCommands.List.Add("Teamsay",               "TeamSay ");
        grdCommands.List.Add("Talk",                  "Talk ");
        grdCommands.List.Add("TeamTalk",              "TeamTalk ");
        grdCommands.List.Add("Summon",                "Summon ");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("Mapvote",               "Mutate BDBMapVote VoteMenu");
        grdCommands.List.Add("Buy menu",              "ToggleHUDBuyMenu");
        grdCommands.List.Add("Speech menu",           "SpeechKey");
        grdCommands.List.Add("Briefing (Objectives)", "ToggleHUDBriefing");
        grdCommands.List.Add("Team info",             "ToggleHUDTeamInfo");
        grdCommands.List.Add("GUI mode",              "ToggleUIMode");
        grdCommands.List.Add("ShowScores",            "ShowScores");
        grdCommands.List.Add("ShowServerInfo",        "ShowServerInfo");
        grdCommands.List.Add("SetName <playername>",  "SetName ");
        grdCommands.List.Add("ScreenFlashes ON",      "Set WinDrv.WindowsClient ScreenFlashes True");
        grdCommands.List.Add("ScreenFlashes OFF",     "Set WinDrv.WindowsClient ScreenFlashes False");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("HUD on/off",            "ToggleHUDDisplay");
        grdCommands.List.Add("Change HUD",            "ChangeHUD");
        grdCommands.List.Add("Shrink HUD",            "ShrinkHUD");
        grdCommands.List.Add("Grow HUD",              "GrowHUD");
        grdCommands.List.Add("Brightness",            "Brightness");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("Admin logout",          "AdminLogOut");
        grdCommands.List.Add("Admin reset",           "AdminReset");
        grdCommands.List.Add("PKick <PlayerID>",      "PKick ");
        grdCommands.List.Add("PKickBan <PlayerID>",   "PKickBan ");
        grdCommands.List.Add("PTempKickBan <PlayerID>", "PTempKickBan ");
        grdCommands.List.Add("Server End round",      "ServerEndRound");
        grdCommands.List.Add("End round",             "EndRound");
        grdCommands.List.Add("Kill all bots",         "KillAllBots");
        grdCommands.List.Add("Add bots <Number>",     "AddBots ");
        grdCommands.List.Add("Pause game",            "Pause");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("Quick console",         "Type");
        grdCommands.List.Add("Console",               "ConsoleKey");
        grdCommands.List.Add("Main menu",             "ShowMenu");
        grdCommands.List.Add("FullScreen on/off",     "ToggleFullScreen");
        grdCommands.List.Add("Cancel",                "Cancel");
        grdCommands.List.Add("Screen shot",           "Shot");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("Find internet games",   "MenuCmd 1 0 'find internet games");
        grdCommands.List.Add("Disconnect server",     "Disconnect");
        grdCommands.List.Add("Reconnect server",      "Reconnect");
        grdCommands.List.Add("-SuperTeam- Keybinder", "MenuCmd 4 x 'SuperTeam KeyBinder (Replace x with corresponding menu position)");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("Exec <filename>",       "Exec ");
        grdCommands.List.Add("DemoRec <name>",        "DemoRec ");
        grdCommands.List.Add("DemoStop",              "DemoStop");
        grdCommands.List.Add("DemoPlay <name>",       "DemoPlay ");
        grdCommands.List.Add("", "");
        grdCommands.List.Add("Flush",                 "Flush");
        grdCommands.List.Add("Advanced options",      "Preferences");
        break;
    //---------- CUSTOM ----------
    Case 7:
        for (i=0; i<ArrayCount(mc_asCustomCommands); i++)
        {
            if (mc_asCustomCommands[i] != "")
            grdCommands.List.Add("",mc_asCustomCommands[i]);
        };
        break;
    };
}

//------------------------------------------
//       cboKeyboard_Change
//------------------------------------------
function cboKeyboard_Change()
{
    mc_iSelectedKeyboardLayout = cboKeyboard.GetSelectedIndex();
    SaveConfig();

    switch(mc_iSelectedKeyboardLayout)
    {
    case 0:  SetKeyboard_Danish();            break;
    case 1:  SetKeyboard_EnglishUS();         break;
    case 2:  SetKeyboard_Finnish();           break;
    case 3:  SetKeyboard_FrenchBelgium();     break;
    case 4:  SetKeyboard_FrenchCanada();      break;
    case 5:  SetKeyboard_FrenchFrance();      break;
    case 6:  SetKeyboard_FrenchSwitzerland(); break;
    case 7:  SetKeyboard_German();            break;
    case 8:  SetKeyboard_Italian();           break;
    case 9:  SetKeyboard_Norwegian();         break;
    case 10: SetKeyboard_Portugues();         break;
    case 11: SetKeyboard_Spanish();           break;
    case 12: SetKeyboard_Swedish();           break;
    };
}

//------------------------------------------
//       edcNewBinding_Change
//------------------------------------------
function edcNewBinding_Change()
{
    local string sBinding;

    sBinding = edcNewBinding.GetValue();
    If(sBinding == "")
        m_sNewKeyBinding = "<Empty>";
    else
        m_sNewKeyBinding = sBinding;

    if(m_sNewKeyBinding == m_sCurrentKeyBinding)
        btnBind.bDisabled = True;
    else
        btnBind.bDisabled = False;
}

//------------------------------------------
//       grdCommands_DoubleClickRow
//------------------------------------------
//function grdCommands_DoubleClickRow(int Row)
//{
//	// defined in subclass
//}



//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//
//          K E Y B O A R D
//
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//------------------------------------------
//       SetKeyboard_KeyPadNumLockOff
//------------------------------------------
Function SetKeyboard_KeyPadNumlockOff()
{
//    SetButton(btns[33], "NumLock", 144);
//    SetButton(btns[34], "/",       111);
//    SetButton(btns[35], "*",       106);
//    SetButton(btns[36], "-",       109);

    SetButton(btns[54], "Home",     36);
    SetButton(btns[55], "u",        38);
    SetButton(btns[56], "PgDn",     33);
//    SetButton(btns[57], "+",       107);

    SetButton(btns[71], "l",        37);
    SetButton(btns[72], "",         12);
    SetButton(btns[73], "r",        39);

    SetButton(btns[87], "End",      35);
    SetButton(btns[88], "d",        40);
    SetButton(btns[89], "PgDn",     34);
//    SetButton(btns[90], "Enter",    13);

    SetButton(btns[102], "Ins",     45);
    SetButton(btns[103], "Del",     46);
}


//------------------------------------------
//       SetKeyboard_KeyPadNumLockOn
//------------------------------------------
Function SetKeyboard_KeyPadNumlockOn()
{
//    SetButton(btns[33], "NumLock", 144);
//    SetButton(btns[34], "/",       111);
//    SetButton(btns[35], "*",       106);
//    SetButton(btns[36], "-",       109);

    SetButton(btns[54], "7",       103);
    SetButton(btns[55], "8",       104);
    SetButton(btns[56], "9",       105);
//    SetButton(btns[57], "+",       107);

    SetButton(btns[71], "4",       100);
    SetButton(btns[72], "5",       101);
    SetButton(btns[73], "6",       102);

    SetButton(btns[87], "1",        97);
    SetButton(btns[88], "2",        98);
    SetButton(btns[89], "3",        99);
//    SetButton(btns[90], "Enter",    13);

    SetButton(btns[102], "0",       96);
    SetButton(btns[103], ".",      110);
}

//------------------------------------------
//       SetKeyboard_Danish
//------------------------------------------
Function SetKeyboard_Danish()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "½",       220);
    SetButton(btns[17], "1",        49);
    SetButton(btns[18], "2",        50);
    SetButton(btns[19], "3",        51);
    SetButton(btns[20], "4",        52);
    SetButton(btns[21], "5",        53);
    SetButton(btns[22], "6",        54);
    SetButton(btns[23], "7",        55);
    SetButton(btns[24], "8",        56);
    SetButton(btns[25], "9",        57);
    SetButton(btns[26], "0",        48);
    SetButton(btns[27], "+",       187);
    SetButton(btns[28], "´",       219);
    SetButton(btns[29], "Back",      8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",       9);
    SetButton(btns[38], "q",        81);
    SetButton(btns[39], "w",        87);
    SetButton(btns[40], "e",        69);
    SetButton(btns[41], "r",        82);
    SetButton(btns[42], "t",        84);
    SetButton(btns[43], "y",        89);
    SetButton(btns[44], "u",        85);
    SetButton(btns[45], "i",        73);
    SetButton(btns[46], "o",        79);
    SetButton(btns[47], "p",        80);
    SetButton(btns[48], "å",       221);
    SetButton(btns[49], "¨",       186);
    SetButton(btns[50], "'",       191);

    //Keypad/Editing is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock",20);
    SetButton(btns[59], "a",        65);
    SetButton(btns[60], "s",        83);
    SetButton(btns[61], "d",        68);
    SetButton(btns[62], "f",        70);
    SetButton(btns[63], "g",        71);
    SetButton(btns[64], "h",        72);
    SetButton(btns[65], "j",        74);
    SetButton(btns[66], "k",        75);
    SetButton(btns[67], "l",        76);
    SetButton(btns[68], "æ",       192);
    SetButton(btns[69], "ø",       222);
    SetButton(btns[70], "Enter",    13);

    //Keypad is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",    16);
    SetButton(btns[75], "z",        90);
    SetButton(btns[76], "x",        88);
    SetButton(btns[77], "c",        67);
    SetButton(btns[78], "v",        86);
    SetButton(btns[79], "b",        66);
    SetButton(btns[80], "n",        78);
    SetButton(btns[81], "m",        77);
    SetButton(btns[82], ",",       188);
    SetButton(btns[83], ".",       190);
    SetButton(btns[84], "-",       189);
    SetButton(btns[85], "Shift",    16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//------------------------------------------
//       SetKeyboard_EnglishUS
//------------------------------------------
Function SetKeyboard_EnglishUS()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "'",       192);
    SetButton(btns[17], "1",        49);
    SetButton(btns[18], "2",        50);
    SetButton(btns[19], "3",        51);
    SetButton(btns[20], "4",        52);
    SetButton(btns[21], "5",        53);
    SetButton(btns[22], "6",        54);
    SetButton(btns[23], "7",        55);
    SetButton(btns[24], "8",        56);
    SetButton(btns[25], "9",        57);
    SetButton(btns[26], "0",        48);
    SetButton(btns[27], "-",       189);
    SetButton(btns[28], "=",       187);
    SetButton(btns[29], "Back",      8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",       9);
    SetButton(btns[38], "q",        81);
    SetButton(btns[39], "w",        87);
    SetButton(btns[40], "e",        69);
    SetButton(btns[41], "r",        82);
    SetButton(btns[42], "t",        84);
    SetButton(btns[43], "y",        89);
    SetButton(btns[44], "u",        85);
    SetButton(btns[45], "i",        73);
    SetButton(btns[46], "o",        79);
    SetButton(btns[47], "p",        80);
    SetButton(btns[48], "[",       219);
    SetButton(btns[49], "]",       221);
    SetButton(btns[50], "\\",      220);

    //Keypad/Editing is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock",20);
    SetButton(btns[59], "a",        65);
    SetButton(btns[60], "s",        83);
    SetButton(btns[61], "d",        68);
    SetButton(btns[62], "f",        70);
    SetButton(btns[63], "g",        71);
    SetButton(btns[64], "h",        72);
    SetButton(btns[65], "j",        74);
    SetButton(btns[66], "k",        75);
    SetButton(btns[67], "l",        76);
    SetButton(btns[68], ";",       186);
    SetButton(btns[69], "'",       222);
    SetButton(btns[70], "Enter",    13);

    //Keypad is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",    16);
    SetButton(btns[75], "z",        90);
    SetButton(btns[76], "x",        88);
    SetButton(btns[77], "c",        67);
    SetButton(btns[78], "v",        86);
    SetButton(btns[79], "b",        66);
    SetButton(btns[80], "n",        78);
    SetButton(btns[81], "m",        77);
    SetButton(btns[82], ",",       188);
    SetButton(btns[83], ".",       190);
    SetButton(btns[84], "/",       191);
    SetButton(btns[85], "Shift",    16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//------------------------------------------
//       SetKeyboard_Finnish
//------------------------------------------
Function SetKeyboard_Finnish()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "§",       220);
    SetButton(btns[17], "1",        49);
    SetButton(btns[18], "2",        50);
    SetButton(btns[19], "3",        51);
    SetButton(btns[20], "4",        52);
    SetButton(btns[21], "5",        53);
    SetButton(btns[22], "6",        54);
    SetButton(btns[23], "7",        55);
    SetButton(btns[24], "8",        56);
    SetButton(btns[25], "9",        57);
    SetButton(btns[26], "0",        48);
    SetButton(btns[27], "+",       187);
    SetButton(btns[28], "´",       219);
    SetButton(btns[29], "Back",      8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",       9);
    SetButton(btns[38], "q",        81);
    SetButton(btns[39], "w",        87);
    SetButton(btns[40], "e",        69);
    SetButton(btns[41], "r",        82);
    SetButton(btns[42], "t",        84);
    SetButton(btns[43], "y",        89);
    SetButton(btns[44], "u",        85);
    SetButton(btns[45], "i",        73);
    SetButton(btns[46], "o",        79);
    SetButton(btns[47], "p",        80);
    SetButton(btns[48], "å",       221);
    SetButton(btns[49], "¨",       186);
    SetButton(btns[50], "'",       191);

    //Keypad/Editing is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock",20);
    SetButton(btns[59], "a",        65);
    SetButton(btns[60], "s",        83);
    SetButton(btns[61], "d",        68);
    SetButton(btns[62], "f",        70);
    SetButton(btns[63], "g",        71);
    SetButton(btns[64], "h",        72);
    SetButton(btns[65], "j",        74);
    SetButton(btns[66], "k",        75);
    SetButton(btns[67], "l",        76);
    SetButton(btns[68], "ö",       192);
    SetButton(btns[69], "ä",       222);
    SetButton(btns[70], "Enter",    13);

    //Keypad is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",    16);
    SetButton(btns[75], "z",        90);
    SetButton(btns[76], "x",        88);
    SetButton(btns[77], "c",        67);
    SetButton(btns[78], "v",        86);
    SetButton(btns[79], "b",        66);
    SetButton(btns[80], "n",        78);
    SetButton(btns[81], "m",        77);
    SetButton(btns[82], ",",       188);
    SetButton(btns[83], ".",       190);
    SetButton(btns[84], "-",       189);
    SetButton(btns[85], "Shift",    16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//------------------------------------------
//       SetKeyboard_FrenchBelgium
//------------------------------------------
Function SetKeyboard_FrenchBelgium()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "²",        222);
    SetButton(btns[17], "&",         49);
    SetButton(btns[18], "é",         50);
    SetButton(btns[19], chr(34),     51); // "
    SetButton(btns[20], "'",         52);
    SetButton(btns[21], "(",         53);
    SetButton(btns[22], "§",         54);
    SetButton(btns[23], "è",         55);
    SetButton(btns[24], "!",         56);
    SetButton(btns[25], "ç",         57);
    SetButton(btns[26], "à",         48);
    SetButton(btns[27], ")",        219);
    SetButton(btns[28], "-",        189);
    SetButton(btns[29], "Back",       8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",        9);
    SetButton(btns[38], "a",         65);
    SetButton(btns[39], "z",         90);
    SetButton(btns[40], "e",         69);
    SetButton(btns[41], "r",         82);
    SetButton(btns[42], "t",         84);
    SetButton(btns[43], "y",         89);
    SetButton(btns[44], "u",         85);
    SetButton(btns[45], "i",         73);
    SetButton(btns[46], "o",         79);
    SetButton(btns[47], "p",         80);
    SetButton(btns[48], "^",        221);
    SetButton(btns[49], "$",        186);
    SetButton(btns[50], "µ",        220);

    //Keypad/Editing is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock", 20);
    SetButton(btns[59], "q",         81);
    SetButton(btns[60], "s",         83);
    SetButton(btns[61], "d",         68);
    SetButton(btns[62], "f",         70);
    SetButton(btns[63], "g",         71);
    SetButton(btns[64], "h",         72);
    SetButton(btns[65], "j",         74);
    SetButton(btns[66], "k",         75);
    SetButton(btns[67], "l",         76);
    SetButton(btns[68], "m",         77);
    SetButton(btns[69], "ù",        192);
    SetButton(btns[70], "Enter",     13);

    //Keypad is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",     16);
    SetButton(btns[75], "w",         87);
    SetButton(btns[76], "x",         88);
    SetButton(btns[77], "c",         67);
    SetButton(btns[78], "v",         86);
    SetButton(btns[79], "b",         66);
    SetButton(btns[80], "n",         78);
    SetButton(btns[81], ",",        188);
    SetButton(btns[82], ";",        190);
    SetButton(btns[83], ":",        191);
    SetButton(btns[84], "=",        187);
    SetButton(btns[85], "Shift",     16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//------------------------------------------
//       SetKeyboard_FrenchCanada
//------------------------------------------
Function SetKeyboard_FrenchCanada()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "/",       222);
    SetButton(btns[17], "1",        49);
    SetButton(btns[18], "2",        50);
    SetButton(btns[19], "3",        51);
    SetButton(btns[20], "4",        52);
    SetButton(btns[21], "5",        53);
    SetButton(btns[22], "6",        54);
    SetButton(btns[23], "7",        55);
    SetButton(btns[24], "8",        56);
    SetButton(btns[25], "9",        57);
    SetButton(btns[26], "0",        48);
    SetButton(btns[27], "-",       189);
    SetButton(btns[28], "=",       187);
    SetButton(btns[29], "Back",      8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",       9);
    SetButton(btns[38], "q",        81);
    SetButton(btns[39], "w",        87);
    SetButton(btns[40], "e",        69);
    SetButton(btns[41], "r",        82);
    SetButton(btns[42], "t",        84);
    SetButton(btns[43], "y",        89);
    SetButton(btns[44], "u",        85);
    SetButton(btns[45], "i",        73);
    SetButton(btns[46], "o",        79);
    SetButton(btns[47], "p",        80);
    SetButton(btns[48], "^",       219);
    SetButton(btns[49], "ç",       221);
    SetButton(btns[50], "à",       220);

    //Keypad/Editing is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock",20);
    SetButton(btns[59], "a",        65);
    SetButton(btns[60], "s",        83);
    SetButton(btns[61], "d",        68);
    SetButton(btns[62], "f",        70);
    SetButton(btns[63], "g",        71);
    SetButton(btns[64], "h",        72);
    SetButton(btns[65], "j",        74);
    SetButton(btns[66], "k",        75);
    SetButton(btns[67], "l",        76);
    SetButton(btns[68], ";",       186);
    SetButton(btns[69], "è",       192);
    SetButton(btns[70], "Enter",    13);

    //Keypad is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",    16);
    SetButton(btns[75], "z",        90);
    SetButton(btns[76], "x",        88);
    SetButton(btns[77], "c",        67);
    SetButton(btns[78], "v",        86);
    SetButton(btns[79], "b",        66);
    SetButton(btns[80], "n",        78);
    SetButton(btns[81], "m",        77);
    SetButton(btns[82], ",",       188);
    SetButton(btns[83], ".",       190);
    SetButton(btns[84], "é",       191);
    SetButton(btns[85], "Shift",    16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//------------------------------------------
//       SetKeyboard_FrenchFrance
//------------------------------------------
Function SetKeyboard_FrenchFrance()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "²",        222);
    SetButton(btns[17], "&",         49);
    SetButton(btns[18], "é",         50);
    SetButton(btns[19], chr(34),     51); // "
    SetButton(btns[20], "'",         52);
    SetButton(btns[21], "(",         53);
    SetButton(btns[22], "-",         54);
    SetButton(btns[23], "è",         55);
    SetButton(btns[24], "_",         56);
    SetButton(btns[25], "ç",         57);
    SetButton(btns[26], "à",         48);
    SetButton(btns[27], ")",        219);
    SetButton(btns[28], "=",        187);
    SetButton(btns[29], "Back",       8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",        9);
    SetButton(btns[38], "a",         65);
    SetButton(btns[39], "z",         90);
    SetButton(btns[40], "e",         69);
    SetButton(btns[41], "r",         82);
    SetButton(btns[42], "t",         84);
    SetButton(btns[43], "y",         89);
    SetButton(btns[44], "u",         85);
    SetButton(btns[45], "i",         73);
    SetButton(btns[46], "o",         79);
    SetButton(btns[47], "p",         80);
    SetButton(btns[48], "^",        221);
    SetButton(btns[49], "$",        186);
    SetButton(btns[50], "*",        220);

    //Keypad/Editing is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock", 20);
    SetButton(btns[59], "q",         81);
    SetButton(btns[60], "s",         83);
    SetButton(btns[61], "d",         68);
    SetButton(btns[62], "f",         70);
    SetButton(btns[63], "g",         71);
    SetButton(btns[64], "h",         72);
    SetButton(btns[65], "j",         74);
    SetButton(btns[66], "k",         75);
    SetButton(btns[67], "l",         76);
    SetButton(btns[68], "m",         77);
    SetButton(btns[69], "ù",        192);
    SetButton(btns[70], "Enter",     13);

    //Keypad is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",     16);
    SetButton(btns[75], "w",         87);
    SetButton(btns[76], "x",         88);
    SetButton(btns[77], "c",         67);
    SetButton(btns[78], "v",         86);
    SetButton(btns[79], "b",         66);
    SetButton(btns[80], "n",         78);
    SetButton(btns[81], ",",        188);
    SetButton(btns[82], ";",        190);
    SetButton(btns[83], ":",        191);
    SetButton(btns[84], "!",        223);
    SetButton(btns[85], "Shift",     16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//------------------------------------------
//       SetKeyboard_FrenchSwitzerland
//------------------------------------------
Function SetKeyboard_FrenchSwitzerland()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "§",       191);
    SetButton(btns[17], "1",        49);
    SetButton(btns[18], "2",        50);
    SetButton(btns[19], "3",        51);
    SetButton(btns[20], "4",        52);
    SetButton(btns[21], "5",        53);
    SetButton(btns[22], "6",        54);
    SetButton(btns[23], "7",        55);
    SetButton(btns[24], "8",        56);
    SetButton(btns[25], "9",        57);
    SetButton(btns[26], "0",        48);
    SetButton(btns[27], "'",       219);
    SetButton(btns[28], "^",       221);
    SetButton(btns[29], "Back",      8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",       9);
    SetButton(btns[38], "q",        81);
    SetButton(btns[39], "w",        87);
    SetButton(btns[40], "e",        69);
    SetButton(btns[41], "r",        82);
    SetButton(btns[42], "t",        84);
    SetButton(btns[43], "z",        90);
    SetButton(btns[44], "u",        85);
    SetButton(btns[45], "i",        73);
    SetButton(btns[46], "o",        79);
    SetButton(btns[47], "p",        80);
    SetButton(btns[48], "è",       186);
    SetButton(btns[49], "¨",       192);
    SetButton(btns[50], "$",       223);

    //Keypad/Editing is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock",20);
    SetButton(btns[59], "a",        65);
    SetButton(btns[60], "s",        83);
    SetButton(btns[61], "d",        68);
    SetButton(btns[62], "f",        70);
    SetButton(btns[63], "g",        71);
    SetButton(btns[64], "h",        72);
    SetButton(btns[65], "j",        74);
    SetButton(btns[66], "k",        75);
    SetButton(btns[67], "l",        76);
    SetButton(btns[68], "é",       222);
    SetButton(btns[69], "à",       220);
    SetButton(btns[70], "Enter",    13);

    //Keypad is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",    16);
    SetButton(btns[75], "y",        89);
    SetButton(btns[76], "x",        88);
    SetButton(btns[77], "c",        67);
    SetButton(btns[78], "v",        86);
    SetButton(btns[79], "b",        66);
    SetButton(btns[80], "n",        78);
    SetButton(btns[81], "m",        77);
    SetButton(btns[82], ",",       188);
    SetButton(btns[83], ".",       190);
    SetButton(btns[84], "-",       189);
    SetButton(btns[85], "Shift",    16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//------------------------------------------
//       SetKeyboard_German
//------------------------------------------
Function SetKeyboard_German()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "^",        220);
    SetButton(btns[17], "1",         49);
    SetButton(btns[18], "2",         50);
    SetButton(btns[19], "3",         51);
    SetButton(btns[20], "4",         52);
    SetButton(btns[21], "5",         53);
    SetButton(btns[22], "6",         54);
    SetButton(btns[23], "7",         55);
    SetButton(btns[24], "8",         56);
    SetButton(btns[25], "9",         57);
    SetButton(btns[26], "0",         48);
    SetButton(btns[27], "ß",        219);
    SetButton(btns[28], "'",        221);
    SetButton(btns[29], "Back",       8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",        9);
    SetButton(btns[38], "q",         81);
    SetButton(btns[39], "w",         87);
    SetButton(btns[40], "e",         69);
    SetButton(btns[41], "r",         82);
    SetButton(btns[42], "t",         84);
    SetButton(btns[43], "z",         90);
    SetButton(btns[44], "u",         85);
    SetButton(btns[45], "i",         73);
    SetButton(btns[46], "o",         79);
    SetButton(btns[47], "p",        112);
    SetButton(btns[48], "ü",        186);
    SetButton(btns[49], "+",        187);
    SetButton(btns[50], "#",         35);

    //Keypad is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock", 20);
    SetButton(btns[59], "a",         65);
    SetButton(btns[60], "s",         83);
    SetButton(btns[61], "d",         68);
    SetButton(btns[62], "f",         70);
    SetButton(btns[63], "g",         71);
    SetButton(btns[64], "h",         72);
    SetButton(btns[65], "j",         74);
    SetButton(btns[66], "k",         75);
    SetButton(btns[67], "l",         76);
    SetButton(btns[68], "ö",        192);
    SetButton(btns[69], "ä",        222);
    SetButton(btns[70], "Enter",     13);

    //Keypad/Editing is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",     16);
    SetButton(btns[75], "y",         89);
    SetButton(btns[76], "x",         88);
    SetButton(btns[77], "c",         67);
    SetButton(btns[78], "v",         86);
    SetButton(btns[79], "b",         66);
    SetButton(btns[80], "n",         78);
    SetButton(btns[81], "m",         77);
    SetButton(btns[82], ",",        188);
    SetButton(btns[83], ".",        190);
    SetButton(btns[84], "-",        189);
    SetButton(btns[85], "Shift",     16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//------------------------------------------
//       SetKeyboard_Italian
//------------------------------------------
Function SetKeyboard_Italian()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "\\",      220);
    SetButton(btns[17], "1",        49);
    SetButton(btns[18], "2",        50);
    SetButton(btns[19], "3",        51);
    SetButton(btns[20], "4",        52);
    SetButton(btns[21], "5",        53);
    SetButton(btns[22], "6",        54);
    SetButton(btns[23], "7",        55);
    SetButton(btns[24], "8",        56);
    SetButton(btns[25], "9",        57);
    SetButton(btns[26], "0",        48);
    SetButton(btns[27], "'",       219);
    SetButton(btns[28], "ì",       221);
    SetButton(btns[29], "Back",      8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",       9);
    SetButton(btns[38], "q",        81);
    SetButton(btns[39], "w",        87);
    SetButton(btns[40], "e",        69);
    SetButton(btns[41], "r",        82);
    SetButton(btns[42], "t",        84);
    SetButton(btns[43], "y",        89);
    SetButton(btns[44], "u",        85);
    SetButton(btns[45], "i",        73);
    SetButton(btns[46], "o",        79);
    SetButton(btns[47], "p",        80);
    SetButton(btns[48], "è",       186);
    SetButton(btns[49], "+",       187);
    SetButton(btns[50], "ù",      191);

    //Keypad/Editing is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock",20);
    SetButton(btns[59], "a",        65);
    SetButton(btns[60], "s",        83);
    SetButton(btns[61], "d",        68);
    SetButton(btns[62], "f",        70);
    SetButton(btns[63], "g",        71);
    SetButton(btns[64], "h",        72);
    SetButton(btns[65], "j",        74);
    SetButton(btns[66], "k",        75);
    SetButton(btns[67], "l",        76);
    SetButton(btns[68], "ò",       192);
    SetButton(btns[69], "à",       222);
    SetButton(btns[70], "Enter",    13);

    //Keypad is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",    16);
    SetButton(btns[75], "z",        90);
    SetButton(btns[76], "x",        88);
    SetButton(btns[77], "c",        67);
    SetButton(btns[78], "v",        86);
    SetButton(btns[79], "b",        66);
    SetButton(btns[80], "n",        78);
    SetButton(btns[81], "m",        77);
    SetButton(btns[82], ",",       188);
    SetButton(btns[83], ".",       190);
    SetButton(btns[84], "-",       189);
    SetButton(btns[85], "Shift",    16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//------------------------------------------
//       SetKeyboard_Norwegian
//------------------------------------------
Function SetKeyboard_Norwegian()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "|",       220);
    SetButton(btns[17], "1",        49);
    SetButton(btns[18], "2",        50);
    SetButton(btns[19], "3",        51);
    SetButton(btns[20], "4",        52);
    SetButton(btns[21], "5",        53);
    SetButton(btns[22], "6",        54);
    SetButton(btns[23], "7",        55);
    SetButton(btns[24], "8",        56);
    SetButton(btns[25], "9",        57);
    SetButton(btns[26], "0",        48);
    SetButton(btns[27], "+",       187);
    SetButton(btns[28], "\\",      219);
    SetButton(btns[29], "Back",      8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",       9);
    SetButton(btns[38], "q",        81);
    SetButton(btns[39], "w",        87);
    SetButton(btns[40], "e",        69);
    SetButton(btns[41], "r",        82);
    SetButton(btns[42], "t",        84);
    SetButton(btns[43], "y",        89);
    SetButton(btns[44], "u",        85);
    SetButton(btns[45], "i",        73);
    SetButton(btns[46], "o",        79);
    SetButton(btns[47], "p",        80);
    SetButton(btns[48], "å",       221);
    SetButton(btns[49], "¨",       186);
    SetButton(btns[50], "'",       191);

    //Keypad/Editing is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock",20);
    SetButton(btns[59], "a",        65);
    SetButton(btns[60], "s",        83);
    SetButton(btns[61], "d",        68);
    SetButton(btns[62], "f",        70);
    SetButton(btns[63], "g",        71);
    SetButton(btns[64], "h",        72);
    SetButton(btns[65], "j",        74);
    SetButton(btns[66], "k",        75);
    SetButton(btns[67], "l",        76);
    SetButton(btns[68], "ø",       192);
    SetButton(btns[69], "æ",       222);
    SetButton(btns[70], "Enter",    13);

    //Keypad is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",    16);
    SetButton(btns[75], "z",        90);
    SetButton(btns[76], "x",        88);
    SetButton(btns[77], "c",        67);
    SetButton(btns[78], "v",        86);
    SetButton(btns[79], "b",        66);
    SetButton(btns[80], "n",        78);
    SetButton(btns[81], "m",        77);
    SetButton(btns[82], ",",       188);
    SetButton(btns[83], ".",       190);
    SetButton(btns[84], "-",       189);
    SetButton(btns[85], "Shift",    16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//------------------------------------------
//       SetKeyboard_Portugues
//------------------------------------------
Function SetKeyboard_Portugues()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "\\",      220);
    SetButton(btns[17], "1",        49);
    SetButton(btns[18], "2",        50);
    SetButton(btns[19], "3",        51);
    SetButton(btns[20], "4",        52);
    SetButton(btns[21], "5",        53);
    SetButton(btns[22], "6",        54);
    SetButton(btns[23], "7",        55);
    SetButton(btns[24], "8",        56);
    SetButton(btns[25], "9",        57);
    SetButton(btns[26], "0",        48);
    SetButton(btns[27], "'",       219);
    SetButton(btns[28], "«",       221);
    SetButton(btns[29], "Back",      8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",       9);
    SetButton(btns[38], "q",        81);
    SetButton(btns[39], "w",        87);
    SetButton(btns[40], "e",        69);
    SetButton(btns[41], "r",        82);
    SetButton(btns[42], "t",        84);
    SetButton(btns[43], "y",        89);
    SetButton(btns[44], "u",        85);
    SetButton(btns[45], "i",        73);
    SetButton(btns[46], "o",        79);
    SetButton(btns[47], "p",        80);
    SetButton(btns[48], "+",       187);
    SetButton(btns[49], "´",       186);
    SetButton(btns[50], "~",       191);

    //Keypad/Editing is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock",20);
    SetButton(btns[59], "a",        65);
    SetButton(btns[60], "s",        83);
    SetButton(btns[61], "d",        68);
    SetButton(btns[62], "f",        70);
    SetButton(btns[63], "g",        71);
    SetButton(btns[64], "h",        72);
    SetButton(btns[65], "j",        74);
    SetButton(btns[66], "k",        75);
    SetButton(btns[67], "l",        76);
    SetButton(btns[68], "ç",       192);
    SetButton(btns[69], "º",       222);
    SetButton(btns[70], "Enter",    13);

    //Keypad is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",    16);
    SetButton(btns[75], "z",        90);
    SetButton(btns[76], "x",        88);
    SetButton(btns[77], "c",        67);
    SetButton(btns[78], "v",        86);
    SetButton(btns[79], "b",        66);
    SetButton(btns[80], "n",        78);
    SetButton(btns[81], "m",        77);
    SetButton(btns[82], ",",       188);
    SetButton(btns[83], ".",       190);
    SetButton(btns[84], "-",       189);
    SetButton(btns[85], "Shift",    16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//------------------------------------------
//       SetKeyboard_Spanish
//------------------------------------------
Function SetKeyboard_Spanish()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "º",       220);
    SetButton(btns[17], "1",        49);
    SetButton(btns[18], "2",        50);
    SetButton(btns[19], "3",        51);
    SetButton(btns[20], "4",        52);
    SetButton(btns[21], "5",        53);
    SetButton(btns[22], "6",        54);
    SetButton(btns[23], "7",        55);
    SetButton(btns[24], "8",        56);
    SetButton(btns[25], "9",        57);
    SetButton(btns[26], "0",        48);
    SetButton(btns[27], "'",       219);
    SetButton(btns[28], "¡",       221);
    SetButton(btns[29], "Back",      8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",       9);
    SetButton(btns[38], "q",        81);
    SetButton(btns[39], "w",        87);
    SetButton(btns[40], "e",        69);
    SetButton(btns[41], "r",        82);
    SetButton(btns[42], "t",        84);
    SetButton(btns[43], "y",        89);
    SetButton(btns[44], "u",        85);
    SetButton(btns[45], "i",        73);
    SetButton(btns[46], "o",        79);
    SetButton(btns[47], "p",        80);
    SetButton(btns[48], "`",       186);
    SetButton(btns[49], "+",       187);
    SetButton(btns[50], "ç",       191);

    //Keypad/Editing is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock",20);
    SetButton(btns[59], "a",        65);
    SetButton(btns[60], "s",        83);
    SetButton(btns[61], "d",        68);
    SetButton(btns[62], "f",        70);
    SetButton(btns[63], "g",        71);
    SetButton(btns[64], "h",        72);
    SetButton(btns[65], "j",        74);
    SetButton(btns[66], "k",        75);
    SetButton(btns[67], "l",        76);
    SetButton(btns[68], "ñ",       192);
    SetButton(btns[69], "´",       222);
    SetButton(btns[70], "Enter",    13);

    //Keypad is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",    16);
    SetButton(btns[75], "z",        90);
    SetButton(btns[76], "x",        88);
    SetButton(btns[77], "c",        67);
    SetButton(btns[78], "v",        86);
    SetButton(btns[79], "b",        66);
    SetButton(btns[80], "n",        78);
    SetButton(btns[81], "m",        77);
    SetButton(btns[82], ",",       188);
    SetButton(btns[83], ".",       190);
    SetButton(btns[84], "-",       189);
    SetButton(btns[85], "Shift",    16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//------------------------------------------
//       SetKeyboard_Swedish
//------------------------------------------
Function SetKeyboard_Swedish()
{
    /*---- Top Row ----*/
    //Is the same on all keyboards

    /*---- Second Row ----*/
    SetButton(btns[16], "§",       220);
    SetButton(btns[17], "1",        49);
    SetButton(btns[18], "2",        50);
    SetButton(btns[19], "3",        51);
    SetButton(btns[20], "4",        52);
    SetButton(btns[21], "5",        53);
    SetButton(btns[22], "6",        54);
    SetButton(btns[23], "7",        55);
    SetButton(btns[24], "8",        56);
    SetButton(btns[25], "9",        57);
    SetButton(btns[26], "0",        48);
    SetButton(btns[27], "+",       187);
    SetButton(btns[28], "´",       219);
    SetButton(btns[29], "Back",      8);

    //Keypad/Editing is the same on all keyboards

    /*---- Third Row ----*/
    SetButton(btns[37], "Tab",       9);
    SetButton(btns[38], "q",        81);
    SetButton(btns[39], "w",        87);
    SetButton(btns[40], "e",        69);
    SetButton(btns[41], "r",        82);
    SetButton(btns[42], "t",        84);
    SetButton(btns[43], "y",        89);
    SetButton(btns[44], "u",        85);
    SetButton(btns[45], "i",        73);
    SetButton(btns[46], "o",        79);
    SetButton(btns[47], "p",        80);
    SetButton(btns[48], "å",       221);
    SetButton(btns[49], "¨",       186);
    SetButton(btns[50], "'",       191);

    //Keypad/Editing is the same on all keyboards

    /*---- Fourth Row ----*/
    SetButton(btns[58], "Caps Lock",20);
    SetButton(btns[59], "a",        65);
    SetButton(btns[60], "s",        83);
    SetButton(btns[61], "d",        68);
    SetButton(btns[62], "f",        70);
    SetButton(btns[63], "g",        71);
    SetButton(btns[64], "h",        72);
    SetButton(btns[65], "j",        74);
    SetButton(btns[66], "k",        75);
    SetButton(btns[67], "l",        76);
    SetButton(btns[68], "ö",       192);
    SetButton(btns[69], "ä",       222);
    SetButton(btns[70], "Enter",    13);

    //Keypad is the same on all keyboards

    /*---- Fifth Row ----*/
    SetButton(btns[74], "Shift",    16);
    SetButton(btns[75], "z",        90);
    SetButton(btns[76], "x",        88);
    SetButton(btns[77], "c",        67);
    SetButton(btns[78], "v",        86);
    SetButton(btns[79], "b",        66);
    SetButton(btns[80], "n",        78);
    SetButton(btns[81], "m",        77);
    SetButton(btns[82], ",",       188);
    SetButton(btns[83], ".",       190);
    SetButton(btns[84], "-",       189);
    SetButton(btns[85], "Shift",    16);

    //Keypad/Cursors is the same on all keyboards

    /*---- Bottom Row ----*/
    //Is the same on all keyboards
    //Keypad/Cursors is the same on all keyboards
}

//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//
//          U S E R D E F I N E D   F U N C T I O N S
//
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//------------------------------------------
//       BindKeyBinding
//------------------------------------------
function BindKeyBinding(int iKeyCode, string sKeyBinding)
{
    local string    sKeyName;

//    if(iKeyCode=Root.Console.ConsoleKey)
//    if(iKeyCode=TO_Console(Root.Console).SpeechKey)
//    if(iKeyCode=TO_Console(Root.Console).UseKey)

    sKeyName = GetPlayerOwner().ConsoleCommand("KEYNAME " $ iKeyCode);
    GetPlayerOwner().ConsoleCommand("SET Input " $ sKeyName $ " " $ sKeyBinding);
    ShowKeyBinding(iKeyCode);
    SetKeybindButtonColor(iKeyCode, ButtonInUse(iKeyCode));
}

//------------------------------------------
//       BindConsoleKey
//------------------------------------------
function BindConsoleKey(int iKeyCode)
{
    local int   iOldKey;

    if((iKeyCode==1) || (iKeyCode==27))
        MessageBox("Error binding key", "Cannot Assign the ConsoleKey to the specified Key.", MB_OK, MR_OK, MR_OK);
    else
    {
        iOldKey = Root.Console.ConsoleKey;
        Root.Console.ConsoleKey = iKeyCode;
    	Root.Console.SaveConfig();

        BindKeyBinding(iOldKey, "");
        if(iKeyCode!=0)
            BindKeyBinding(iKeyCode, "None");
    };
}

//------------------------------------------
//       BindSpeechKey
//------------------------------------------
function BindSpeechKey(int iKeyCode)
{
    local int   iOldKey;

    if((iKeyCode==1) || (iKeyCode==27))
        MessageBox("Error binding key", "Cannot Assign the SpeechKey to the specified Key.", MB_OK, MR_OK, MR_OK);
    else
    {
        iOldKey = TO_Console(Root.Console).SpeechKey;
        TO_Console(Root.Console).SpeechKey = iKeyCode;
    	TO_Console(Root.Console).SaveConfig();

        BindKeyBinding(iOldKey, "");
        if(iKeyCode!=0)
            BindKeyBinding(iKeyCode, "None");
    };
}

//------------------------------------------
//       BindUseKey
//------------------------------------------
function BindUseKey(int iKeyCode)
{
    local int   iOldKey;

    if((iKeyCode==1) || (iKeyCode==27))
        MessageBox("Error binding key", "Cannot Assign the UseKey to the specified Key.", MB_OK, MR_OK, MR_OK);
    else
    {
        iOldKey = TO_Console(Root.Console).UseKey;
        TO_Console(Root.Console).UseKey = iKeyCode;
    	TO_Console(Root.Console).SaveConfig();

        BindKeyBinding(iOldKey, "");
        if(iKeyCode!=0)
            BindKeyBinding(iKeyCode, "None");
    };
}


//------------------------------------------
//       ButtonInUse
//------------------------------------------
function bool ButtonInUse(int iKeyCode)
{
    local string    sKeyName;
    local bool      bReturn;

    bReturn = False;

    bReturn = (iKeyCode==Root.Console.ConsoleKey);
    if(!bReturn)
        bReturn = (iKeyCode==TO_Console(Root.Console).SpeechKey);
    if(!bReturn)
        bReturn = (iKeyCode==TO_Console(Root.Console).UseKey);
    if(!bReturn)
    {
        sKeyName = GetPlayerOwner().ConsoleCommand("KEYNAME " $ iKeyCode);
        bReturn = (GetPlayerOwner().ConsoleCommand("KEYBINDING " $ sKeyName)!="");
    };
    return bReturn;
}

//------------------------------------------
//       CreateButton
//------------------------------------------
function UWindowSmallButton CreateButton(float X, float Y, float W, string sText, int iKeyCode, Optional bool bNotVisible)
{
    local UWindowSmallButton    btn;
    local bool                  bInUse;

    btn = UWindowSmallButton(CreateControl(class'UWindowSmallButton', X, Y, W, 1));
    btn.Text = sText;
    btn.ToolTipString = string(iKeyCode);
    btn.bWindowVisible = !bNotVisible;

    if(iKeyCode < 900)
    {
        bInUse = ButtonInUse(iKeyCode);
        SetKeybindButtonColor(iKeyCode, bInUse, btn);
    };

    return btn;
}

//------------------------------------------
//       InsertCommand
//------------------------------------------
function InsertCommand(string sCommand)
{
    local string    sValue;

    sValue = Lower(Trim(edcNewBinding.GetValue()));
    if(sValue=="")
        edcNewBinding.InsertText(sCommand);
    else if(Left(sCommand,1)=="#")
        edcNewBinding.InsertText(" " $ sCommand);
    else if(instr(sValue,"consolekey")!=-1)
        MessageBox("Error Inserting command", "Cannot assign more commands to the ConsoleKey.", MB_OK, MR_OK, MR_OK);
    else if(Lower(Trim(sCommand))=="consolekey")
        MessageBox("Error Inserting command", "Cannot assign ConsoleKey to a binding with more commands.", MB_OK, MR_OK, MR_OK);
    else if(instr(sValue,"speechkey")!=-1)
        MessageBox("Error Inserting command", "Cannot assign more commands to the SpeechKey.", MB_OK, MR_OK, MR_OK);
    else if(Lower(Trim(sCommand))=="speechkey")
        MessageBox("Error Inserting command", "Cannot assign SpeechKey to a binding with more commands.", MB_OK, MR_OK, MR_OK);
    else if(instr(sValue,"usekey")!=-1)
        MessageBox("Error Inserting command", "Cannot assign more commands to the UseKey.", MB_OK, MR_OK, MR_OK);
    else if(Lower(Trim(sCommand))=="usekey")
        MessageBox("Error Inserting command", "Cannot assign UseKey to a binding with more commands.", MB_OK, MR_OK, MR_OK);
    else
        edcNewBinding.InsertText(" | " $ sCommand);
}

//------------------------------------------
//       PlayVoice
//------------------------------------------
function PlayVoice(EVoiceType eVoiceType, int iVoice)
{
    local sound sndVoice;

    sndVoice = None;

    if((iVoice>=0) || (iVoice<ArrayCount(sndVoicesFemaleT)))
    {
        switch(eVoiceType)
        {
            case vtNone:
                sndVoice = None;
                break;
            case vtFemaleT:
                sndVoice = sndVoicesFemaleT[iVoice];
                break;
            case vtMaleT:
                sndVoice = sndVoicesMaleT[iVoice];
                break;
            case vtFemaleSF:
                sndVoice = sndVoicesFemaleSF[iVoice];
                break;
            case vtMaleSF:
                sndVoice = sndVoicesMaleSF[iVoice];
                break;
        };
    };

    if(sndVoice!=None)
        GetPlayerOwner().PlaySound(sndVoice);
}

//------------------------------------------
//       SetButton
//------------------------------------------
function SetButton(UWindowSmallButton btn, string sText, int iKeyCode)
{
    local bool  bInUse;

    btn.Text = sText;
    btn.ToolTipString = string(iKeyCode);
    if(iKeyCode < 900)
    {
        bInUse = ButtonInUse(iKeyCode);
        SetKeybindButtonColor(iKeyCode, bInUse, btn);
    };
}

//------------------------------------------
//       SetKeybindButtonColor
//------------------------------------------
function SetKeybindButtonColor(int iKeyCode, bool bInUse, Optional UWindowSmallButton btn)
{
    local int i;

    if(btn==none)
    {
        log("SetKeybindButtonColor["$iKeyCode$"] bInUse["$bInUse$"]");
        for (i=0; i<ArrayCount(btns); i++)
        {
            if (btns[i].ToolTipString == string(iKeyCode))
                btn = btns[i];
        };
    };

    if(btn!=none)
    {
        if(bInUse)
        {
            btn.TextColor.R = 0;
            btn.TextColor.G = 0;
            btn.TextColor.B = 0;
        }
        else
        {
            btn.TextColor.R = 255;
            btn.TextColor.G = 0;
            btn.TextColor.B = 0;
        };
    };
}

//------------------------------------------
//       ShowAboutBox
//------------------------------------------
function ShowAboutBox()
{
    MessageBox("About",
               "Tactical Ops: AoT" $ chr(13) $
               "SuperTeam - Keybinder " $ chr(13) $
               chr(13) $
               "version 1.2" $ chr(13) $
               chr(13) $
               "Programmed By:" $ chr(13) $
               "Andrew 'SuperDre' Jakobs" $ chr(13) $
               chr(13) $
               "Copyright 2002 SuperTeam" $ chr(13) $
               chr(13) $
               "Email: Andrew_Jakobs@hotmail.com",
               MB_OK, MR_OK);
}

//------------------------------------------
//       ShowKeyBinding
//------------------------------------------
function ShowKeyBinding(int iKeyCode)
{
    local string sKeyBinding;
    local string sKeyName;

    m_sSelectedKeyName = "";
    m_iSelectedKeyCode = 0;

    m_sCurrentKeyBinding = "";
    m_sNewKeyBinding = "";

    sKeyBinding = "";

    sKeyName = GetPlayerOwner().ConsoleCommand("KEYNAME " $ iKeyCode);

    switch(iKeyCode)
    {
        case Root.Console.ConsoleKey:
            sKeyBinding = "ConsoleKey";
            break;
        case TO_Console(Root.Console).SpeechKey:
            sKeyBinding = "SpeechKey";
            break;
        case TO_Console(Root.Console).UseKey:
            sKeyBinding = "UseKey";
            break;
        default:
            if (sKeyName != "")
                sKeyBinding = GetPlayerOwner().ConsoleCommand("KEYBINDING " $ sKeyName);
    };

    btnBind.bDisabled = True;
    m_iSelectedKeyCode = iKeyCode;
    m_sSelectedKeyName = sKeyName;

    if(sKeyBinding == "")
        m_sCurrentKeyBinding = "<Empty>";
    else
        m_sCurrentKeyBinding = sKeyBinding;
    m_sNewKeyBinding = m_sCurrentKeyBinding;
    edcNewBinding.EditBox.Clear();
    edcNewBinding.EditBox.Offset = 0;
    edcNewBinding.SetValue(sKeyBinding);
    edcNewBinding.EditBox.CaretOffset = Len(sKeyBinding);
}


//------------------------------------------
//       ShowVoiceButtons
//------------------------------------------
Function ShowVoiceButtons(bool bShow)
{
    if(bShow)
    {
        btnVoices[0].WinWidth=60;
        btnVoices[1].WinWidth=60;
        btnVoices[2].WinWidth=60;
        btnVoices[3].WinWidth=60;
    }
    else
    {
        btnVoices[0].WinWidth=0;
        btnVoices[1].WinWidth=0;
        btnVoices[2].WinWidth=0;
        btnVoices[3].WinWidth=0;
    };
}

//------------------------------------------
//       ShowCustomButtons
//------------------------------------------
Function ShowCustomButtons(bool bShow)
{
    if(bShow)
    {
        btnCustoms[0].WinWidth=60;
//        btnCustoms[1].WinWidth=60;
    }
    else
    {
        btnCustoms[0].WinWidth=0;
//        btnCustoms[1].WinWidth=0;
    };
}

//------------------------------------------
//       TestBrowser
//------------------------------------------
//function TestBrowser()
//{
//	local Class<UBrowserMainWindow> UBrowserClass;
//	local string  sPlayername;
//
//    sPlayername = edcNewBinding.GetValue();
//
//	if ( BrowserWindow == None )
//	{
//		UBrowserClass=Class<UBrowserMainWindow>(DynamicLoadObject(UBrowserClassName,Class'Class'));
//		BrowserWindow=UBrowserMainWindow(Root.CreateWindow(UBrowserClass,50.00,30.00,500.00,300.00));
//	}
//	else
//	{
//		BrowserWindow.ShowWindow();
//		BrowserWindow.BringToFront();
//	}
//
////	if ( bOpenLocation )
////	{
////		BrowserWindow.ShowOpenWindow();
////	}
////	if ( bOpenLAN )
////	{
////		BrowserWindow.SelectLAN();
////	}
////	else
////	{
//		BrowserWindow.SelectInternet();

//	//	TO_BrowserFavoriteServers(TO_BrowserMainWindowCW(browserwindow).FC).

////	}
////	bOpenLocation=False;
//}


//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//
//          G R A P H I X   F U N C T I O N S
//
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//------------------------------------------
//       DrawFrame
//------------------------------------------
function DrawFrame(Canvas C, float fLeft, float fTop, float fWidth, float fHeight, string sCaption)
{
    local float  fTextWidth, fTextHeight;

    TextSize(C, sCaption, fTextWidth, fTextHeight);

    //Left
	DrawStretchedTexture(C, fLeft, fTop, 1, fHeight, Texture'BlackTexture');
    //Right
	DrawStretchedTexture(C, fLeft + fWidth - 1, fTop, 1, fHeight, Texture'BlackTexture');
    //Top
	DrawStretchedTexture(C, fLeft, fTop, 5, 1, Texture'BlackTexture');
	DrawStretchedTexture(C, fLeft + 5 + fTextWidth, fTop, fWidth - 5 - fTextWidth, 1, Texture'BlackTexture');
    //Bottom
	DrawStretchedTexture(C, fLeft, fTop + fHeight - 1, fWidth, 1, Texture'BlackTexture');
    //Caption
    DrawText(C, fLeft + 5, fTop - (fTextHeight / 2), 1, fTextHeight, sCaption, TA_Left);
}

//------------------------------------------
//       DrawText
//------------------------------------------
final function DrawText(Canvas C, float fLeft, float fTop, float fWidth, float fHeight, coerce string sText, TextAlign Align)
{
    local float     TW, TH, TX, TY;

    TextSize(C, sText, TW, TH);

    TY = fTop + ((fHeight - TH) / 2);
    switch(Align)
    {
    Case TA_Left:
         TX = fLeft;
         break;
    Case TA_Center:
         TX = fLeft + ((fWidth - TW) / 2);
         break;
    Case TA_Right:
         TX = fLeft + fWidth - TW;
         break;
    }
    ClipText(C, TX, TY, sText);
}

//------------------------------------------
//       WrapClipText_
//------------------------------------------
// This is an altered WrapClipText
final function int WrapClipText_(Canvas C, float fLeft, float fTop, float W, float H, coerce string S, optional bool bCheckHotkey)
{
    local bool     bCR, bSentry;
    local float    X, Y;
    local float    TW, TH;
    local float    pW, pH;
    local int      i;
    local int      NumLines;
    local int      SpacePos, CRPos, WordPos, TotalPos;
    local string   Out, Temp, Padding;

    X = fLeft;
    Y = fTop;

    // replace \\n's with Chr(13)'s
    i = InStr(S, "\\n");
    while(i != -1)
    {
         S = Left(S, i) $ Chr(13) $ Mid(S, i + 2);
         i = InStr(S, "\\n");
    }

    i = 0;
    bSentry = True;
    Out = "";
    NumLines = 1;
    while( bSentry && Y < fTop + H)
    {
         // Get the line to be drawn.
         if(Out == "")
         {
              i++;
              Out = S;
         }
              // Find the word boundary.
         SpacePos = InStr(Out, " ");
         CRPos = InStr(Out, Chr(13));

         bCR = False;
         if(CRPos != -1 && (CRPos < SpacePos || SpacePos == -1))
         {
              WordPos = CRPos;
              bCR = True;
         }
         else
         {
              WordPos = SpacePos;
         }

         // Get the current word.
         C.SetPos(0, 0);
         if(WordPos == -1)
              Temp = Out;
         else
              Temp = Left(Out, WordPos)$" ";
         TotalPos += WordPos;

         TextSize(C, Temp, TW, TH);

         // Calculate draw offset.
         if(TW + X > fLeft + W && X > 0)
         {
             X = fLeft;
             Y += TH;
             NumLines++;
         }

         // Draw the line.
         ClipText(C, X, Y, Temp, bCheckHotKey);

         // Increment the draw offset.
         X += TW;
         if(bCR)
         {
              X =0;
              Y += TH;
              NumLines++;
         }
         Out = Mid(Out, Len(Temp));
         if ((Out == "") && (i > 0))
              bSentry = False;
    }
    return NumLines;
}


//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//
//          S T R I N G   F U N C T I O N S
//
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//THESE FUNCTION ARE TAKEN FROM  http://wiki.beyondunreal.com/wiki/Useful_String_Functions

static final function string Lower(coerce string Text)
{
  local int IndexChar;

  for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
    if (Mid(Text, IndexChar, 1) >= "A" &&
        Mid(Text, IndexChar, 1) <= "Z")
      Text = Left(Text, IndexChar) $ Chr(Asc(Mid(Text, IndexChar, 1)) + 32) $ Mid(Text, IndexChar + 1);

  return Text;
}

static final function string LTrim(coerce string S)
{
    while (Left(S, 1) == " ")
        S = Right(S, Len(S) - 1);
    return S;
}

static final function string RTrim(coerce string S)
{
    while (Right(S, 1) == " ")
        S = Left(S, Len(S) - 1);
    return S;
}

static final function string Trim(coerce string S)
{
    return LTrim(RTrim(S));
}

//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//
//          S E R V E R   F U N C T I O N S (Unused at the moment)
//
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//============================================================================
// Following Routines are for the serverlist
//function Tick(float Delta)
//{
//	PingedList.Tick(Delta);
//
//	if(PingedList.bNeedUpdateCount)
//	{
//		PingedList.UpdateServerCount();
//		PingedList.bNeedUpdateCount = False;
//	}
//
////	// AutoRefresh local servers
////	if(AutoRefreshTime > 0)
////	{
////		TimeElapsed += Delta;
////
////		if(TimeElapsed > AutoRefreshTime)
////		{
////			TimeElapsed = 0;
////			Refresh(,True, bNoAutoSort);
////		}
////	}
//}


//function RefreshServerList(optional bool bInitial, optional bool bSaveExistingList, optional bool bInNoSort)
//{
//	if(!bSaveExistingList && PingedList != None)
//	{
//		PingedList.DestroyList();
//		PingedList = None;
////		Grid.SelectedServer = None;
//	}
//
//	if(PingedList == None)
//	{
//		PingedList=New ServerListClass;
////		PingedList.Owner = UBrowserServerListWindow(Self);
//		PingedList.SetupSentinel(True);
//		PingedList.bSuspendableSort = True;
//	}
//	else
//	{
//		TagServersAsOld();
//	}
//
//	if(UnpingedList != None)
//		UnpingedList.DestroyList();
//
//	if(!bSaveExistingList)
//	{
//		UnpingedList = New ServerListClass;
////		UnpingedList.Owner =  UBrowserServerListWindow(Self);
//		UnpingedList.SetupSentinel(False);
//	}
//
//	PingState = PS_QueryServer;
//	if(factory != none)
//        Factory.Shutdown();
//    factory = none;
//
//	Factory= UBrowserServerListFactory(BuildObjectWithProperties("TOSystem.TO_BrowserModFact,GameType=s_SWATGame,bCompatibleServersOnly=True,MasterServerAddress=master0.gamespy.com,MasterServerTCPPort=28900,Region=0,GameName=ut"));
//
//	Factory.PingedList = PingedList;
//	Factory.UnpingedList = UnpingedList;
//
//	if(bSaveExistingList)
//		Factory.Owner = PingedList;
//	else
//		Factory.Owner = UnpingedList;
//
//    Factory.Query(,bInitial);
//}

//function TagServersAsOld()
//{
//	local UBrowserServerList l;
//
//	for(l = UBrowserServerList(PingedList.Next);l != None;l = UBrowserServerList(l.Next))
//		l.bOldServer = True;
//}

//function RemoveOldServers()
//{
//	local UBrowserServerList l, n;
//
//	l = UBrowserServerList(PingedList.Next);
//	while(l != None)
//	{
//		n = UBrowserServerList(l.Next);
//
//		if(l.bOldServer)
//		{
////			if(Grid.SelectedServer == l)
////				Grid.SelectedServer = n;
//
//			l.Remove();
//		}
//		l = n;
//	}
//}


//function QueryFinished(UBrowserServerListFactory Fact, bool bSuccess, optional string ErrorMsg)
//{
//	local int i;
//	local bool bDone;
//
//	bDone = True;
//
//	if(!bSuccess)
//	{
//		PingState = PS_QueryFailed;
//		ErrorString = ErrorMsg;
//
//		// don't ping and report success if we have no servers.
//		if(bDone && UnpingedList.Count() == 0)
//		{
//			return;
//		}
//	}
//	else
//		ErrorString = "";
//
//	if(bDone)
//	{
//		RemoveOldServers();
//
//		PingState = PS_Pinging;
//		if(!bNoSort && !Fact.bIncrementalPing)
//			PingedList.Sort();
//		UnpingedList.PingServers(True, bNoSort || Fact.bIncrementalPing);
//	}
//}


//function PingFinished()
//{
//	PingState = PS_Done;
//}

//End routines serverlist
//============================================================================
//============================================================================

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

defaultproperties
{
    m_asCategories(0)="Buy"
    m_asCategories(1)="Speech"
    m_asCategories(2)="Gestures"
    m_asCategories(3)="Weapons"
    m_asCategories(4)="Movement"
    m_asCategories(5)="TOST"
    m_asCategories(6)="Various"
    m_asCategories(7)="<Custom>"
    m_asKeyboards(0)="Danish"
    m_asKeyboards(1)="English US"
    m_asKeyboards(2)="Finnish"
    m_asKeyboards(3)="French (Belgium)"
    m_asKeyboards(4)="French (Canada)"
    m_asKeyboards(5)="French (France)"
    m_asKeyboards(6)="French (Switzerland)"
    m_asKeyboards(7)="German"
    m_asKeyboards(8)="Italian"
    m_asKeyboards(9)="Norwegian"
    m_asKeyboards(10)="Portugues"
    m_asKeyboards(11)="Spanish (intl)"
    m_asKeyboards(12)="Swedish"
    mc_bNumLock=True
    mc_iSelectedKeyboardLayout=1
    sndVoicesFemaleT(0)=Sound'VoiceFemaleT1.(All).FT1_Ack_ICopy'
    sndVoicesFemaleT(1)=Sound'VoiceFemaleT1.(All).FT1_Ack_RogerThat'
    sndVoicesFemaleT(2)=Sound'VoiceFemaleT1.(All).FT1_Ack_YouGotIt'
    sndVoicesFemaleT(3)=Sound'VoiceFemaleT1.(All).FT1_Ack_Negative'
    sndVoicesFemaleT(5)=Sound'VoiceFemaleT1.(All).FT1_FF1'
    sndVoicesFemaleT(6)=Sound'VoiceFemaleT1.(All).FT1_FF1'
    sndVoicesFemaleT(8)=Sound'VoiceFemaleT1.(All).FT1_Group_5Secb4Assault'
    sndVoicesFemaleT(9)=Sound'VoiceFemaleT1.(All).FT1_Group_GetInPosition'
    sndVoicesFemaleT(10)=Sound'VoiceFemaleT1.(All).FT1_Group_KeepMoving'
    sndVoicesFemaleT(11)=Sound'VoiceFemaleT1.(All).FT1_Group_MeetAtRendezVous'
    sndVoicesFemaleT(12)=Sound'VoiceFemaleT1.(All).FT1_Group_SplitInPairs'
    sndVoicesFemaleT(13)=Sound'VoiceFemaleT1.(All).FT1_Group_StayTogetherTeam'
    sndVoicesFemaleT(15)=Sound'VoiceFemaleT1.(All).FT1_Order_ReturnToBase'
    sndVoicesFemaleT(16)=Sound'VoiceFemaleT1.(All).FT1_Order_HoldThisPosition'
    sndVoicesFemaleT(17)=Sound'VoiceFemaleT1.(All).FT1_Order_LetsCleanThisPlaceOut'
    sndVoicesFemaleT(18)=Sound'VoiceFemaleT1.(All).FT1_Order_CoverMe'
    sndVoicesFemaleT(19)=Sound'VoiceFemaleT1.(All).FT1_Order_AttackMainTarget'
    sndVoicesFemaleT(21)=Sound'VoiceFemaleT1.(All).FT1_Report_EnemyDown'
    sndVoicesFemaleT(22)=Sound'VoiceFemaleT1.(All).FT1_Game_HostageRescued'
    sndVoicesFemaleT(23)=Sound'VoiceFemaleT1.(All).FT1_Game_BombHasBeenPlanted'
    sndVoicesFemaleT(24)=Sound'VoiceFemaleT1.(All).FT1_Game_FireInTheHole'
    sndVoicesFemaleT(25)=Sound'VoiceFemaleT1.(All).FT1_Report_IveGotYourBack'
    sndVoicesFemaleT(26)=Sound'VoiceFemaleT1.(All).FT1_Status_ImHit'
    sndVoicesFemaleT(27)=Sound'VoiceFemaleT1.(All).FT1_Status_Emergency'
    sndVoicesFemaleT(28)=Sound'VoiceFemaleT1.(All).FT1_Game_CoverYourEyes'
    sndVoicesFemaleT(29)=Sound'VoiceFemaleT1.(All).FT1_Report_AreaCleared'
    sndVoicesFemaleT(30)=Sound'VoiceFemaleT1.(All).FT1_Report_EnemySpotted'
    sndVoicesFemaleT(31)=Sound'VoiceFemaleT1.(All).FT1_Report_IllKeepThemBusy'
    sndVoicesFemaleT(32)=Sound'VoiceFemaleT1.(All).FT1_Report_ImGoingIn'
    sndVoicesFemaleT(33)=Sound'VoiceFemaleT1.(All).FT1_Report_ImInPosition'
    sndVoicesFemaleT(34)=Sound'VoiceFemaleT1.(All).FT1_Report_ObjectiveAccomplished'
    sndVoicesFemaleT(35)=Sound'VoiceFemaleT1.(All).FT1_Report_TargetInSight'
    sndVoicesFemaleT(37)=Sound'VoiceFemaleT1.(All).FT1_Status_Emergency'
    sndVoicesFemaleT(38)=Sound'VoiceFemaleT1.(All).FT1_Status_FallingBack'
    sndVoicesFemaleT(39)=Sound'VoiceFemaleT1.(All).FT1_Status_ImHit'
    sndVoicesFemaleT(40)=Sound'VoiceFemaleT1.(All).FT1_Status_ImUnderHeavyAttack'
    sndVoicesFemaleT(41)=Sound'VoiceFemaleT1.(All).FT1_Status_INeedSomeBackupFast'
    sndVoicesFemaleT(42)=Sound'VoiceFemaleT1.(All).FT1_Status_WatchForCover'
    sndVoicesMaleT(0)=Sound'VoiceMaleT1.(All).T1_Ack_ICopy'
    sndVoicesMaleT(1)=Sound'VoiceMaleT1.(All).T1_Ack_RogerThat'
    sndVoicesMaleT(2)=Sound'VoiceMaleT1.(All).T1_Ack_YouGotIt'
    sndVoicesMaleT(3)=Sound'VoiceMaleT1.(All).T1_Ack_Negative'
    sndVoicesMaleT(5)=Sound'VoiceMaleT1.(All).T1_FF1'
    sndVoicesMaleT(6)=Sound'VoiceMaleT1.(All).T1_FF2'
    sndVoicesMaleT(8)=Sound'VoiceMaleT1.(All).T1_Group_5secb4assault'
    sndVoicesMaleT(9)=Sound'VoiceMaleT1.(All).T1_Group_getinposition'
    sndVoicesMaleT(10)=Sound'VoiceMaleT1.(All).T1_Group_keepmoving'
    sndVoicesMaleT(11)=Sound'VoiceMaleT1.(All).T1_Group_meetatrendezvous'
    sndVoicesMaleT(12)=Sound'VoiceMaleT1.(All).T1_Group_splitinpairs'
    sndVoicesMaleT(13)=Sound'VoiceMaleT1.(All).T1_Group_staytogetherteam'
    sndVoicesMaleT(15)=Sound'VoiceMaleT1.(All).T1_Order_returntobase'
    sndVoicesMaleT(16)=Sound'VoiceMaleT1.(All).T1_Order_holdthisposition'
    sndVoicesMaleT(17)=Sound'VoiceMaleT1.(All).T1_Order_letscleanthisplaceout'
    sndVoicesMaleT(18)=Sound'VoiceMaleT1.(All).T1_Order_coverme'
    sndVoicesMaleT(19)=Sound'VoiceMaleT1.(All).T1_Order_attackmaintarget'
    sndVoicesMaleT(21)=Sound'VoiceMaleT1.(All).T1_Report_enemydown'
    sndVoicesMaleT(22)=Sound'VoiceMaleT1.(All).T1_Game_hostagerescued'
    sndVoicesMaleT(23)=Sound'VoiceMaleT1.(All).T1_Game_BombHasBeenPlanted'
    sndVoicesMaleT(24)=Sound'VoiceMaleT1.(All).T1_Game_fireinthehole'
    sndVoicesMaleT(25)=Sound'VoiceMaleT1.(All).T1_Report_ivegotyourback'
    sndVoicesMaleT(26)=Sound'VoiceMaleT1.(All).T1_Status_imhit'
    sndVoicesMaleT(27)=Sound'VoiceMaleT1.(All).T1_Status_emergency'
    sndVoicesMaleT(28)=Sound'VoiceMaleT1.(All).T1_Game_CoverYourEyes'
    sndVoicesMaleT(29)=Sound'VoiceMaleT1.(All).T1_Report_areacleared'
    sndVoicesMaleT(30)=Sound'VoiceMaleT1.(All).T1_Report_enemyspotted'
    sndVoicesMaleT(31)=Sound'VoiceMaleT1.(All).T1_Report_illkeepthembusy'
    sndVoicesMaleT(32)=Sound'VoiceMaleT1.(All).T1_Report_imgoingin'
    sndVoicesMaleT(33)=Sound'VoiceMaleT1.(All).T1_Report_iminposition'
    sndVoicesMaleT(34)=Sound'VoiceMaleT1.(All).T1_Report_objectiveaccomplished'
    sndVoicesMaleT(35)=Sound'VoiceMaleT1.(All).T1_Report_targetinsight'
    sndVoicesMaleT(37)=Sound'VoiceMaleT1.(All).T1_Status_emergency'
    sndVoicesMaleT(38)=Sound'VoiceMaleT1.(All).T1_Status_fallingback'
    sndVoicesMaleT(39)=Sound'VoiceMaleT1.(All).T1_Status_imhit'
    sndVoicesMaleT(40)=Sound'VoiceMaleT1.(All).T1_Status_imunderheavyattack'
    sndVoicesMaleT(41)=Sound'VoiceMaleT1.(All).T1_Status_ineedsomebackupfast'
    sndVoicesMaleT(42)=Sound'VoiceMaleT1.(All).T1_Status_watchforcover'
    sndVoicesFemaleSF(0)=Sound'VoiceFemaleSF1.(All).FSF1_Ack_ICopy'
    sndVoicesFemaleSF(1)=Sound'VoiceFemaleSF1.(All).FSF1_Ack_RogerThat'
    sndVoicesFemaleSF(2)=Sound'VoiceFemaleSF1.(All).FSF1_Ack_YouGotIt'
    sndVoicesFemaleSF(3)=Sound'VoiceFemaleSF1.(All).FSF1_Ack_Negative'
    sndVoicesFemaleSF(5)=Sound'VoiceFemaleSF1.(All).FSF1_FF1'
    sndVoicesFemaleSF(6)=Sound'VoiceFemaleSF1.(All).FSF1_FF1'
    sndVoicesFemaleSF(8)=Sound'VoiceFemaleSF1.(All).FSF1_Group_5secb4Assault'
    sndVoicesFemaleSF(9)=Sound'VoiceFemaleSF1.(All).FSF1_Group_GetInPosition'
    sndVoicesFemaleSF(10)=Sound'VoiceFemaleSF1.(All).FSF1_Group_KeepMoving'
    sndVoicesFemaleSF(11)=Sound'VoiceFemaleSF1.(All).FSF1_Group_MeetAtRendezVous'
    sndVoicesFemaleSF(12)=Sound'VoiceFemaleSF1.(All).FSF1_Group_SplitInPairs'
    sndVoicesFemaleSF(13)=Sound'VoiceFemaleSF1.(All).FSF1_Group_StayTogetherTeam'
    sndVoicesFemaleSF(15)=Sound'VoiceFemaleSF1.(All).FSF1_Order_ReturnToBase'
    sndVoicesFemaleSF(16)=Sound'VoiceFemaleSF1.(All).FSF1_Order_HoldThisPosition'
    sndVoicesFemaleSF(17)=Sound'VoiceFemaleSF1.(All).FSF1_Order_LetsCleanThisPlaceOut'
    sndVoicesFemaleSF(18)=Sound'VoiceFemaleSF1.(All).FSF1_Order_CoverMe'
    sndVoicesFemaleSF(19)=Sound'VoiceFemaleSF1.(All).FSF1_Order_AttackMainTarget'
    sndVoicesFemaleSF(21)=Sound'VoiceFemaleSF1.(All).FSF1_Report_EnemyDown'
    sndVoicesFemaleSF(22)=Sound'VoiceFemaleSF1.(All).FSF1_Game_HostageRescued'
    sndVoicesFemaleSF(23)=Sound'VoiceFemaleSF1.(All).FSF1_Game_BombHasBeenPlanted'
    sndVoicesFemaleSF(24)=Sound'VoiceFemaleSF1.(All).FSF1_Game_FireInTheHole'
    sndVoicesFemaleSF(25)=Sound'VoiceFemaleSF1.(All).FSF1_Report_IveGotYourBack'
    sndVoicesFemaleSF(26)=Sound'VoiceFemaleSF1.(All).FSF1_Status_ImHit'
    sndVoicesFemaleSF(27)=Sound'VoiceFemaleSF1.(All).FSF1_Status_Emergency'
    sndVoicesFemaleSF(28)=Sound'VoiceFemaleSF1.(All).FSF1_Game_CoverYourEyes'
    sndVoicesFemaleSF(29)=Sound'VoiceFemaleSF1.(All).FSF1_Report_AreaCleared'
    sndVoicesFemaleSF(30)=Sound'VoiceFemaleSF1.(All).FSF1_Report_EnemySpotted'
    sndVoicesFemaleSF(31)=Sound'VoiceFemaleSF1.(All).FSF1_Report_IllKeepThemBusy'
    sndVoicesFemaleSF(32)=Sound'VoiceFemaleSF1.(All).FSF1_Report_ImGoingIn'
    sndVoicesFemaleSF(33)=Sound'VoiceFemaleSF1.(All).FSF1_Report_ImPosition'
    sndVoicesFemaleSF(34)=Sound'VoiceFemaleSF1.(All).FSF1_Report_ObjectiveAccomplished'
    sndVoicesFemaleSF(35)=Sound'VoiceFemaleSF1.(All).FSF1_Report_TargetInsight'
    sndVoicesFemaleSF(37)=Sound'VoiceFemaleSF1.(All).FSF1_Status_Emergency'
    sndVoicesFemaleSF(38)=Sound'VoiceFemaleSF1.(All).FSF1_Status_FallingBack'
    sndVoicesFemaleSF(39)=Sound'VoiceFemaleSF1.(All).FSF1_Status_ImHit'
    sndVoicesFemaleSF(40)=Sound'VoiceFemaleSF1.(All).FSF1_Status_ImUnderHeavyAttack'
    sndVoicesFemaleSF(41)=Sound'VoiceFemaleSF1.(All).FSF1_Status_INeedSomeBackupFast'
    sndVoicesFemaleSF(42)=Sound'VoiceFemaleSF1.(All).FSF1_Status_WatchForCover'
    sndVoicesMaleSF(0)=Sound'VoiceMaleSF1.(All).SF1_Ack_icopy'
    sndVoicesMaleSF(1)=Sound'VoiceMaleSF1.(All).SF1_Ack_rogerthat'
    sndVoicesMaleSF(2)=Sound'VoiceMaleSF1.(All).SF1_Ack_yougotit'
    sndVoicesMaleSF(3)=Sound'VoiceMaleSF1.(All).SF1_Ack_negative'
    sndVoicesMaleSF(5)=Sound'VoiceMaleSF1.(All).SF1_FF1'
    sndVoicesMaleSF(6)=Sound'VoiceMaleSF1.(All).SF1_FF2'
    sndVoicesMaleSF(8)=Sound'VoiceMaleSF1.(All).SF1_Group_5secb4assault'
    sndVoicesMaleSF(9)=Sound'VoiceMaleSF1.(All).SF1_Group_GetInPosition'
    sndVoicesMaleSF(10)=Sound'VoiceMaleSF1.(All).SF1_Group_KeepMoving'
    sndVoicesMaleSF(11)=Sound'VoiceMaleSF1.(All).SF1_Group_MeetAtRendezVous'
    sndVoicesMaleSF(12)=Sound'VoiceMaleSF1.(All).SF1_Group_SplitInPairs'
    sndVoicesMaleSF(13)=Sound'VoiceMaleSF1.(All).SF1_Group_StayTogetherTeam'
    sndVoicesMaleSF(15)=Sound'VoiceMaleSF1.(All).SF1_Order_returntobase'
    sndVoicesMaleSF(16)=Sound'VoiceMaleSF1.(All).SF1_Order_holdthisposition'
    sndVoicesMaleSF(17)=Sound'VoiceMaleSF1.(All).SF1_Order_letscleanthisplaceout'
    sndVoicesMaleSF(18)=Sound'VoiceMaleSF1.(All).SF1_Order_coverme'
    sndVoicesMaleSF(19)=Sound'VoiceMaleSF1.(All).SF1_Order_attackmaintarget'
    sndVoicesMaleSF(21)=Sound'VoiceMaleSF1.(All).SF1_Report_enemydown'
    sndVoicesMaleSF(22)=Sound'VoiceMaleSF1.(All).SF1_Game_HostageRescued'
    sndVoicesMaleSF(23)=Sound'VoiceMaleSF1.(All).SF1_Game_BombHasBeenPlanted'
    sndVoicesMaleSF(24)=Sound'VoiceMaleSF1.(All).SF1_Game_FireInTheHole'
    sndVoicesMaleSF(25)=Sound'VoiceMaleSF1.(All).SF1_Report_ivegotyourback'
    sndVoicesMaleSF(26)=Sound'VoiceMaleSF1.(All).SF1_Status_imhit'
    sndVoicesMaleSF(27)=Sound'VoiceMaleSF1.(All).SF1_Status_emergency'
    sndVoicesMaleSF(28)=Sound'VoiceMaleSF1.(All).SF1_Game_CoverYourEyes'
    sndVoicesMaleSF(29)=Sound'VoiceMaleSF1.(All).SF1_Report_areacleared'
    sndVoicesMaleSF(30)=Sound'VoiceMaleSF1.(All).SF1_Report_enemyspotted'
    sndVoicesMaleSF(31)=Sound'VoiceMaleSF1.(All).SF1_Report_IllKeepThemBusy'
    sndVoicesMaleSF(32)=Sound'VoiceMaleSF1.(All).SF1_Report_ImGoingIn'
    sndVoicesMaleSF(33)=Sound'VoiceMaleSF1.(All).SF1_Report_iminposition'
    sndVoicesMaleSF(34)=Sound'VoiceMaleSF1.(All).SF1_Report_objectiveaccomplished'
    sndVoicesMaleSF(35)=Sound'VoiceMaleSF1.(All).SF1_Report_targetinsight'
    sndVoicesMaleSF(37)=Sound'VoiceMaleSF1.(All).SF1_Status_emergency'
    sndVoicesMaleSF(38)=Sound'VoiceMaleSF1.(All).SF1_Status_FallingBack'
    sndVoicesMaleSF(39)=Sound'VoiceMaleSF1.(All).SF1_Status_imhit'
    sndVoicesMaleSF(40)=Sound'VoiceMaleSF1.(All).SF1_Status_imunderheavyattack'
    sndVoicesMaleSF(41)=Sound'VoiceMaleSF1.(All).SF1_Status_ineedsomebackupfast'
    sndVoicesMaleSF(42)=Sound'VoiceMaleSF1.(All).SF1_Status_watchforcover'
}
