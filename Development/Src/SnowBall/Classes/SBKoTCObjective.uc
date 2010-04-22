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

simulated event PostBeginPlay()
{
	// Init this
	SetInitialState();	

	// Only the server really needs to check
	if (Role == ROLE_AUTHORITY)
		SetTimer(AreaCheckFrequency,true,'AreaCheckTimer');
}

/** Set initial state of this objective */
simulated function SetInitialSate()
{
	bIsBeingCaptured = false;
	bIsNeutral = true;
	bIsTied = true;

	LastDefender = none;
}

/** Update nearby actors associated with this objective */
simulated function UpdateCloseActors() {}

/** Check states */
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);	

	UpdateCaptureStatus(DeltaTime);
}

simulated function UpdateCaptureStatus(float DeltaTime)
{
	if ( !bIsNeutral )
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
					`Log("SB Objective: Capture progress: "@CaptureProgress);
					CaptureProgress += DeltaTime;

					if (CaptureProgress >= CaptureTime)
					{
						// Capture completed
						`Log("SB Objective: Objective captured!");
						SetTeam(CaptureTeamIndex);
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
simulated function AreaCheckTimer()
{
	local SBBot_Custom Player;
	local float Distance;
	local bool TeamRed;
	local bool TeamBlue;

	TeamRed = false;
	TeamBlue = false;

	foreach AllActors(class'SBBot_Custom', Player)
	{
		Distance = VSize(Player.Location - Location);

		if (Distance <= CaptureDistance)
		{
			if ( (Player.GetTeam()).TeamIndex == 0 )
			{
				`log("SB Objective: Player from team red");
				TeamRed = true;
			}
			else if ( (Player.GetTeam()).TeamIndex == 1 )
			{
				`log("SB Objective: Player from team blue");
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
	bIsNeutral = false;
	bIsBeingCaptured = false;

	super.SetTeam(TeamIndex);
}

/** Reset the objective */
simulated function Reset()
{
	SetInitialState();

	UpdateCloseActors();
}

defaultproperties
{
	CaptureTime=5.0
	CaptureDistance=200
	AreaCheckFrequency=0.5
	bStatic=false
}