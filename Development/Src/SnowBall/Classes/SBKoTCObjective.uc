/** Generalized class for the various types of objectives in King of the Castle */
class SBKotCObjective extends UTGameObjective
	config(SnowBall);

/** is this objective uncontrolled at the moment */
var bool bIsNeutral;

/** Is this objective in the process of being captured */
var bool bIsBeingCaptured;

/** owning team's index */
var int DefendingTeam;

/** The time increments at which capture progress is measure */
var float AreaCheckFrequency;

/** Is there a member of a specific team present */
var Array<bool> TeamPresent;

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
function SetInitialSate()
{
	bIsBeingCaptured = False;
	bIsNeutral = True;
	TeamPresent[0] = false;
	TeamPresent[1] = false;

	LastDefender = none;
}

/** Update nearby actors associated with this objective */
function UpdateCloseActors() {}

/** Check states */
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);	

	if ( !bIsNeutral )
	{
		// Is Attacking team present?
		if ( TeamPresent[1 - DefendingTeam] )
		{
			if ( !TeamPresent[DefendingTeam] )
			{
				// Is the capture in progress already?
				if ( bIsBeingCaptured )
				{
					// Capture Progress
					CaptureProgress += DeltaTime;

					if (CaptureProgress >= CaptureTime)
					{
						// Capture completed
						`Log("SB Objective: Objective captured!");
						SetDefender(1 - DefendingTeam);
					}				
				}
				else
				{
					// Starting capture
					`Log("SB Objective: Capturing...");
					bIsBeingCaptured = true;
					CaptureProgress = 0;
				}
			}
			else
			{
				if ( bIsBeingCaptured )
				{
					// Capture aborted. Enemy blocking it
					`Log("SB Objective: Defender present. Capture aborted!");
					bIsBeingCaptured = false;
					CaptureProgress = 0;
				}
				else
				{
					// Capture blocked. Enemy present
					`Log("SB Objective: Defender blocking capture attempt!");
				}
			}
		}
		else
		{
			if ( bIsBeingCaptured )
			{
				// Capture aborted, no attackers present
				`Log("SB Objective: Attacker left. Capture aborted!");
				bIsBeingCaptured = false;
				CaptureProgress = 0;
			}
		}
	}
	else
	{
		if ( bIsBeingCaptured )
		{
			// Is Attacking team still present?
			if ( TeamPresent[1 - DefendingTeam] )
			{
				// Is the other team there now?
				if ( TeamPresent[DefendingTeam] )
				{
					// Capture aborted. enemy interfered
					bIsBeingCaptured = false;
					CaptureProgress = 0;
				}
				else
				{
					// Capture Progress
					CaptureProgress += DeltaTime;

					if (CaptureProgress >= CaptureTime)
					{
						// Capture completed
						SetDefender(1 - DefendingTeam);
					}		
				}
			}
			else
			{
				// Captured aborted, attacker not present
				bIsBeingCaptured = false;
				CaptureProgress = 0;
			}
		}
		else
		{
			// Only allow capture if a team is the only one present
			if ( TeamPresent[0] && !TeamPresent[1] )
			{
				// Starting capture for team 0
				DefendingTeam = 1;
				bIsBeingCaptured = true;
				CaptureProgress = 0;
			}
			else if ( !TeamPresent[0] && TeamPresent[1] )
			{
				// Starting capture for team 1
				DefendingTeam = 0;
				bIsBeingCaptured = true;
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

	TeamPresent[0] = false;
	TeamPresent[1] = false;

	foreach AllActors(class'SBBot_Custom', Player)
	{
		Distance = VSize(Player.Location - Location);

		if (Distance <= CaptureDistance)
		{
			TeamPresent[(Player.GetTeam()).TeamIndex] = true;
		}
	}
}

/** Set the new defending team */
function SetDefender(int TeamIndex)
{
	bIsNeutral = false;
	bIsBeingCaptured = false;
	DefendingTeam = TeamIndex;
}

/** Reset the objective */
function Reset()
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