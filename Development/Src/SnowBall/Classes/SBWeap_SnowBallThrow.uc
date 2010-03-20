/**
 * Our stuff.
 */

class SBWeap_SnowBallThrow extends UTWeapon;

/** maximum strength a snowball can have */
var int MaxSnowballStrength;
var int SnowballStrength;

var SoundCue WeaponLoadSnd;

var float AdditionalCoolDownTime;
var float CoolDownTime;

/** Array of all the animations for the various primary fires*/
var array<name> PrimaryFireAnims; // special case for Bio; if this needs to be promoted perhaps an array of arrays?

/** arm animations corresponding to above*/
var array<name> PrimaryArmAnims;

/** the primary fire animation currently playing */
var int CurrentFireAnim;

var ParticleSystemComponent ChargingSystem;
var name WeaponChargeAnim;
var name ArmsChargeAnim;

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    SkeletalMeshComponent(Mesh).AttachComponentToSocket(ChargingSystem,MuzzleFlashSocket);
}

/*********************************************************************************************
 * Hud/Crosshairs
 *********************************************************************************************/

simulated event float GetPowerPerc()
{
    return 0.0;
}

/**
 * GetAdjustedAim begins a chain of function class that allows the weapon, the pawn and the controller to make
 * on the fly adjustments to where this weapon is pointing.
 */
simulated function Rotator GetAdjustedAim( vector StartFireLoc )
{
    local rotator R;

    // Start the chain, see Pawn.GetAdjustedAimFor()
    if( Instigator != None )
    {
        R = Instigator.GetAdjustedAimFor( Self, StartFireLoc );

        if ( PlayerController(Instigator.Controller) != None )
        {
            R.Pitch = R.Pitch & 65535;
            if ( R.Pitch < 16384 )
            {
                R.Pitch += (16384 - R.Pitch)/16;
            }
            else if ( R.Pitch > 49152 )
            {
                R.Pitch += 1024;
            }
        }
    }

    return R;
}

/**
 * Take the projectile spawned and if it's the proper type, adjust it's strength and speed
 */
simulated function Projectile ProjectileFire()
{
    local Projectile SpawnedProjectile;

    SpawnedProjectile = super.ProjectileFire();
    if ( SBProj_SnowBall(SpawnedProjectile) != None )
    {
        SBProj_SnowBall(SpawnedProjectile).InitSnow(self, SnowballStrength);
    }

    return SpawnedProjectile;
}

/**
 * Tells the weapon to play a firing sound (uses CurrentFireMode)
 */
simulated function PlayFiringSound()
{
    if (CurrentFireMode<WeaponFireSnd.Length)
    {
        // play weapon fire sound
        if ( WeaponFireSnd[CurrentFireMode] != None )
        {
            MakeNoise(1.0);
            if(CurrentFireMode == 1 && GetPowerPerc() > 0.75)
            {
                WeaponPlaySound( WeaponFireSnd[2] );
            }
            else
            {
                WeaponPlaySound( WeaponFireSnd[CurrentFireMode] );
            }
        }
    }
}

/*********************************************************************************************
 * State WeaponLoadAmmo
 * In this state, ammo will continue to load up until MAXLOADCOUNT has been reached.  It's
 * similar to the firing state
 *********************************************************************************************/

