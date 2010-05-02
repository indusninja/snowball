/** Generalized class for the various types of objectives in King of the Castle */
class SBKotCObjective extends UTGameObjective
	placeable
	config(SnowBall);

/** is this objective uncontrolled at the moment */
var bool bIsNeutral;

/** Is this objective in the process of being captured */
var bool bIsBeingCaptured;

/** Is control tied at the moment */
var bool bIsTied;

/** The time increments at which capture progress is measure */
var float AreaCheckFrequency;

/** Which team is controlling */
var byte CurrentTeam;

/** Team in the process of capturing */
var byte CaptureTeamIndex;

/** The amount of time that capture has been in progress */
var float CaptureProgress;

/** The amount of time needed to capture the objective */
var float CaptureTime;

/** the distance at which the objective can be captured */
var float CaptureDistance;

/** last player to defend this node */
var UTPlayerReplicationInfo LastDefender;

/** Mesh of the objective */
var SkeletalMeshComponent SkelMesh;

/** Material for neutral state */
var Material MaterialNeutral;

/** Material for red team */
var Material MaterialRed;

/** Material for blue team */
var Material MaterialBlue;

/** Light environment for the flag */
var DynamicLightEnvironmentComponent LightEnvironment;

/** Replicate variables */
simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'DefenderTeamIndex')
	{
		UpdateEffects();

		Super.ReplicatedEvent(VarName);
	}
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}

simulated event PostBeginPlay()
{
	// Init this
	SetInitialState();

	`Log("SB Objective: Remote role: "@Role);

	// Only the server really needs to check
	if (Role == ROLE_AUTHORITY)
		SetTimer(AreaCheckFrequency,true,'AreaCheckTimer');
}

/** Set initial state of this objective */
simulated function SetInitialState()
{
	bIsBeingCaptured = false;
	bIsTied = true;
	LastDefender = none;

	SetTeam(2);

	super.SetInitialState();
}

/** Check states */
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);	
	
	UpdateCaptureStatus(DeltaTime);
}

function UpdateCaptureStatus(float DeltaTime)
{
	if (Role == ROLE_AUTHORITY)
	{
		// What is the current status?
		if ( !bIsTied )
		{
			// Red or Blue Team
			if (bIsBeingCaptured)
			{
				if ( CurrentTeam == CaptureTeamIndex )
				{
					// Capture Progress
					//`Log("SB Objective: Capture progress: "@CaptureProgress);
					CaptureProgress += DeltaTime;

					if (CaptureProgress >= CaptureTime)
					{
						// Capture completed
						`Log("SB Objective: Objective captured by team "@CaptureTeamIndex);
						SetTeam(CaptureTeamIndex);
						bIsBeingCaptured = false;
					}		
				}
				else
				{
					`Log("SB Objective: Capture interrupted by enemy!");
					bIsBeingCaptured = false;
					CaptureProgress = 0;
				}
			}
			else
			{
				// Is the controlling team not the owner?
				if (bIsNeutral || (CurrentTeam != DefenderTeamIndex) )
				{
					`Log("SB Objective: Capture started by team "@CurrentTeam);
					bIsBeingCaptured = true;
					CaptureProgress = 0;
					CaptureTeamIndex = CurrentTeam;
				}
			}
		}
		else
		{
			// Control tied
			if (bIsBeingCaptured)
			{
				`Log("SB Objective: Objective control tied. Capture aborted.");
				bIsBeingCaptured = false;
				CaptureProgress = 0;
			}
		}
	}
}

