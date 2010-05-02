/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */
class SBCharSoundGroup extends UTPawnSoundGroup
	abstract
	dependson(UTPhysicalMaterialProperty);

defaultproperties
{
	GaspSound=SoundCue'A_Character_IGMale_Cue.Efforts.A_Effort_IGMale_MaleDrowning_Cue'
	DoubleJumpSound=SoundCue'SB_Audio.SB_A_NullSound_Cue'
	DefaultJumpingSound=SoundCue'SB_Audio.SB_A_NullSound_Cue'

	FootstepSounds[0]=(MaterialType=Stone,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneCue')
	FootstepSounds[9]=(MaterialType=Snow,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowCue')

	JumpingSounds[0]=(MaterialType=Stone,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneJumpCue')
	JumpingSounds[11]=(MaterialType=Snow,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowJumpCue')

	DefaultLandingSound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_DirtLandCue'
	LandingSounds[0]=(MaterialType=Stone,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_StoneLandCue')
	LandingSounds[11]=(MaterialType=Snow,Sound=SoundCue'A_Character_Footsteps.FootSteps.A_Character_Footstep_SnowLandCue')

	BulletImpactSound=SoundCue'A_Character_IGMale_Cue.Efforts.A_Effort_IGMale_MaleDrowning_Cue'
}