simulated state WeaponLoadAmmo
{
    simulated function WeaponEmpty();

    simulated event float GetPowerPerc()
    {
        local float p;
        p = float(SnowballStrength) / float(MaxSnowballStrength);
        p = FClamp(p,0.0,1.0);

        return p;
    }

    simulated function bool TryPutdown()
    {
        bWeaponPutDown = true;
        return true;
    }

    /**
     * Adds a rocket to the count and uses up some ammo.  In Addition, it plays
     * a sound so that other pawns in the world can here it.
     */
    simulated function IncreaseSnowballStrength()
    {
        if (SnowballStrength < MaxSnowballStrength && HasAmmo(CurrentFireMode))
        {
            // Add the glob
            SnowballStrength++;
            ConsumeAmmo(CurrentFireMode);
        }
    }

    function bool IsFullyCharged()
    {
        return (SnowballStrength >= MaxSnowballStrength);
    }

    /**
     * Fire off a shot w/ effects
     */
    simulated function WeaponFireLoad()
    {
        ProjectileFire();
        PlayFiringSound();
        InvManager.OwnerEvent('FiredWeapon');
    }

    /**
     * This is the timer event for each shot
     */
    simulated event RefireCheckTimer()
    {
        IncreaseSnowballStrength();
    }

    simulated function SendToFiringState( byte FireModeNum )
    {
        return;
    }


    /**
     * We need to override EndFire so that we can correctly fire off the
     * current load if we have any.
     */
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

    /**
     * Initialize the loadup
     */
    simulated function BeginState(Name PreviousStateName)
    {
        local UTPawn POwner;
        local UTAttachment_ShockRifle ASnow;

        SnowballStrength = 0;

        super.BeginState(PreviousStateName);

        POwner = UTPawn(Instigator);
        if (POwner != None)
        {
            POwner.SetWeaponAmbientSound(WeaponLoadSnd);
            ASnow = UTAttachment_ShockRifle(POwner.CurrentWeaponAttachment);
            if(ASnow != none)
            {
                //ASnow.StartCharging();
            }
        }
        ChargingSystem.ActivateSystem();
        PlayWeaponAnimation( WeaponChargeAnim, MaxSnowballStrength*FireInterval[1], false);
        PlayArmAnimation(ArmsChargeAnim, MaxSnowballStrength*FireInterval[1],false);
    }

    /**
     * Insure that the SnowStrength is 1 when we leave this state
     */
    simulated function EndState(Name NextStateName)
    {
        local UTPawn POwner;

        Cleartimer('RefireCheckTimer');

        SnowballStrength = 1;

        POwner = UTPawn(Instigator);
        if (POwner != None)
        {
            POwner.SetWeaponAmbientSound(None);
            //POwner.SetFiringMode(0); // return to base fire mode for network anims
        }
        ChargingSystem.DeactivateSystem();

        Super.EndState(NextStateName);
    }

    simulated function bool IsFiring()
    {
        return true;
    }

    /**
     * This determines whether or not the Weapon can have ViewAcceleration when Firing.
     *
     * When you are FULLY charged up and running around the level looking for someone to Glob,
     * you need to be able to view accelerate
     **/
    simulated function bool CanViewAccelerationWhenFiring()
    {
        return( SnowballStrength == MaxSnowballStrength );
    };


Begin:
    IncreaseSnowballStrength();
    TimeWeaponFiring(CurrentFireMode);

}

simulated state WeaponCoolDown
{
    simulated function WeaponCooled()
    {
        GotoState('Active');
    }

    simulated function EndState(name NextStateName)
    {
        ClearFlashCount();
        ClearFlashLocation();

        ClearTimer('WeaponCooled');
        super.EndState(NextStateName);
    }

begin:
    SetTimer(CoolDownTime + AdditionalCoolDownTime,false,'WeaponCooled');
}

