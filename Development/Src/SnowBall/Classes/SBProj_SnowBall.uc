/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SBProj_SnowBall extends UTProjectile
	config(SnowBall);

var repnotify int   SnowballStrength;
var() float         SnowballSpeed;
var config float	SpeedIncrement;
var config float  	SpeedBase;
var config float	DamageIncrement;
var config float    DamageBase;
var config float    TossForce;
var config float    ImpactForce;
var MeshComponent   SnowBallMesh;

replication
{
    if (bNetInitial)
        SnowballStrength;
}

/** What to do once the snowball is created */
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	// Set config values
	Speed = SpeedBase;
	Damage = DamageBase;
	TossZ = TossForce;
	MomentumTransfer = ImpactForce;
}

/** Replicate variables */
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

/** Initialise the snowball based on how much it was charged */
function InitSnow(SBWeap_SnowBallThrow FiringWeapon, int InSnowballStrength)
{
	local float NewSpeed;

	// adjust snowball parameters
    InSnowballStrength = Max(InSnowballStrength, 0);
	NewSpeed = Speed + InSnowballStrength * SpeedBase * SpeedIncrement;
    Velocity = Normal(Velocity) * NewSpeed;
    Damage = Damage + InSnowballStrength * Damage * DamageIncrement;

	//`log("Snowball: Speed is "@NewSpeed);
	//`log("Snowball: Damage is "@Damage);

    SetSnowballStrength(InSnowballStrength);
}

/** CreateProjectileLight() called from TickSpecial() once if Instigator is local player
always create shock light, even at low frame rates (since critical for timing combos)
*/
simulated event CreateProjectileLight()
{
	ProjectileLight = new(Outer) ProjectileLightClass;
	AttachComponent(ProjectileLight);
}

/** Sets the strength of this snowball actor */
simulated function SetSnowballStrength( int NewStrength )
{
    SnowballStrength = Max(NewStrength,0);
}

/** What do when hitting another object */
simulated function ProcessTouch(Actor Other, vector HitLocation, vector HitNormal)
{
	local SBProj_SnowBall SnowProj;

	Super.ProcessTouch(Other, HitLocation, HitNormal);

	// when snowballs collide, make sure they both blow up
	SnowProj = SBProj_SnowBall(Other);
	if (SnowProj != None)
	{
		SnowProj.Explode(HitLocation, -HitNormal);
	}
}

defaultproperties
{
	//ProjFlightTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball'
	//ProjExplosionTemplate=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball_Impact'
	ProjFlightTemplate=ParticleSystem'SB_SpecialEffects.Effects.Snowball_Hit_Psystem'
	ProjExplosionTemplate=ParticleSystem'SB_SpecialEffects.Effects.Snowball_Hit_Psystem'
	Speed=1000
	MaxSpeed=7000
	MaxEffectDistance=7000.0
	bRotationFollowsVelocity=false
	bCheckProjectileLight=true
	ProjectileLightClass=class'UTGame.UTShockBallLight'
	TossZ=+245.0
	Physics=PHYS_Falling

	SnowballStrength=0
	Damage=30
	DamageRadius=0
	MomentumTransfer=10000

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

	Begin Object Class=StaticMeshComponent name=ProjectileMesh
		StaticMesh=StaticMesh'SB_Snowball.Mesh.Snowball04'
		CullDistance=20000
		Scale=2.0
		CollideActors=false
		CastShadow=false
		bAcceptsLights=true
		bForceDirectLightMap=true
		LightingChannels=(BSP=true,Dynamic=false,Static=true,CompositeDynamic=false)
		BlockRigidBody=false
		BlockActors=false
		bUseAsOccluder=false
	End Object
	Components.Add(ProjectileMesh)
	SnowBallMesh=ProjectileMesh

	bNetTemporary=false
	AmbientSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireTravelCue'
	ExplosionSound=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireImpactCue'
}
