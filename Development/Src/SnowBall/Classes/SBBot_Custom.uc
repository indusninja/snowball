class SBBot_Custom extends UTPawn
	config(SnowBall);

// members for the custom mesh
var SkeletalMesh defaultMesh;
var MaterialInterface defaultMaterial0;
var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;
var AnimNodeSequence defaultAnimSeq;
var PhysicsAsset defaultPhysicsAsset;

var name MaterialBelowFeet;

var config name GatheringMaterial;
var config name SlowerSpeedMaterial;
var config name SlideSpeedMaterial;

var config float SnowGatherRate;
var config float DefaultGroundSpeed;
var config float SlowerSpeedPercent;
var config float SlideSpeedPercent;

/*Function for picking up snow. It has a timer associated declared in the PostBeginPlay function, so the 
 * time the snow is picked up can be changed easily*/
simulated function SnowGatheringTimer()
{
	if(MaterialBelowFeet == GatheringMaterial)
	{

		// Only pick up snow if not firing a weapon and crouched
		if( !IsFiring() && bIsCrouched)
		{
			// Also restrict to when not moving
			if( (Velocity.X == 0.0) && (Velocity.Y == 0.0) && (Velocity.Z == 0.0) )
			{
				UTInventoryManager(InvManager).AddAmmoToWeapon(1,class'SnowBall.SBWeap_SnowBallThrow');
			}
		}
	}
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	MaterialBelowFeet = GetMaterialBelowFeet();

	if (MaterialBelowFeet == SlowerSpeedMaterial)
		GroundSpeed = DefaultGroundSpeed * SlowerSpeedPercent;
	else
		GroundSpeed = DefaultGroundSpeed;
}

simulated function name GetMaterialBelowFeet()
{
	local vector HitLocation, HitNormal;
	local TraceHitInfo HitInfo;
	local UTPhysicalMaterialProperty PhysicalProperty;
	local actor HitActor;
	local float TraceDist;
	local Terrain TerrainObject;
	local Material MaterialFound;

	TraceDist = 1.5 * GetCollisionHeight();

	HitActor = Trace(HitLocation, HitNormal, Location - TraceDist*vect(0,0,1), Location, false,, HitInfo, TRACEFLAG_PhysicsVolumes);
	if ( WaterVolume(HitActor) != None )
	{
		return (Location.Z - HitLocation.Z < 0.33*TraceDist) ? 'Water' : 'ShallowWater';
	}
	if ( Terrain(HitActor) != None )
	{
		//`log("Standing on Terrain!");
		TerrainObject = Terrain(HitActor);
		MaterialFound = Material(TerrainObject.Layers[0].Setup.Materials[0].Material.Material);
		PhysicalProperty = UTPhysicalMaterialProperty(MaterialFound.PhysMaterial.GetPhysicalMaterialProperty(class'UTPhysicalMaterialProperty'));
		//`log("Terrain Physical Material: "$TerrainObject.TerrainPhysMaterialOverride);
		if (PhysicalProperty != None)
		{
			return PhysicalProperty.MaterialType;
		}
	}
	if (HitInfo.PhysMaterial != None)
	{
		PhysicalProperty = UTPhysicalMaterialProperty(HitInfo.PhysMaterial.GetPhysicalMaterialProperty(class'UTPhysicalMaterialProperty'));
		if (PhysicalProperty != None)
		{
			return PhysicalProperty.MaterialType;
		}
	}
	return '';
}

simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
	Mesh.SetSkeletalMesh(defaultMesh);
	Mesh.SetMaterial(0,defaultMaterial0);
	Mesh.SetPhysicsAsset(defaultPhysicsAsset);
	Mesh.AnimSets=defaultAnimSet;
	Mesh.SetAnimTreeTemplate(defaultAnimTree);
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(SnowGatherRate,true,'SnowGatheringTimer');
	//SpawnDefaultController();
}

defaultproperties
{
	defaultMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
	defaultAnimTree=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
	defaultAnimSet(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	defaultPhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'

	Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
	End Object
}