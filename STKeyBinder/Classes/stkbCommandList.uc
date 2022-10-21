//-----------------------------------------------------------
//    CommandList
//-----------------------------------------------------------
//
// Tactical Ops - SuperTeam KeyBinder -
//
// Source code rights:
// Copyright (C) 2002 Andrew Jakobs
//-----------------------------------------------------------
class stkbCommandList extends UWindowList;

var string  Description;
var string  Command;


//------------------------------------------
//       Add
//------------------------------------------
function stkbCommandList Add(string sDescription, string sCommand)
{
    local stkbCommandList   cl;

    cl = stkbCommandList(Append(class'stkbCommandList'));
    cl.Description = sDescription;
    cl.Command = sCommand;

    return cl;
}

