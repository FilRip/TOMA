class TOMAModelHandler extends TO_ModelHandler;

final static function byte TOMADressModel(Actor A, byte num)
{
	local	Pawn P;

	P = Pawn(A);

	// Mesh
	if ( P != None )
	{
		// Make sure model is valid
		if ( (num==255) || (default.ModelType[num] == MT_None) || (default.ModelType[num] == MT_Hostage) )
		{
			if ( P.PlayerReplicationInfo.Team < 2 )
				num = GetNextModel(num, P.PlayerReplicationInfo.Team);
			else if ( P.PlayerReplicationInfo.Team == 3 )
				num = GetRandomHostageModel(Pawn(A));
			else
				num = GetNextModel(num, Rand(2));
		}

		// Only assign mesh if player is visible!
		if ( !P.PlayerReplicationInfo.bWaitingPlayer && !P.PlayerReplicationInfo.bIsSpectator )
			A.Mesh = default.ModelMesh[num];
		/*
		// Assign model name
		if ( P.IsA('s_BotBase') )
			TO_BRI(P.PlayerReplicationInfo).ModelName ~= Default.ModelName[i];

		if ( P.IsA('s_Player') )
			TO_PRI(P.PlayerReplicationInfo).ModelName ~= Default.ModelName[i];
		*/
		P.SelectionMesh = Default.ModelName[num];
	}
	else
	{
		// Make sure model is valid
		if ( (num==255) || (default.ModelType[num] == MT_None) )
			num = GetNextModel(num, Rand(2));

		A.Mesh = default.ModelMesh[num];
	}

	// Skins
	A.MultiSkins[0] = Texture(DynamicLoadObject(default.Skin0[num], class'Texture'));
	A.MultiSkins[1] = Texture(DynamicLoadObject(default.Skin1[num], class'Texture'));
	A.MultiSkins[2] = Texture(DynamicLoadObject(default.Skin2[num], class'Texture'));
	A.MultiSkins[3] = Texture(DynamicLoadObject(default.Skin3[num], class'Texture'));
	A.MultiSkins[4] = Texture(DynamicLoadObject(default.Skin4[num], class'Texture'));

	if ( default.Skin5[num] != "" )
		A.MultiSkins[5] = Texture(DynamicLoadObject(default.Skin5[num], class'Texture'));
	else
		A.MultiSkins[5] = None;

	if ( default.Skin6[num] != "" )
		A.MultiSkins[6] = Texture(DynamicLoadObject(default.Skin6[num], class'Texture'));
	else
		A.MultiSkins[6] = None;

	if ( default.Skin7[num] != "" )
		A.MultiSkins[7] = Texture(DynamicLoadObject(default.Skin7[num], class'Texture'));
	else
		A.MultiSkins[7] = None;

	// Voice
	if ( P != None )
	{
		if ( default.ModelType[num] == MT_Terrorist ) // Terrorist
		{
			if ( default.bFemale[num] > 0 )
				P.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject("TODatas.VoiceFT1", class'Class'));
			else
				P.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject("TODatas.VoiceT1", class'Class'));
		}
		else // Special Forces
		{
			if ( default.bFemale[num] > 0 )
				P.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject("TODatas.VoiceFSF1", class'Class'));
			else
				P.PlayerReplicationInfo.VoiceType = class<VoicePack>(DynamicLoadObject("TODatas.VoiceSF1", class'Class'));
		}

		//log("TO_ModelHandler::DressModel - Setting voice to:"@P.PlayerReplicationInfo.PlayerName@P.PlayerReplicationInfo.VoiceType);
	}

	return num;
}

defaultproperties
{
}

