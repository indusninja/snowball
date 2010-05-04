// SnowBall Game HUD

class SBHUD extends UTHUD
	config(SnowBall);

var Texture2D HUDBaseTex;

var config Vector2D ThermometerTexPosition;
var config Vector2D ThermometerTexSize;
var config Vector2D ThermometerFillTexPosition;
var config Vector2D ThermometerFillTexSize;
var config Vector2D ThermometerScale;
var config Vector2D SnowAmmoTexPosition;
var config Vector2D SnowAmmoTexSize;
var config Vector2D CrossTexPosition;
var config Vector2D CrossTexSize;
var config Vector2D TextBackPosition;
var config Vector2D TextBackSize;

function DrawGameHud()
{
	local Vector2D thermometerDrawBasePosition;
	local Vector2D thermometerDrawResolvedPosition;
	local Vector2D thermometerFillDrawBasePosition;
	local Vector2D thermometerFillDrawResolvedPosition;
	local Vector2D ammoDrawBasePosition;
	local Vector2D ammoDrawResolvedPosition;
	local Color teamColor;

	thermometerDrawBasePosition.X = 0;
	thermometerDrawBasePosition.Y = 768 - (ThermometerTexSize.Y * ThermometerScale.Y) - 20;
	thermometerDrawResolvedPosition = ResolveHUDPosition(thermometerDrawBasePosition, ThermometerTexSize.X, ThermometerTexSize.Y);

	thermometerFillDrawBasePosition.X = 0;
	thermometerFillDrawBasePosition.Y = 768 - (ThermometerFillTexSize.Y * ThermometerScale.Y) - 20;
	thermometerFillDrawResolvedPosition = ResolveHUDPosition(thermometerFillDrawBasePosition, ThermometerFillTexSize.X, ThermometerFillTexSize.Y);

	ammoDrawBasePosition.X = 1024 - (SnowAmmoTexSize.X);
	ammoDrawBasePosition.Y = 768 - SnowAmmoTexSize.Y - 10;
	ammoDrawResolvedPosition = ResolveHUDPosition(ammoDrawBasePosition, SnowAmmoTexSize.X, SnowAmmoTexSize.Y);

    if ( !PlayerOwner.IsDead() && !UTPlayerOwner.IsInState('Spectating') )
    {
		if(PlayerOwner.Pawn != none && PawnOwner != none)
		{
			DrawBar("Health", PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax, 20, 20, 200, 80, 80);
			//DrawBar("Ammo", UTWeapon(PawnOwner.Weapon).AmmoCount, UTWeapon(PawnOwner.Weapon).MaxAmmoCount, 20, 40, 80, 80, 200);
			DrawThermometerFill(PlayerOwner.Pawn.Health, thermometerFillDrawResolvedPosition.X, thermometerFillDrawResolvedPosition.Y);
			DrawThermometer(thermometerDrawResolvedPosition.X, thermometerDrawResolvedPosition.Y);
			teamColor = PawnOwner.GetTeam().GetHUDColor();
			DrawAmmo(UTWeapon(PawnOwner.Weapon).AmmoCount, UTWeapon(PawnOwner.Weapon).MaxAmmoCount, ammoDrawResolvedPosition.X, ammoDrawResolvedPosition.Y, teamColor);
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

function DrawThermometerFill(float value, int X, int Y)
{
	Canvas.Reset();
	Canvas.SetPos(X, Y);
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.DrawTile(HUDBaseTex, ThermometerFillTexSize.X * ThermometerScale.X, ThermometerFillTexSize.Y * ThermometerScale.Y, ThermometerFillTexPosition.X, ThermometerFillTexPosition.Y, ThermometerFillTexSize.X, ThermometerFillTexSize.Y);
}

function DrawThermometer(int X, int Y)
{
	Canvas.Reset();
	Canvas.SetPos(X, Y);
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.DrawTile(HUDBaseTex, ThermometerTexSize.X * ThermometerScale.X, ThermometerTexSize.Y * ThermometerScale.Y, ThermometerTexPosition.X, ThermometerTexPosition.Y, ThermometerTexSize.X, ThermometerTexSize.Y);
}

function DrawAmmo(int value, int maxValue, int X, int Y, Color teamColor)
{
	local string Amount;

	Canvas.Reset();
	Canvas.SetPos(X, Y);
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.DrawTile(HUDBaseTex, SnowAmmoTexSize.X, SnowAmmoTexSize.Y, SnowAmmoTexPosition.X, SnowAmmoTexPosition.Y, SnowAmmoTexSize.X, SnowAmmoTexSize.Y);

	Canvas.Reset();
	Canvas.SetPos(X + SnowAmmoTexSize.X + 10, Y + (SnowAmmoTexSize.Y / 2) - (CrossTexSize.Y / 2));
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.DrawTile(HUDBaseTex, CrossTexSize.X, CrossTexSize.Y, CrossTexPosition.X, CrossTexPosition.Y, CrossTexSize.X, CrossTexSize.Y);

	Canvas.Reset();
	Canvas.SetPos(X + SnowAmmoTexSize.X + CrossTexSize.X + 10, Y + (SnowAmmoTexSize.Y / 2) - (TextBackSize.Y / 2));
	Canvas.SetDrawColor(teamColor.R, teamColor.G, teamColor.B, 255);
	Canvas.DrawTile(HUDBaseTex, TextBackSize.X, TextBackSize.Y, TextBackPosition.X, TextBackPosition.Y, TextBackSize.X, TextBackSize.Y);

	Amount = ""$value;
	Canvas.Reset();
    Canvas.Font = Font'SB_GameHUD.Font.FrostyLarge';
	Canvas.SetPos(X + SnowAmmoTexSize.X + CrossTexSize.X + 20, Y + (Canvas.Font.GetMaxCharHeight() / 4));
    Canvas.SetDrawColor(0, 0, 0, 255);
    Canvas.DrawText(Amount, , 0.8,0.8);

	Amount = ""$maxValue;
	Canvas.SetPos(X + SnowAmmoTexSize.X + CrossTexSize.X + 90, Y + (Canvas.Font.GetMaxCharHeight() / 4));
	Canvas.DrawText(Amount, , 0.8,0.8);
}

defaultproperties
{
	HUDBaseTex=Texture2D'SB_GameHUD.HUD.SB_BaseHUD'
}