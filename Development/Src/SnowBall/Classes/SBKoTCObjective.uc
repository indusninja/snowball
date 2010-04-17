/** Generalized class for the various types of objectives in King of the Castle */
class SBKotCObjective extends UTGameObjective
	config(SnowBall);

/** is this objective uncontrolled at the moment */
var bool bIsNeutral;

/** The time increments at which capture progress is measure */
var float AreaCheckFrequency;

/** amount of progress toward capture of this objective */
var float PctControl;

/** last player to defend this node */
var UTPlayerReplicationInfo LastDefender;

simulated event PostBeginPlay()
{
	// Only the server really needs to check
	if (Role == ROLE_AUTHORITY)
		SetTimer(AreaCheckFrequency,true,'AreaCheckTimer');
}

/** Set initial state of this objective */
function SetInitialSate()
{
	bIsNeutral = True;
	PctControl = 0;
}

/** Update nearby actors associated with this objective */
function UpdateCloseActors() {}

/** Check for players in the area and determine capture progress */
function AreaCheckTimer() {}

/** Reset the objective */
function Reset()
{
	SetInitialState();

	UpdateCloseActors();
}

defaultproperties
{
	AreaCheckFrequency=0.5
	bStatic=false
}