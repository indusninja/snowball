class SBPlayerController_ThirdPerson extends UTPlayerController
	config(SnowBall);

// members for the custom mesh
var SkeletalMesh defaultMesh;
var MaterialInterface defaultMaterial0;
var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;
var AnimNodeSequence defaultAnimSeq;
var PhysicsAsset defaultPhysicsAsset;

var config int WallConstructionCost;

/*Function responsible of placing a Wall when the key X is pressed*/
exec function ConstructWall()
{
	local vector loc;
	local Rotator rot;

	if(Pawn.Weapon.HasAmmo(0,WallConstructionCost))
	{
		loc = Pawn.Location + normal(vector(Pawn.Rotation))*200; 
		//loc.Y-=90;
		//loc.X-=90;
		//loc.X = Pawn.Location + normal(vector(Pawn.Rotation)).X*200; 
		//loc.Y=Pawn.Location.Y - normal(vector(Pawn.Rotation)).Y*200;
		
		//Rotation based on Tait-Bryan angles... nice...
		rot.Pitch=Pawn.Rotation.Pitch ;
		rot.Roll=Pawn.Rotation.Roll;
		rot.Yaw=Pawn.Rotation.Yaw + (90.0f * DegToRad) * RadToUnrRot;
		
		//loc.Z-=15;
		loc.Z=Pawn.Location.Z-35;//Placing Wall in the ground
		
		Pawn.Spawn(class'SnowBall.SBActor_SnowWall',,,loc,rot);
		Pawn.Weapon.AddAmmo(-1*WallConstructionCost);
	}
}
simulated function PostBeginPlay() 
{
	super.PostBeginPlay();
	//SetCameraMode('ThirdPerson');
	//resetMesh();
}

// Sets the Pawns Mesh to the resources speced in the DefaultProperties
public function resetMesh()
{
	local PostProcessChain coolShade;

	Pawn.Mesh.SetSkeletalMesh(defaultMesh);
	Pawn.Mesh.SetMaterial(0,defaultMaterial0);
	Pawn.Mesh.SetPhysicsAsset(defaultPhysicsAsset );
	Pawn.Mesh.AnimSets=defaultAnimSet;
	Pawn.Mesh.SetAnimTreeTemplate(defaultAnimTree);

	if (LocalPlayer(Player)!=none)
	{
		coolShade = PostProcessChain'SB_PostProcessing.PostProcess.DunDefScenePostProcess';
		LocalPlayer(Player).InsertPostProcessingChain(coolShade,-1,false);
	}
}

// Called at RestartPlayer by GameType
public function rSetBehindView(bool view)
{
	SetBehindView(view);
}

// Called at RestartPlayer by GameType
public function rSetCameraMode(name cameraSetting)
{
	SetCameraMode(cameraSetting);
}

DefaultProperties
{
	defaultMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
	defaultAnimTree=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
	defaultAnimSet(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	defaultPhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
}
