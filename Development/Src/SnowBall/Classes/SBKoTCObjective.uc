/** Generalized class for the various types of objectives in King of the Castle */
class SBKotCObjective extends UTGameObjective
	config(SnowBall);

/** is this objective uncontrolled at the moment */
var bool bIsNeutral;

/** amount of progress toward capture of this objective */
var float PctControl;

/** last player to defend this node */
var UTPlayerReplicationInfo LastDefender;

function SetInitialSate()
{
	bIsNeutral = True;
	PctControl = 0;
}

function UpdateCloseActors() {}

function Reset()
{
	SetInitialState();

	UpdateCloseActors();
}

defaultproperties
{
	bStatic=false
}