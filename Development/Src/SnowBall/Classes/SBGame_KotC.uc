/** King of the Castle game-mode */
class SBGame_KotC extends UTTeamGame
	config(SnowBall);

/** List of objectives in level */
var array<SBKotCObjective> KotCObjectives;
var SBKotCObjective_Castle KotCCastle;
var SBPlayerController_ThirdPerson currentPlayer;
var config bool IsThirdPerson;

var array<string> playerNames;

event PostLogin ( playerController NewPlayer )
{
	local string playerName;
	local int randOutput;
	
	playerName = NewPlayer.GetHumanReadableName();

	//`Log("Current Player is on Team: "@string(NewPlayer.GetTeamNum()));
	//`Log("Current Player's Family: "@string(Teams[NewPlayer.GetTeamNum()].get));
	//`Log("Current Player's Faction: "@TeamFactions[NewPlayer.GetTeamNum()]);

	Super.PostLogin(NewPlayer);

	if(InStr(playerName, "player", false, true, 0)!=-1)
	{
		randOutput = Rand(playerNames.Length - 1);
		//`Log("Number of Random Names: "@playerNames.Length);
		playerName = playerNames[randOutput];
		//`Log("Changing Player Name to: "@playerName);
		ChangeName( NewPlayer, playerName, false );
	}
}

function PreBeginPlay()
{
	Super.PreBeginPlay();

	CreateTeam(0);
	CreateTeam(1);
	Teams[0].AI.EnemyTeam = Teams[1];
	Teams[1].AI.EnemyTeam = Teams[0];
	
	//`Log("PreBeginPlay SBGAME_KOTC");
}

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

	playerNames.AddItem("Klaus");
	playerNames.AddItem("Orestis");
	playerNames.AddItem("Sune");
	playerNames.AddItem("Simon");
	playerNames.AddItem("Martin");
	playerNames.AddItem("Juan");
	playerNames.AddItem("Prakash");
	playerNames.AddItem("Alex");
	playerNames.AddItem("Paul");
	playerNames.AddItem("Hans");
	playerNames.AddItem("Søren");
	playerNames.AddItem("Gabrielle");
	playerNames.AddItem("Aske");
	playerNames.AddItem("Ben");
	playerNames.AddItem("Michael");
	playerNames.AddItem("Jack");

	Super.InitGame(Options, ErrorMessage);

	/*TeamFactions[0] = "Kids";
	TeamFactions[1] = "Kids";*/

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
	local int i;

	// Find the castle
	for (i = 0; i < KotCObjectives.length; i++)
	{
		if (SBKotCObjective_Castle(KotCObjectives[i]) != None)
		{
			if (KotCCastle == None)
				KotCCastle = SBKotCObjective_Castle(KotCObjectives[i]);
			else
				`Log("KotC: Multiple castles found!!",,'error');
		}
	}
}

/* create a player team, and fill from the team roster
*/
function CreateTeam(int TeamIndex)
{
	Teams[TeamIndex] = spawn(class'SnowBall.SBTeamInfo');
	Teams[TeamIndex].Faction = TeamFactions[TeamIndex];
	Teams[TeamIndex].Initialize(TeamIndex);
	Teams[TeamIndex].AI = Spawn(TeamAIType[TeamIndex]);
	Teams[TeamIndex].AI.Team = Teams[TeamIndex];
	GameReplicationInfo.SetTeam(TeamIndex, Teams[TeamIndex]);
	Teams[TeamIndex].AI.SetObjectiveLists();
	//`Log("CreateTeam "@TeamIndex@" SBGAME_KOTC");
}

/** Set what to focus on at the end of the game */
function SetEndGameFocus(PlayerReplicationInfo Winner)
{
	local Controller P;

	EndGameFocus = KotCCastle;

	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;

	foreach WorldInfo.AllControllers(class'Controller', P)
	{
		P.GameHasEnded(EndGameFocus, (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner) );
	}
}

/** Check whether the score is sufficient to end the game */
function bool CheckScore(PlayerReplicationInfo Scorer)
{
	if (CheckMaxLives(Scorer) ) 
	{
		return false;
	}
	else if (GoalScore != 0 && (Teams[0].Score >= GoalScore || Teams[1].Score >= GoalScore))
	{
		EndGame(Scorer,"teamscorelimit");
		return true;
	}
	else
	{
		return false;
	}
}

/** Called by the castle objective once a team has succesfully captured and held it*/
function CastleHeld(byte TeamIndex)
{
	if (TeamIndex == 0)
	{
		BroadcastLocalizedMessage( MessageClass, 0);
		Teams[0].Score += 1;
		Teams[0].bForceNetUpdate = TRUE;
		CheckScore(KotCCastle.LastDefender);
	}
	else
	{
		BroadcastLocalizedMessage( MessageClass, 1);
		Teams[1].Score += 1;
		Teams[1].bForceNetUpdate = TRUE;
		CheckScore(KotCCastle.LastDefender);
	}
	BroadcastLocalizedMessage( MessageClass, bOverTime ? 12 : 11);

	if (!bGameEnded)
	{
		EndRound(KotCCastle);
	}
}

/** State for when the match is over */
state MatchOver
{
	/** Dummy function if a castle capture happens after match is over */
	function CastleHeld(byte TeamIndex) {}
}

/** Reset the game for a new round */
function Reset()
{
	local int i;
	local UTPlayerReplicationInfo PRI;

	/*for (i = 0; i < KotCObjectives.length; i++)
	{
		KotCObjectives[i].Reset();
	}*/

	Super.Reset();
	
	// reset per-life PRI properties
	for (i = 0; i < GameReplicationInfo.PRIArray.length; i++)
	{
		PRI = UTPlayerReplicationInfo(GameReplicationInfo.PRIArray[i]);
		if (PRI != None)
		{
			PRI.Spree = 0;
		}
	}

	for (i = 0; i < ArrayCount(Teams); i++)
	{
		Teams[i].AI.SetObjectiveLists();
	}
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