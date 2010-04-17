// SnowBall Game HUD

class SBHUD extends UTHUD
	config(SnowBall);

//var config name ThermometerMaterial;
var Texture2D HUDBaseTex;

var config Vector2D ThermometerTexPosition;
var config Vector2D ThermometerTexSize;
var config Vector2D SnowAmmoTexPosition;
var config Vector2D SnowAmmoTexSize;

function DrawGameHud()
{
	local Vector2D thermometerDrawBasePosition;
	local Vector2D thermometerDrawResolvedPosition;
	local Vector2D ammoDrawBasePosition;
	local Vector2D ammoDrawResolvedPosition;

	thermometerDrawBasePosition.X = 10;
	thermometerDrawBasePosition.Y = 768 - ThermometerTexSize.Y - 10;
	thermometerDrawResolvedPosition = ResolveHUDPosition(thermometerDrawBasePosition, ThermometerTexSize.X, ThermometerTexSize.Y);

	ammoDrawBasePosition.X = 1024 - (SnowAmmoTexSize.X * 3);
	ammoDrawBasePosition.Y = 768 - SnowAmmoTexSize.Y - 10;
	ammoDrawResolvedPosition = ResolveHUDPosition(ammoDrawBasePosition, SnowAmmoTexSize.X, SnowAmmoTexSize.Y);

	//`log("Thermometer: " @ thermometerDrawResolvedPosition);
    if ( !PlayerOwner.IsDead() && !UTPlayerOwner.IsInState('Spectating') )
    {
		if(PlayerOwner.Pawn != none && PawnOwner != none)
		{
			DrawBar("Health", PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax, 20, 20, 200, 80, 80);
			DrawBar("Ammo", UTWeapon(PawnOwner.Weapon).AmmoCount, UTWeapon(PawnOwner.Weapon).MaxAmmoCount, 20, 40, 80, 80, 200);
			DrawThermometer(thermometerDrawResolvedPosition.X, thermometerDrawResolvedPosition.Y);
			DrawAmmo(ammoDrawResolvedPosition.X, ammoDrawResolvedPosition.Y);
		}
    }
}

function DrawBar(String Title, float Value, float MaxValue, int X, int Y, int R, int G, int B)
{
    local int PosX, NbCases, i;

    PosX = X;                                       // Where we should draw the next rectangle
    NbCases = 10 * Value / MaxValue;                // Number of active rectangles to draw
    i=0;                                            // Number of rectangles already drawn

    /* Displays active rectangles */
    while( (i < NbCases) && (i < 10) )
    {
        Canvas.SetPos(PosX, Y);
        Canvas.SetDrawColor(R, G, B, 200);
        Canvas.DrawRect(8, 12);

        PosX += 10;
        i++;
    }

    /* Displays inactive rectangles */
    while(i < 10)
    {
        Canvas.SetPos(PosX, Y);
        Canvas.SetDrawColor(255, 255, 255, 80);
        Canvas.DrawRect(8, 12);

        PosX += 10;
        i++;
    }

    /* Displays a title */
    Canvas.SetPos(PosX + 5, Y);
    Canvas.SetDrawColor(R, G, B, 200);
    Canvas.Font = class'Engine'.static.GetSmallFont();
    Canvas.DrawText(Title);
}

function DrawThermometer(int X, int Y)
{
	Canvas.Reset();
	Canvas.SetPos(X, Y);
	//Canvas.DrawTile(HUDBaseTex, 200, 200, 173, 132, 57, 34);
	Canvas.DrawTile(HUDBaseTex, ThermometerTexSize.X, ThermometerTexSize.Y, ThermometerTexPosition.X, ThermometerTexPosition.Y, ThermometerTexSize.X, ThermometerTexSize.Y);
	//DrawMaterialTile (Material Mat, float XL, float YL, float U, float V, float UL, float VL);
}

function DrawAmmo(int X, int Y)
{
	Canvas.Reset();
	Canvas.SetPos(X, Y);
	//Canvas.DrawTile(HUDBaseTex, 200, 200, 173, 132, 57, 34);
	Canvas.DrawTile(HUDBaseTex, SnowAmmoTexSize.X, SnowAmmoTexSize.Y, SnowAmmoTexPosition.X, SnowAmmoTexPosition.Y, SnowAmmoTexSize.X, SnowAmmoTexSize.Y);
	//DrawMaterialTile (Material Mat, float XL, float YL, float U, float V, float UL, float VL);
}

defaultproperties
{
	HUDBaseTex=Texture2D'SB_GameHUD.HUD.SB_BaseHUD'
	//HUDBaseTex=Texture2D'UI_GoldHud.HudIcons'
}