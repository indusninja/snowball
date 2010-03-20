/**
  * Example game type for UDK mod making
 * Copyright 1998-2009 Epic Games, Inc. All Rights Reserved.
 */
class SuperFunGame extends UTDeathmatch;

/** 
  * Send an announcement to the killer for every kill
  */
function Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> DamageType )
{
	`log("This works!!! "$Killer);
	if ( PlayerController(Killer) != None )
	{
		PlayerController(Killer).ReceiveLocalizedMessage( class'UTKillingSpreeMessage', 5, Killer.PlayerReplicationInfo, None );
	}
	Super.Killed(Killer, KilledPlayer, KilledPawn, DamageType);
}

/**
  * Don't override this gametype if chosen as DefaultGameType in .ini or on command line
  */
static event class<GameInfo> SetGameType(string MapName, string Options, string Portal)
{
	return default.class;
}