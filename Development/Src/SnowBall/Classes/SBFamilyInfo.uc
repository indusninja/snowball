/**
 * Copyright 1998-2010 Epic Games, Inc. All Rights Reserved.
 */

class SBFamilyInfo extends UTFamilyInfo
	abstract;

defaultproperties
{
	FamilyID="Snowball"
	Faction="Kids"

	CharacterMesh=SkeletalMesh'SB_Characters.Mesh.SK_CH_TestCharacter'
	
	CharacterTeamHeadMaterials[0]=MaterialInstanceConstant'SB_Characters.Materials.MI_CH_TestCharacter_BearDiffuse'
	CharacterTeamBodyMaterials[0]=MaterialInstanceConstant'SB_Characters.Materials.MI_CH_TestCharacter_BearDiffuse'
	CharacterTeamHeadMaterials[1]=MaterialInstanceConstant'SB_Characters.Materials.MI_CH_TestCharacter_SabreDiffuse'
	CharacterTeamBodyMaterials[1]=MaterialInstanceConstant'SB_Characters.Materials.MI_CH_TestCharacter_SabreDiffuse'

	ArmMeshPackageName="CH_Corrupt_Arms"
	ArmSkinPackageName="CH_Corrupt_Arms"

	ArmMesh=CH_Corrupt_Arms.Mesh.SK_CH_Corrupt_Arms_MaleA_1P
	RedArmMaterial=SB_Characters.Materials.MI_CH_TestCharacter_BearDiffuse
	BlueArmMaterial=SB_Characters.Materials.MI_CH_TestCharacter_SabreDiffuse

	PhysAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
	AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'

	NonTeamEmissiveColor=(R=8.0,G=3.0,B=1.0)
	NonTeamTintColor=(R=3.0,G=2.0,B=1.4)

	BaseMICParent=MaterialInstanceConstant'SB_Characters.Materials.MI_CH_All_Base1'
	BioDeathMICParent=MaterialInstanceConstant'CH_All.Materials.MI_CH_ALL_Corrupt_BioDeath'

	SoundGroupClass=class'SBCharSoundGroup'
	VoiceClass=class'UTVoice_Robot'

	HeadShotEffect=ParticleSystem'T_FX.Effects.P_FX_HeadShot_Corrupt'

	BloodSplatterDecalMaterial=MaterialInstanceTimeVarying'T_FX.DecalMaterials.MITV_FX_OilDecal_Small01'

	GibExplosionTemplate=ParticleSystem'T_FX.Effects.P_FX_GibExplode_Corrupt'

	HeadGib=(BoneName=b_Head,GibClass=class'UTGib_RobotHead',bHighDetailOnly=false)

	Gibs[0]=(BoneName=b_LeftForeArm,GibClass=class'UTGib_RobotArm',bHighDetailOnly=false)
	Gibs[1]=(BoneName=b_RightForeArm,GibClass=class'UTGib_RobotHand',bHighDetailOnly=true)
	Gibs[2]=(BoneName=b_LeftLeg,GibClass=class'UTGib_RobotLeg',bHighDetailOnly=false)
	Gibs[3]=(BoneName=b_RightLeg,GibClass=class'UTGib_RobotLeg',bHighDetailOnly=false)
	Gibs[4]=(BoneName=b_Spine,GibClass=class'UTGib_RobotTorso',bHighDetailOnly=false)
	Gibs[5]=(BoneName=b_Spine1,GibClass=class'UTGib_RobotChunk',bHighDetailOnly=true)
	Gibs[6]=(BoneName=b_Spine2,GibClass=class'UTGib_RobotChunk',bHighDetailOnly=true)
	Gibs[7]=(BoneName=b_LeftClav,GibClass=class'UTGib_RobotChunk',bHighDetailOnly=true)
	Gibs[8]=(BoneName=b_RightClav,GibClass=class'UTGib_RobotArm',bHighDetailOnly=true)

	// 	CH_Gibs.Mesh.SK_CH_Gibs_Corrupt_Part01_Physics arm
	// 	CH_Gibs.Mesh.SK_CH_Gibs_Corrupt_Part02_Physics leg
	// 	CH_Gibs.Mesh.SK_CH_Gibs_Corrupt_Part03_Physics arm
	// 	CH_Gibs.Mesh.SK_CH_Gibs_Corrupt_Part04_Physics leg
	// 	CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part05 spine
	// 	CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part06 shoulder area/ chest
	// 	CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part07 shoulder side 
	// 	CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part08 gen
	// 	CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part09 foot part
	// 	CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part10 thigh
	// 	CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part11 chesty part
	// 	CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part13 generic
	//  CH_Gibs.Mesh.S_CH_Gib_Corrupt_Part12 gen

	BloodEffects[0]=(Template=ParticleSystem'T_FX.Effects.P_FX_Bloodhit_Corrupt_Far',MinDistance=750.0)
	BloodEffects[1]=(Template=ParticleSystem'T_FX.Effects.P_FX_Bloodhit_Corrupt_Mid',MinDistance=350.0)
	BloodEffects[2]=(Template=ParticleSystem'T_FX.Effects.P_FX_Bloodhit_Corrupt_Near',MinDistance=0.0)

	DefaultMeshScale=1.075
	BaseTranslationOffset=14.0
}




