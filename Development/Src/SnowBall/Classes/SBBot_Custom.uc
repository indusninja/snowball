class SBBot_Custom extends UTPawn;

// members for the custom mesh
var SkeletalMesh defaultMesh;
var MaterialInterface defaultMaterial0;
var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;
var AnimNodeSequence defaultAnimSeq;
var PhysicsAsset defaultPhysicsAsset;

simulated function name GetAmmoMaterial()
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
	return 'None';
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