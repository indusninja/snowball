class SBActor_SnowWall extends FracturedStaticMeshActor
placeable;



var Vector Destination;

/** Used to shut down actor on the server to reduce overhead. */
simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Destination=self.Location;
	`log( "Destination: "$Destination );
	//SetStaticMesh(StaticMesh'PAK_SnowBall_v1.StaticMesh.S_LT_Buildings_SM_BunkerWallB_STR_FRACTURED');
	//ActorFactoryFracturedStaticMesh
	//SetPhysicalCollisionProperties
}

//Server replicates the wall location to the clients
replication
	{
		if (Role<ROLE_Authority && bNetDirty)
			Destination;
		
	}

defaultproperties
{
	// Set the role for the client
	//
	RemoteRole=ROLE_SimulatedProxy
	
	bStatic=false// Does not move or change over time. It is only safe to change this property in defaultproperties.
	bNoDelete=false // Cannot be deleted during play.

	bReplicateRigidBodyLocation=true // replicate Location property even when in PHYS_RigidBody
	bReplicateMovement=true // if true, replicate movement/location related properties
	
 

    Begin Object Name=FracturedStaticMeshComponent0 
        StaticMesh=FracturedStaticMesh'PAK_SnowBall_v1.StaticMesh.S_LT_Buildings_SM_BunkerWallB_STR_FRACTURED'

    End Object 
	Components.Add(FracturedStaticMeshComponent0)



}
