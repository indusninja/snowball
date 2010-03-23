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
var int BasePawnSpeed;
var int FastPawnSpeed;

event PlayerTick(float DeltaTime)
{
	local string materialName;

	super.PlayerTick(DeltaTime);

	if(Pawn!=None)
	{
		materialName = string(SBBot_Custom(Pawn).GetAmmoMaterial());

		//`Log("Material: "$materialName);

		if((materialName == "MAT_SnowWall")||(materialName == "Snow01"))
		{
			Pawn.GroundSpeed = BasePawnSpeed;
			Pawn.Weapon.AddAmmo(AmmoRate);
		}
		else
		{	
			Pawn.GroundSpeed = FastPawnSpeed;
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
	Pawn.GroundSpeed=BasePawnSpeed;
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
	BasePawnSpeed=300;
	FastPawnSpeed=400;
	defaultMesh=SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA'
	defaultAnimTree=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
	defaultAnimSet(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
	defaultPhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
}
