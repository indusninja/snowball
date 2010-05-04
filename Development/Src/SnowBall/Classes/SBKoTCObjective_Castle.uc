/** Generalized class for the various types of objectives in King of the Castle */
class SBKotCObjective_Castle extends SBKotCObjective
	placeable
	config(SnowBall);

/** Combined time that a team needs to hold the castle in */
var config float TimeToWin;

/** How much progress each team has made on their timer */
var float WinProgress;

/** Either 1 or -1 to set which way the bar progress for the teams */
var int WinProgressOrientation;

/** Has the castle been succesfully held? Stop working if it has */
var bool bCastleHeld;

replication
{
	//If I'm the server I replicate the location and rotation to the clients
	if (Role==ROLE_Authority && bNetDirty) 
		WinProgress;
}

/** Set initial state of this objective */
simulated function SetInitialState()
{
	super.SetInitialState();
	
	WinProgress=0.0;
	bCastleHeld = false;
}

/** Check states */
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);	

	UpdateWinProgress(DeltaTime);
}

/** Function to call when a team has held the castle long enough */
simulated function UpdateWinProgress(float DeltaTime)
{
	local int ProgressDir;

	if ( !bIsNeutral && !bCastleHeld && (DefenderTeamIndex == 0 || DefenderTeamIndex == 1) )
	{
		ProgressDir = ( (1 - DefenderTeamIndex) * -1) + (DefenderTeamIndex * 1);

		WinProgress += DeltaTime * WinProgressOrientation * ProgressDir;

		//`Log("SB Objective: Progress is "@WinProgress);

		if (WinProgress <= (TimeToWin * WinProgressOrientation * -1) )
		{
			if (Role==ROLE_Authority)
			{
				`Log("SB Objective: Game won by team 0 while objective was held by team "@DefenderTeamIndex);
				SBGame_KotC(WorldInfo.Game).CastleHeld(0);
				bCastleHeld = true;
			}
		}
		else if (WinProgress >= (TimeToWin * WinProgressOrientation) )
		{
			if (Role==ROLE_Authority)
			{
				`Log("SB Objective: Game won by team 1 while objective was held by team "@DefenderTeamIndex);
				SBGame_KotC(WorldInfo.Game).CastleHeld(1);
				bCastleHeld = true;
			}
		}
	}
}

defaultproperties
{
	WinProgressOrientation=1
}