/** Check for players in the area and determine capture progress */
function AreaCheckTimer()
{
	local SBBot_Custom Player;
	local float Distance;
	local bool TeamRed;
	local bool TeamBlue;

	TeamRed = false;
	TeamBlue = false;

	foreach DynamicActors(class'SBBot_Custom', Player)
	{
		Distance = VSize(Player.Location - Location);

		if (Distance <= CaptureDistance)
		{
			if ( (Player.GetTeam()).TeamIndex == 0 )
			{
				//`log("SB Objective: Player from team red");
				TeamRed = true;
			}
			else if ( (Player.GetTeam()).TeamIndex == 1 )
			{
				//`log("SB Objective: Player from team blue");
				TeamBlue = true;
			}
		}
	}

	if ( TeamRed && !TeamBlue )
	{
		//`log("SB Objective: Red Team Controlling");
		CurrentTeam = 0;
		bIsTied = false;
	}
	else if ( !TeamRed && TeamBlue )
	{
		//`log("SB Objective: Red Team Controlling");
		CurrentTeam = 1;
		bIsTied = false;
	}
	else
	{
		//`log("SB Objective: Control tied");
		bIsTied = true;
	}
}

/** Set the new defending team */
simulated function SetTeam(byte TeamIndex)
{
	if (TeamIndex == 0 || TeamIndex == 1)
		bIsNeutral = false;
	else
		bIsNeutral = true;

	super.SetTeam(TeamIndex);
}

/** Update effects associated with the objective (color, etc) */
simulated function UpdateEffects()
{
    if ( WorldInfo.NetMode == NM_DedicatedServer )
        return;

	`Log("SB Objective: Mesh updated!");

	if (DefenderTeamIndex == 0)
	{
		SkelMesh.SetMaterial(1,MaterialRed);
	}
	else if (DefenderTeamIndex == 1)
	{
		SkelMesh.SetMaterial(1,MaterialBlue);
	}
	else
	{
		SkelMesh.SetMaterial(1,MaterialNeutral);
	}
}

/** Reset the objective */
simulated function Reset()
{
	SetInitialState();
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	DefenderTeamIndex=2
	CaptureTime=5.0
	CaptureDistance=200
	NetUpdateFrequency = 10.0
	AreaCheckFrequency=0.5
	bStatic=false

	Begin Object Class=DynamicLightEnvironmentComponent Name=FlagLightEnvironment
		bDynamic=FALSE
	End Object
	LightEnvironment=FlagLightEnvironment
	Components.Add(FlagLightEnvironment)

	MaterialNeutral=Material'SB_BaseGameType.Materials.M_CTF_Flag_IG_FlagNeutral'
	MaterialRed=Material'CTF_Flag_IronGuard.Materials.M_CTF_Flag_IG_FlagRed'
	MaterialBlue=Material'CTF_Flag_IronGuard.Materials.M_CTF_Flag_IG_FlagBlue'

	Begin Object Class=SkeletalMeshComponent Name=FlagSkelMesh
		CollideActors=false
		BlockActors=false
		PhysicsWeight=0
		bHasPhysicsAssetInstance=true
		BlockRigidBody=true
		RBChannel=RBCC_Nothing
		RBCollideWithChannels=(Default=FALSE,GameplayPhysics=FALSE,EffectPhysics=FALSE,Cloth=TRUE)
		ClothRBChannel=RBCC_Cloth
		LightEnvironment=FlagLightEnvironment
		bUseAsOccluder=FALSE
		bEnableClothSimulation=true
		bAutoFreezeClothWhenNotRendered=true
		bUpdateSkelWhenNotRendered=false
		ClothWind=(X=20.0,Y=10.0)
		bAcceptsDecals=false
		Translation=(X=0.0,Y=0.0,Z=-40.0)
		SkeletalMesh=SkeletalMesh'CTF_Flag_IronGuard.Mesh.S_CTF_Flag_IronGuard'
		PhysicsAsset=PhysicsAsset'CTF_Flag_IronGuard.Mesh.S_CTF_Flag_IronGuard_Physics'
		Materials(1)=Material'SB_BaseGameType.Materials.M_CTF_Flag_IG_FlagNeutral'
	End Object

	SkelMesh=FlagSkelMesh
	Components.Add(FlagSkelMesh)
}