/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 * This object is used as a store for all character profile information.
 */
class SBCharInfo extends UTCharInfo;

defaultproperties
{
	Families.Remove(class'UTFamilyInfo_Liandri_Male')
	Families.Add(class'SBFamilyInfo')
}