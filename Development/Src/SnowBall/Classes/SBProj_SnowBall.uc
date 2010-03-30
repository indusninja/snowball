/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SBProj_SnowBall extends UTProjectile;

//var() int           MaxRestingGlobStrength;
var repnotify int   SnowballStrength;
var() float         SnowballSpeed;

//var StaticMeshComponent SnowLandedMesh;
//var ParticleSystemComponent HitWallEffect;

//var class<UTDamageType> GibDamageType;

replication
{
    if (bNetInitial)
        SnowballStrength;
}

simulated event ReplicatedEvent(name VarName)
{
    if (VarName == 'SnowballStrength')
    {
        SetSnowballStrength(SnowballStrength);
    }
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}

function InitSnow(SBWeap_SnowBallThrow FiringWeapon, int InSnowballStrength)
{
    // adjust speed
    InSnowballStrength = Max(InSnowballStrength, 1);
    Velocity = Normal(Velocity) * (Speed + (InSnowballStrength-1) * Speed * SpeedIncrement);
    Damage = Damage + Damage * DamageIncrement * (InSnowballStrength-1);

    SetSnowballStrength(InSnowballStrength);
    //RestTime = Default.RestTime + 0.6*InSnowballStrength;
}

/** CreateProjectileLight() called from TickSpecial() once if Instigator is local player
always create shock light, even at low frame rates (since critical for timing combos)
*/
simulated event CreateProjectileLight()
{
	ProjectileLight = new(Outer) ProjectileLightClass;
	AttachComponent(ProjectileLight);
}

/**
 * Sets the strength of this bio goo actor
 */
simulated function SetSnowballStrength( int NewStrength )
{
    SnowballStrength = Max(NewStrength,1);
    SetDrawScale(Sqrt((SnowballStrength == 1) ? 1 : (SnowballStrength + 1)) * default.DrawScale);
    if (SnowballStrength > 4)
    {
        SetCollisionSize(CylinderComponent.CollisionRadius, CylinderComponent.CollisionHeight * 2.0);
    }

    // set different damagetype for charged shots
    /**if (SnowballStrength > 1)
    {
        MyDamageType = default.MyDamageType;
    }
    else
    {*/
        //MyDamageType = class'SBProj_Snowball'.default.MyDamageType;
		MyDamageType = default.MyDamageType;
    //}
}

simulated function ProcessTouch(Actor Other, vector HitLocation, vector HitNormal)
{
	local SBProj_SnowBall SnowProj;

	Super.ProcessTouch(Other, HitLocation, HitNormal);

	// when shock projectiles collide, make sure they both blow up
	SnowProj = SBProj_SnowBall(Other);
	if (SnowProj != None)
	{
		SnowProj.Explode(HitLocation, -HitNormal);
	}
}

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball'
	ProjExplosionTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
	Speed=1000
        SpeedIncrement=0.4
	MaxSpeed=7000
	MaxEffectDistance=7000.0
	bCheckProjectileLight=true
	ProjectileLightClass=class'UTGame.UTShockBallLight'
	TossZ=+245.0
	Physics=PHYS_Falling

	Damage=30
        DamageIncrement=0.1
	DamageRadius=0
	MomentumTransfer=30000

	MyDamageType=class'SBDmgType_SnowBall'
	LifeSpan=0.0

	bCollideWorld=true
	bProjTarget=True

	CheckRadius=40.0
	bCollideComplex=false

	Begin Object Name=CollisionCylinder
		CollisionRadius=16
		CollisionHeight=16
		AlwaysLoadOnClient=True
		AlwaysLoadOnServer=True
		BlockNonZeroExtent=true
		BlockZeroExtent=true
		BlockActors=true
		CollideActors=true
	End Object

	bNetTemporary=false
	AmbientSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireTravelCue'
	ExplosionSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue'
}
