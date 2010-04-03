/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class SBDmgType_SnowBall extends UTDamageType
	abstract;

defaultproperties
{
	DamageWeaponClass=class'SBWeap_SnowBallThrow'

	DamageBodyMatColor=(R=40,B=50)
	DamageOverlayTime=0.3
	DeathOverlayTime=0.6
	VehicleDamageScaling=0.8
	VehicleMomentumScaling=2.75
	KDamageImpulse=1500.0
}
