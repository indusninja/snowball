/** King of the Castle game-mode */
class SBGame_KotC extends UTTeamGame
	config(SnowBall);

/** List of objectives in level */
var array<SBKotCObjective> KotCObjectives;

var SBPlayerController_ThirdPerson currentPlayer;

var config bool IsThirdPerson;

/** Stuff to do once play begins */
simulated function PostBeginPlay() 
{
	local UTGame Game;
	Super.PostBeginPlay();
	Game = UTGame(WorldInfo.Game);
	if (Game != None)
	{
		Game.PlayerControllerClass=Class'SnowBall.SBPlayerController_ThirdPerson';
	}
}

/** Init the game mode */
event InitGame(string Options, out string ErrorMessage)
{
	local SBKotCObjective Objective;

	Super.InitGame(Options, ErrorMessage);

	// Find objectives present in level
	foreach AllActors(class'SBKotCObjective', Objective)
	{
		// Register KotC objectives
		KotCObjectives[KotCObjectives.length] = Objective;
	}

	// Throw error if no objectives are present
	if (KotCObjectives.length == 0)
	{
		`Log("KotC: No objectives found in level!",,'error');
	}

	InitObjectives();
}

/** Find the different objectives and set them up */
function InitObjectives()
{
	// Go through the objective list, find out what type each objective is and init accordingly
}

/** Restart the player */
function RestartPlayer(Controller aPlayer)
{
	super.RestartPlayer(aPlayer);
	//`Log("Player restarted");
	currentPlayer = SBPlayerController_ThirdPerson(aPlayer);
	currentPlayer.resetMesh();
	if(IsThirdPerson)
	{
		SBPlayerController_ThirdPerson(aPlayer).rSetBehindView(true);
		SBPlayerController_ThirdPerson(aPlayer).rSetCameraMode('ThirdPerson');
	}
}

DefaultProperties
{
	PlayerControllerClass=Class'SnowBall.SBPlayerController_ThirdPerson'
	DefaultPawnClass=class'SnowBall.SBBot_Custom'
	//bAutoNumBots=false
	//MaxPlayersAllowed=4
	DefaultInventory(0)=class'SnowBall.SBWeap_SnowBallThrow'

	MapPrefixes[0]="SB"
	Acronym="KotC"

	bScoreVictimsTarget=false
	bTeamScoreRounds=false
	bScoreTeamKills=false
	bScoreDeaths=false

	HUDType=class'SnowBall.SBHUD'
}