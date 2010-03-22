class SBPlayerController_ThirdPerson extends UTPlayerController
	config(SnowBall);

// members for the custom mesh
var SkeletalMesh defaultMesh;
var MaterialInterface defaultMaterial0;
var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;
var AnimNodeSequence defaultAnimSeq;
var PhysicsAsset defaultPhysicsAsset;

const AmmoRate=1;

event PlayerTick(float DeltaTime)
{
	super.PlayerTick(DeltaTime);

	if(Pawn!=None)
	{
		if(string(SBBot_Custom(Pawn).GetAmmoMaterial()) == "MAT_SnowWall")
		{
			Pawn.GroundSpeed = 550;
			Pawn.Weapon.AddAmmo(AmmoRate);
		}
		else
		{	
			Pawn.GroundSpeed = 50;
		}
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
	Pawn.Mesh.SetSkeletalMesh(defaultMesh);
	Pawn.Mesh.SetMaterial(0,defaultMaterial0);
	Pawn.Mesh.SetPhysicsAsset(defaultPhysicsAsset );
	Pawn.Mesh.AnimSets=defaultAnimSet;
	Pawn.Mesh.SetAnimTreeTemplate(defaultAnimTree);
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
