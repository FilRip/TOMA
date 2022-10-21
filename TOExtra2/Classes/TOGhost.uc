class TOGhost extends mutator;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (Other.IsA('Pawn')) Other.Style=STY_Translucent;
    if (Other.IsA('s_Weapon')) Other.Style=STY_Translucent;
    if (Other.IsA('Carcass')) Other.Style=STY_Translucent;
    if (Other.IsA('s_Evidence')) Other.Style=STY_Translucent;
    if (Other.IsA('s_MoneyPickup')) Other.Style=STY_Translucent;
    return true;
}

defaultproperties
{
}

