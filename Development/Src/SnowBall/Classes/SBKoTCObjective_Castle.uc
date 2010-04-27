/** Generalized class for the various types of objectives in King of the Castle */
class SBKotCObjective_Castle extends SBKotCObjective
	placeable
	config(SnowBall);

/** Combined time that a team needs to hold the castle in */
var config float TimeToWin;

/** How much progress each team has made on their timer */
var array<float> TeamTimerProgress;

/** Set initial state of this objective */
simulated function SetInitialState()
{
	`Log("SB Objective: Resetting objective");

	ClearTimer('WinTimer');
	TeamTimerProgress[0] = 0;
	TeamTimerProgress[1] = 0;

	super.SetInitialState();
}

/** Set the new defending team */
simulated function SetTeam(byte TeamIndex)
{
	local float Progress;

	`Log("SB Objective: Setting team to "@TeamIndex);

	if ( ( (DefenderTeamIndex == 0) || (DefenderTeamIndex == 1) ) && !bIsNeutral )
	{
		Progress = GetTimerCount('WinTimer');
		ClearTimer('WinTimer');

		`Log("SB Objective: WinTimer stopped after "@Progress);

		TeamTimerProgress[DefenderTeamIndex] += Progress;
	}
	
	if ( (TeamIndex == 0) || (TeamIndex == 1) )
	{
		`Log("SB Objective: WinTimer started with "@(TimeToWin-TeamTimerProgress[TeamIndex]));
		SetTimer(TimeToWin-TeamTimerProgress[TeamIndex],false,'WinTimer');
	}

	super.SetTeam(TeamIndex);
}

/** Function to call when a team has held the castle long enough */
simulated function WinTimer()
{
	`Log("SB Objective: Game won by team "@DefenderTeamIndex);
	SBGame_KotC(WorldInfo.Game).CastleHeld(DefenderTeamIndex);
}