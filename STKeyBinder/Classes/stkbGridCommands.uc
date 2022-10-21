//-----------------------------------------------------------
//
//-----------------------------------------------------------
class stkbGridCommands expands UWindowGrid;

var stkbCommandList         List;
var stkbCommandList         SelectedListItem;
var localized string        GridName;

function Created()
{
    local float Width;

	Super.Created();

    List = new class'stkbCommandList';
    List.SetupSentinel();

	RowHeight = 12;
	Width = WinWidth;

	AddColumn("Description", (WinWidth /2));
	AddColumn("Command", (WinWidth/2));
}

function PaintColumn(Canvas C, UWindowGridColumn Column, float MouseX, float MouseY)
{
	local int              iRowsVisible;
	local int              iCount;
	local int              iSkipped;
	local int              iYPos;
	local int              iTopMargin;
	local int              iBottomMargin;
	local stkbCommandList  cl;
	local float            fWidth;

	if(bShowHorizSB)
		iBottomMargin = LookAndFeel.Size_ScrollbarWidth;
	else
		iBottomMargin = 0;

	iTopMargin = LookAndFeel.ColumnHeadingHeight;

	if(List == None)
		return;
	iCount = List.Count();

	C.Font = Root.Fonts[F_Normal];
	iRowsVisible = int((WinHeight - (iTopMargin + iBottomMargin))/RowHeight);

	VertSB.SetRange(0, iCount+1, iRowsVisible);

    if(Column == self.LastColumn)
    {
        fWidth = WinWidth - column.WinLeft;
        if(HorizSB.bWindowVisible)
        {
	       if(VertSB.bWindowVisible)
               fWidth = fWidth - LookAndFeel.Size_ScrollbarWidth;
           Column.WinWidth = fWidth;
        }
        else
        {
           fWidth = WinWidth;
           if(VertSB.bWindowVisible)
                fWidth = fWidth - LookAndFeel.Size_ScrollbarWidth;

           if(column.WinLeft + column.WinWidth < fWidth)
           {
                fWidth = WinWidth - column.WinLeft;
                if(VertSB.bWindowVisible)
                    fWidth = fWidth - LookAndFeel.Size_ScrollbarWidth;
                Column.WinWidth = fWidth;
           }
        }
    }

	TopRow = VertSB.Pos;

	iSkipped = 0;

	iYPos = 1;

	cl = stkbCommandList(List.Next);
 	while((iYPos < RowHeight + WinHeight - RowHeight - (iTopMargin + iBottomMargin)) && (cl != None))
	{
		if(iSkipped >= VertSB.Pos)
		{
    		//Is it the selected Item? then we have to draw the HighLight
            if(cl == SelectedListItem)
	       		Column.DrawStretchedTexture( C, 0, iYPos-1 + iTopMargin, Column.WinWidth, RowHeight + 1, Texture'Highlight');

			switch(Column.ColumnNum)
			{
			case 0:
				Column.ClipText( C, 2, iYPos + iTopMargin, cl.Description);
				break;
			case 1:
				Column.ClipText( C, 2, iYPos + iTopMargin, cl.Command);
				break;
			}
			iYPos += RowHeight;
		}
		iSkipped ++;
		cl = stkbCommandList(cl.Next);
	}
}

function RightClickRow(int Row, float X, float Y)
{

//   MessageBox("Message", "RightClickRow not yet implemented.", MB_OK, MR_OK, MR_OK);

//	local UBrowserInfoMenu Menu;
//	local float MenuX, MenuY;
//	local UWindowWindow W;
//
//	W = GetParent(class'UBrowserInfoWindow');
//	if(W == None)
//		return;
//	Menu = UBrowserInfoWindow(W).Menu;
//
//	WindowToGlobal(X, Y, MenuX, MenuY);
//	Menu.WinLeft = MenuX;
//	Menu.WinTop = MenuY;
//
//	Menu.ShowWindow();
}


function DoubleClickRow(int Row)
{
    local UWindowDialogControl dc;

    //dc is needed to trigger the Notify
    UWindowDialogClientWindow(OwnerWindow).Notify(dc, DE_DoubleClick);
}


function SortColumn(UWindowGridColumn Column)
{
   //MessageBox("Message", "SortColumn not yet implemented.", MB_OK, MR_OK, MR_OK);
//	UBrowserInfoClientWindow(GetParent(class'UBrowserInfoClientWindow')).Server.PlayerList.SortByColumn(Column.ColumnNum);
}

function SelectRow(int Row)
{
	local stkbCommandList cl;

	cl = GetListItem(Row);

	if(cl != None)
		SelectedListItem = cl;
}

function Paint(Canvas C, float X, float Y)
{
	DrawStretchedTexture(C, 0, 0, WinWidth, WinHeight, Texture'BlackTexture');
	super.Paint(C, X, Y);
}


function stkbCommandList GetListItem(int Row)
{
	local int              i;
	local stkbCommandList  cl;

	if(List != None)
	{
		i = 0;
		cl = stkbCommandList(List.Next);
		while(cl != None)
		{
			if(i == Row)
				return cl;

			cl = stkbCommandList(cl.Next);
			i++;
		}
	}
	return None;
}


function int GetSelectedRow()
{
	local int              i;
	local stkbCommandList  cl;

	if(List != None)
	{
		i = 0;
		cl = stkbCommandList(List.Next);
        while(cl != None)
		{
			if(cl == SelectedListItem)
				return i;

			cl = stkbCommandList(cl.Next);
			i++;
		}
	}
	return -1;
}


defaultproperties
{
    bNoKeyboard=True
}

