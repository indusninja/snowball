/**
 * King of the Castle game-mode
 */

class SBGame_KotC extends UTGame
	config(SnowBall);

var SBPlayerController_ThirdPerson currentPlayer;

function RestartPlayer(Controller aPlayer)
{
	super.RestartPlayer(aPlayer);
	`Log("Player restarted");
	currentPlayer = SBPlayerController_ThirdPerson(aPlayer);
	currentPlayer.resetMesh();
	SBPlayerController_ThirdPerson(aPlayer).rSetBehindView(true);
	SBPlayerController_ThirdPerson(aPlayer).rSetCameraMode('ThirdPerson');
}

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

DefaultProperties
{
	PlayerControllerClass=Class'SnowBall.SBPlayerController_ThirdPerson'
	DefaultPawnClass=class'SnowBall.SBBot_Custom'
	//bAutoNumBots=false
	//MaxPlayersAllowed=4
	DefaultInventory(0)=class'SnowBall.SBWeap_SnowBallThrow'

	HUDType=class'SnowBall.SBHUD'
}