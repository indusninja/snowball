/** The "Weapon" responsible for throwing snowballs and other combat actions */
class SBWeap_SnowBallThrow extends UTWeapon
	config(SnowBall);

/** The amount of ammo that the weapon starts with by default */
var config int AmmoDefault;
/** The maximum amount of ammo that the weapon can hold */
var config int AmmoMax;
/** The amount of ammo that a single shot costs */
var config int SnowballAmmoCost;

/** The maximum strength a snowball can have */
var config int MaxSnowballStrength;
/** This variable tracks the strength of a snowball */
var int SnowballStrength;

/** Cooldown time after a charged shot */
var float CoolDownTime;
/** Leftover time from the RefireCheckTimer interval that is added to the cooldown */
var float AdditionalCoolDownTime;

/** Sound to play while weapon is loading */
var SoundCue WeaponLoadSnd;

/** Component for visual charging effect */
var ParticleSystemComponent ChargingSystem;

/** The weapon animation to play when charging the weapon */
var name WeaponChargeAnim;
/** The arms animation to play when charging the weapon */
var name ArmsChargeAnim;

/**********************************************************************
 *  General functions
 **********************************************************************/

/** Initialize the weapon after it enters play */
simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    SkeletalMeshComponent(Mesh).AttachComponentToSocket(ChargingSystem,MuzzleFlashSocket);

	// Set inherited variables with config values
	AmmoCount = AmmoDefault;
	MaxAmmoCount = AmmoMax;
	ShotCost[0] = SnowballAmmoCost;
	ShotCost[1] = SnowballAmmoCost;
}

