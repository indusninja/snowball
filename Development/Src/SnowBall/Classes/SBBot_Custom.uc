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

var repnotify Vector Destination;
var repnotify Rotator WallRotation;

var repnotify SBActor_SnowWall Wall;
var repnotify bool bIsContructing;

var config int WallConstructionCost;
var config int WallInitialDepth;

replication
{
	//If I'm the server I replicate the location and rotation to the clients
	if (Role==ROLE_Authority && bNetDirty) 
		Destination,WallRotation,bIsContructing,Wall;

	//if(Role<ROLE_Authority)
	//	bIsContructing;

}


unreliable server /*simulated*/ function StopConstructing()
{
	//if(bIsContructing)
	bIsContructing=false;
	
	if(Wall!=none)
		Wall=none;
	
	//`log("bIscontructing: "@bIsContructing);

}

unreliable server /*simulated*/ function StartConstructing()
{
	//if(!bIsContructing)
		bIsContructing=true;
	//`log("bIscontructing: "@bIsContructing);
	//ServerCreateWall();
}

/*This event is triggered everytime the variables labeled with reptonify are modified. Then we call the 
 *simulated function SpawnWall on all the clients that recieved the replicated version of WallRotation*/
simulated event ReplicatedEvent(name VarName)
{
	super.ReplicatedEvent(VarName);

	if(VarName=='bIsContructing')
	{
		//StopConstructing();
		//StartConstructing();
		if(bIsContructing)
		`log("Iscontructing replicated event "@bIsContructing);
		else
			Wall=none;
		//if(!bIsContructing)
		//Wall=none;
	}

	if (VarName=='Destination'||VarName=='Rotation'){
		`log("Replicating Wall...");
		ClientMessage("Spawning client wall");
		if(bIsContructing)
		/*Wall=*/SpawnWall(bIsContructing);
		//Wall=GrowingWall();
	}
}

unreliable server /*simulated*/ function  ServerCreateWall(bool constructing)
{	
	local vector loc;
	local Rotator rot;

	//bIsContructing=constructing;
	//`log("Construction: "@bIsContructing);
	if(bIsContructing==true)
	{
		if(Wall==none)
		{
			if(Weapon.HasAmmo(0,WallConstructionCost))
			{
				loc = Location + normal(vector(Rotation))* 200; //Placing the Wall further
				
				//Rotation based on Tait-Bryan angles... nice...
				rot.Pitch=Rotation.Pitch ;
				rot.Roll=Rotation.Roll;
				rot.Yaw=Rotation.Yaw + (-90.0f * DegToRad) * RadToUnrRot;
				
				loc.Z=Location.Z - WallInitialDepth;//Placing Wall in the ground

				//Updating replicated variables data
				WallRotation=rot;
				Destination=loc;

				//Calling the simulated function that it's goin to spawn both in client and server the wall
				/*Wall=*/SpawnWall(constructing);
				
				Weapon.AddAmmo(-1*WallConstructionCost);
			}
		}else
			{
			//`log("Client grows the wall??");

				////Updating replicated variables data
				WallRotation=Wall.Rotation;
				Destination.Z= Wall.Location.Z + 6;

				if(Destination.Z < self.Location.Z - 50)
					Wall.Destroy();

				//Wall=none;
				///*Wall=*/GrowingWall();
				SpawnWall(constructing);
			}
	}
	//else
	//	Wall=none;
}

/*Function simulated on the server so it knows where to Spawn the wall*/
simulated function /*SBActor_SnowWall*/ SpawnWall(bool construct)
{
	if((Destination.Z < self.Location.Z - 50) && bIsContructing)
	{
		Wall.Destroy();
		if((Destination.X!=0 || Destination.Y!=0 || Destination.Z!=0)&&
			(WallRotation!=Rotation))
				Wall=WorldInfo.Spawn(class'SnowBall.SBActor_SnowWall',Owner,,Destination,WallRotation);
	}
	else
	{
		Wall=none;
		StopConstructing();
		//`log("Deleting");
	}		
	//Wall=MyWall;
	//return MyWall;
}


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


reliable server function CallingBuildingConstructor()
{
	if(MaterialBelowFeet == GatheringMaterial && !bIsMoving)
		ServerCreateWall(bIsContructing);

}


simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SetTimer(SnowGatherRate,true,'SnowGatheringTimer');

	//Timer that will make the wall grow
	SetTimer(0.15,true,'CallingBuildingConstructor');

	//SpawnDefaultController();
}

defaultproperties
{
	bIsContructing=false;
	defaultMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
	defaultAnimTree=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
	defaultAnimSet(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	defaultPhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'

	Begin Object Name=WPawnSkeletalMeshComponent
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
	End Object
}