simulated function WeaponCooled()
{
    `log("Snowball: Weapon Cooled outside WeaponCoolDown, is in"@GetStateName());
}

// AI Interface
function float GetAIRating()
{
    local UTBot B;
    local float EnemyDist;
    local vector EnemyDir;

    B = UTBot(Instigator.Controller);
    if ( (B == None) || (B.Enemy == None) )
        return AIRating;

    // if retreating, favor this weapon
    EnemyDir = B.Enemy.Location - Instigator.Location;
    EnemyDist = VSize(EnemyDir);
    if ( EnemyDist > 1500 )
        return 0.1;
    if ( B.IsRetreating() )
        return (AIRating + 0.4);
    if ( (B.Enemy.Weapon != None) && B.Enemy.Weapon.bMeleeWeapon )
        return (AIRating + 0.35);
    if ( -1 * EnemyDir.Z > EnemyDist )
        return AIRating + 0.1;
    if ( EnemyDist > 1000 )
        return 0.35;
    return AIRating;
}

/* BestMode()
choose between regular or alt-fire
*/
function byte BestMode()
{
    if ( FRand() < 0.8 )
        return 0;
    return 1;
}

function float SuggestAttackStyle()
{
    local UTBot B;
    local float EnemyDist;

    B = UTBot(Instigator.Controller);
    if ( (B == None) || (B.Enemy == None) )
        return 0.4;

    EnemyDist = VSize(B.Enemy.Location - Instigator.Location);
    if ( EnemyDist > 1500 )
        return 1.0;
    if ( EnemyDist > 1000 )
        return 0.4;
    return -0.4;
}

function float SuggestDefenseStyle()
{
    local UTBot B;

    B = UTBot(Instigator.Controller);
    if ( (B == None) || (B.Enemy == None) )
        return 0;

    if ( VSize(B.Enemy.Location - Instigator.Location) < 1600 )
        return -0.6;
    return 0;
}

/** Set default properties here */
defaultproperties
{
	/** Firing mode properties */
	WeaponFireTypes(0)=EWFT_Projectile
	WeaponFireTypes(1)=EWFT_Projectile

	WeaponProjectiles(0)=class'Snowball.SBProj_SnowBall'
	WeaponProjectiles(1)=class'Snowball.SBProj_SnowBall'

	FireInterval(0)=+1.5
	FireInterval(1)=+0.35

	InstantHitDamageTypes(0)=None
	InstantHitDamageTypes(1)=None

	ShouldFireOnRelease(0)=0
    ShouldFireOnRelease(1)=0

	ShotCost(0)=1
	ShotCost(1)=1

	Spread(0)=0.0

	SnowballStrength=1
    MaxSnowballStrength=10

	//FiringStatesArray(0)=WeaponLoadAmmo
	FiringStatesArray(1)=WeaponLoadAmmo

	/** Firing, timing and states */
	//EquipTime=+0.45
	//PutDownTime=+0.33
	//FireOffset=(X=0.0,Y=0.0,Z=0.0)
	//WeaponRange=22000
	//PlayerViewOffset=(X=17,Y=10.0,Z=-8.0)

	DrawScale3D=(X=1.0,Y=1.05,Z=1.0)

	/** Visuals, Sounds and Effects */
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_1P'
		AnimSets(0)=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
		Animations=MeshSequenceA
		Rotation=(Yaw=-16384)
		FOV=60.0
	End Object

	AttachmentClass=class'UTGameContent.UTAttachment_ShockRifle'

	Begin Object Name=PickupMesh
		SkeletalMesh=SkeletalMesh'WP_ShockRifle.Mesh.SK_WP_ShockRifle_3P'
	End Object

	WeaponFireSnd[0]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
	WeaponFireSnd[1]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireCue'
	WeaponFireSnd[2]=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_AltFireCue'
	WeaponLoadSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_FireCue'
	WeaponEquipSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_RaiseCue'
	WeaponPutDownSnd=SoundCue'A_Weapon_ShockRifle.Cue.A_Weapon_SR_LowerCue'
	PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Shock_Cue'

	MuzzleFlashSocket=MF
	MuzzleFlashPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashAltPSCTemplate=WP_ShockRifle.Particles.P_ShockRifle_MF_Alt
	MuzzleFlashColor=(R=200,G=120,B=255,A=255)
	MuzzleFlashDuration=0.33
	MuzzleFlashLightClass=class'UTGame.UTShockMuzzleFlashLight'

	WeaponFireAnim(0)=WeaponFire
    WeaponFireAnim(1)=WeaponAltFire
    WeaponPutDownAnim=WeaponPutDown
    WeaponEquipAnim=WeaponEquip
    WeaponChargeAnim=WeaponAltCharge

    CoolDownTime=0.33;
    ArmsAnimSet=AnimSet'WP_ShockRifle.Anim.K_WP_ShockRifle_1P_Base'
    ArmFireAnim(0)=WeaponFire
    ArmFireAnim(1)=WeaponAltFire
    ArmsPutDownAnim=WeaponPutDown
    ArmsEquipAnim=WeaponEquip
    ArmsChargeAnim=WeaponAltCharge


    PrimaryFireAnims(0)=WeaponFire
    PrimaryFireAnims(1)=WeaponFire
    PrimaryFireAnims(2)=WeaponFire
    PrimaryArmAnims(0)=WeaponFire
    PrimaryArmAnims(1)=WeaponFire
    PrimaryArmAnims(2)=WeaponFire
    CurrentFireAnim=0;

	Begin Object Class=ParticleSystemComponent Name=ChargePart
        Template=ParticleSystem'WP_ShockRifle.Particles.P_WP_ShockRifle_Ball'
        bAutoActivate=false
        DepthPriorityGroup=SDPG_Foreground
    End Object
    ChargingSystem=ChargePart
    Components.Add(ChargePart)


	/** Inventory properties */
	bCanThrow=false

	AmmoCount=50
	LockerAmmoCount=50
	MaxAmmoCount=100

	InventoryGroup=4
	GroupWeight=0.5

	LockerRotation=(Pitch=32768,Roll=16384)

	/** UI Visuals */
	IconCoordinates=(U=728,V=382,UL=162,VL=45)
	IconX=400
	IconY=129
	IconWidth=22
	IconHeight=48

	CrosshairImage=Texture2D'UI_HUD.HUD.UTCrossHairs'
	CrossHairCoordinates=(U=256,V=0,UL=64,VL=64)
	CrosshairScaling=1.0

	WeaponColor=(R=160,G=0,B=255,A=255)

	/** AI Hints */
	bInstantHit=false
	bLeadTarget=true
	bConsiderProjectileAcceleration=true
	//bMeleeWeapon=false
	//bRecommendSplashDamage=false
	//bSplashJump=false
	//bSniping=false
	AIRating=0.65
	CurrentRating=0.65
	MaxDesireability=0.65
}