/** Spawn and fire a projectile */
simulated function Projectile ProjectileFire()
{
	local Projectile SpawnedProjectile;
	SpawnedProjectile = Super.ProjectileFire();

	if ( SBProj_SnowBall(SpawnedProjectile) != None )
	{
		`log("Snowball: Fired snowball with strength of "@SnowBallStrength);
		SBProj_SnowBall(SpawnedProjectile).InitSnow(self, SnowballStrength);
	}

	return SpawnedProjectile;
}

/**********************************************************************
 *  This state handles the charging of a snowball shot 
 **********************************************************************/

simulated state WeaponLoadAmmo
{
	/** Override BeginState to Initialize the charging */
	simulated function BeginState(Name PreviousStateName)
	{
    	local UTPawn POwner;

		SnowballStrength = 0;

		super.BeginState(PreviousStateName);

		POwner = UTPawn(Instigator);
		if (POwner != None)
		{
			POwner.SetWeaponAmbientSound(WeaponLoadSnd);
		}
		ChargingSystem.ActivateSystem();

		PlayWeaponAnimation( WeaponChargeAnim, MaxSnowballStrength*FireInterval[CurrentFireMode], false);
		PlayArmAnimation(ArmsChargeAnim, MaxSnowballStrength*FireInterval[CurrentFireMode],false);
	}

	/** Override EndState to clean up after firing the charged shot */
	simulated function EndState(Name NextStateName)
	{
		local UTPawn POwner;

		Cleartimer('RefireCheckTimer');

		SnowballStrength = 0;

		POwner = UTPawn(Instigator);
		if (POwner != None)
		{
			POwner.SetWeaponAmbientSound(None);
		}
		ChargingSystem.DeactivateSystem();

		Super.EndState(NextStateName);
	}

	/** Fire off the snowball at the end of this state */
	simulated function EndFire(byte FireModeNum)
	{
		Global.EndFire(FireModeNum);

		if (FireModeNum == CurrentFireMode)
		{
			// Fire the load
			ChargingSystem.DeactivateSystem();
			WeaponFireLoad();

			// Cool Down
			AdditionalCoolDownTime = GetTimerRate('RefireCheckTimer') - GetTimerCount('RefireCheckTimer');
			GotoState('WeaponCoolDown');
		}
	}

	/** Increase the power of the snowball by one */
	simulated function IncreaseSnowballStrength()
	{
		if (!IsFullyCharged())
		{
			// Add the snow
			SnowballStrength++;
		}
	}

	/** Check if the snowball has been charged to maximum */
	function bool IsFullyCharged()
	{
		return (SnowballStrength >= MaxSnowballStrength);
	}

	/** Fire the shot */
	simulated function WeaponFireLoad()
	{
		if (HasAmmo(CurrentFireMode)) {
			ConsumeAmmo(CurrentFireMode);
			ProjectileFire();
			PlayFiringSound();

			InvManager.OwnerEvent('FiredWeapon');
		}
	}

	/** Override RefireCheckTimer to increase snowball power each interval */
	simulated event RefireCheckTimer()
	{
		IncreaseSnowballStrength();
	}

	/** Override SendToFiringState since we don't want to start another fire mode while charging */
	simulated function SendToFiringState( byte FireModeNum )
	{
    	return;
	}

	/** Override this so weapon doesnt switch when ammo runs out while charging */
	simulated function WeaponEmpty();

	/** Put down weapon */
	simulated function bool TryPutdown()
	{
		bWeaponPutDown = true;
		return true;
	}

	/** Player is considered to be firing a weapon while charging */
	simulated function bool IsFiring()
	{
		return true;
	}

	/** Turn on view acceleration when snowball is fully charged */
	simulated function bool CanViewAccelerationWhenFiring()
	{
		return( IsFullyCharged() );
	}

Begin:
    TimeWeaponFiring(CurrentFireMode);
}

/**********************************************************************
 *  This state handles the cooldown after a charged shot
 **********************************************************************/

simulated state WeaponCoolDown
{
	/** Go back to active state since cooldown is done */
    simulated function WeaponCooled()
    {
        GotoState('Active');
    }

	/** Cleans up before leaving state */
    simulated function EndState(name NextStateName)
    {
        ClearFlashCount();
        ClearFlashLocation();

        ClearTimer('WeaponCooled');
        super.EndState(NextStateName);
    }

Begin:
    SetTimer(CoolDownTime + AdditionalCoolDownTime,false,'WeaponCooled');
}

/** Dummy function called if not in WeaponCooldown state */
simulated function WeaponCooled()
{
    `log("Snowball: Weapon Cooled outside WeaponCoolDown, is in"@GetStateName());
}

/**********************************************************************
 *  All defaultproperties defined below
 **********************************************************************/

defaultproperties
{
	/** Weapon properties */
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile

	WeaponProjectiles(0)=class'Snowball.SBProj_SnowBall'
	WeaponProjectiles(1)=class'Snowball.SBProj_SnowBall'

	InstantHitDamageTypes(0)=None
	InstantHitDamageTypes(1)=None

	ShouldFireOnRelease(0)=0
	ShouldFireOnRelease(1)=0

	FireInterval(0)=+0.5
	FireInterval(1)=+0.5

	ShotCost(0)=1
	ShotCost(1)=1

	FiringStatesArray(0)=WeaponLoadAmmo
	FiringStatesArray(1)=None

	CoolDownTime=1.00

	EquipTime=+0.45
	PutDownTime=+0.33
	WeaponRange=0

	AmmoCount=50
	MaxAmmoCount=100

	FireOffset=(X=20,Y=5)
	//PlayerViewOffset=(X=17,Y=10.0,Z=-8.0)

	/** 3D-models and animations */
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_1P'
		AnimSets(0)=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
		Rotation=(Yaw=-16384)
		FOV=60.0
	End Object

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_3P'
	End Object

	DrawScale3D=(X=1.0,Y=1.05,Z=1.0)

	ArmsAnimSet=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'

	WeaponFireAnim(0)=WeaponFire
	WeaponFireAnim(1)=WeaponAltFire
	ArmFireAnim(0)=WeaponFire
	ArmFireAnim(1)=WeaponAltFire

	WeaponEquipAnim=WeaponEquip
	ArmsEquipAnim=WeaponEquip

	WeaponPutDownAnim=WeaponPutDown
	ArmsPutDownAnim=WeaponPutDown

	WeaponChargeAnim=WeaponAltCharge
	ArmsChargeAnim=WeaponAltCharge

	/** Visual Effects */
	MuzzleFlashSocket=MF
	/*MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashColor=(R=200,G=120,B=255,A=255)*/
	MuzzleFlashPSCTemplate=SB_SpecialEffects.Effects.Snowball_Hit_Psystem
	MuzzleFlashAltPSCTemplate=SB_SpecialEffects.Effects.Snowball_Hit_Psystem
	MuzzleFlashColor=(R=255,G=255,B=255,A=255)
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'

	AttachmentClass=class'UTGameContent.UTAttachment_ShockRifle'

	Begin Object Class=ParticleSystemComponent Name=ChargePart
		//Template=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball'
		Template=ParticleSystem'SB_SpecialEffects.Effects.Snowball_Hit_Psystem'
		bAutoActivate=false
		DepthPriorityGroup=SDPG_Foreground
	End Object
	ChargingSystem=ChargePart
	Components.Add(ChargePart)

	/** Sounds */
	WeaponFireSnd[0]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
	WeaponLoadSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireCue'
	WeaponEquipSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_RaiseCue'
	WeaponPutDownSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_LowerCue'
	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Shock_Cue'

	/** Inventory properties */
	bCanThrow=false
	InventoryGroup=1
	GroupWeight=0.5

	/** AI Hints */
	bInstantHit=false
	bLeadTarget=true
	bConsiderProjectileAcceleration=true
	//bMeleeWeapon=false
	//bRecommendSplashDamage=false
	//bSplashJump=false
	//bSniping=false
	//AIRating=0.65
	//CurrentRating=0.65
	//MaxDesireability=0.65

	CrosshairImage=Texture2D'SB_GameHUD.HUD.SB_CrossHair'
}
