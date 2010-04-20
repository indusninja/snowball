// SnowBall Game HUD

class SBHUD extends UTHUD
	config(SnowBall);

//var config name ThermometerMaterial;
var Texture2D HUDBaseTex;

var config Vector2D ThermometerTexPosition;
var config Vector2D ThermometerTexSize;
var config Vector2D SnowAmmoTexPosition;
var config Vector2D SnowAmmoTexSize;
var config Vector2D CrossTexPosition;
var config Vector2D CrossTexSize;

function DrawGameHud()
{
	local Vector2D thermometerDrawBasePosition;
	local Vector2D thermometerDrawResolvedPosition;
	local Vector2D ammoDrawBasePosition;
	local Vector2D ammoDrawResolvedPosition;
	//local Vector2D crossBasePosition;
	//local Vector2D crossResolvedPosition;

	thermometerDrawBasePosition.X = 10;
	thermometerDrawBasePosition.Y = 768 - ThermometerTexSize.Y - 10;
	thermometerDrawResolvedPosition = ResolveHUDPosition(thermometerDrawBasePosition, ThermometerTexSize.X, ThermometerTexSize.Y);

	ammoDrawBasePosition.X = 1024 - (SnowAmmoTexSize.X);
	ammoDrawBasePosition.Y = 768 - SnowAmmoTexSize.Y - 10;
	ammoDrawResolvedPosition = ResolveHUDPosition(ammoDrawBasePosition, SnowAmmoTexSize.X, SnowAmmoTexSize.Y);

	//`log("Ammo: " $ ammoDrawBasePosition.X $ ", " $ ammoDrawBasePosition.Y);
	//`log("Ammo: " $ ammoDrawResolvedPosition.X $ ", " $ ammoDrawResolvedPosition.Y);
    if ( !PlayerOwner.IsDead() && !UTPlayerOwner.IsInState('Spectating') )
    {
		if(PlayerOwner.Pawn != none && PawnOwner != none)
		{
			DrawBar("Health", PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax, 20, 20, 200, 80, 80);
			DrawBar("Ammo", UTWeapon(PawnOwner.Weapon).AmmoCount, UTWeapon(PawnOwner.Weapon).MaxAmmoCount, 20, 40, 80, 80, 200);
			DrawThermometer(PlayerOwner.Pawn.Health, thermometerDrawResolvedPosition.X, thermometerDrawResolvedPosition.Y);
			DrawAmmo(UTWeapon(PawnOwner.Weapon).AmmoCount, ammoDrawResolvedPosition.X, ammoDrawResolvedPosition.Y, 255, 255, 255);
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

function DrawThermometer(float value, int X, int Y)
{
	local Color barColor;

	barColor.R = 255 * value;
	barColor.G = 0;
	barColor.B = 255 * (100 - value);
	barColor.A = 255;

	Canvas.Reset();
	Canvas.SetPos(X, Y);
	Canvas.DrawColor = barColor;
	Canvas.DrawRect(ThermometerTexSize.X, ThermometerTexSize.Y * value);

	Canvas.Reset();
	Canvas.SetPos(X, Y);
	Canvas.SetDrawColor(255, 255, 255, 255);
	Canvas.DrawTile(HUDBaseTex, ThermometerTexSize.X, ThermometerTexSize.Y, ThermometerTexPosition.X, ThermometerTexPosition.Y, ThermometerTexSize.X, ThermometerTexSize.Y);
}

function DrawAmmo(int value, int X, int Y, int R, int G, int B)
{
	local string Amount;
	//local vector2d POS, AmmoTextOffsetPOS;
	//local float TX, TY;

	Canvas.Reset();
	Canvas.SetPos(X, Y);
	Canvas.SetDrawColor(R, G, B, 255);
	Canvas.DrawTile(HUDBaseTex, SnowAmmoTexSize.X, SnowAmmoTexSize.Y, SnowAmmoTexPosition.X, SnowAmmoTexPosition.Y, SnowAmmoTexSize.X, SnowAmmoTexSize.Y);

	Canvas.Reset();
	Canvas.SetPos(X + SnowAmmoTexSize.X + 10, Y + (SnowAmmoTexSize.Y / 2) - (CrossTexSize.Y / 2));
	Canvas.SetDrawColor(R, G, B, 255);
	Canvas.DrawTile(HUDBaseTex, CrossTexSize.X, CrossTexSize.Y, CrossTexPosition.X, CrossTexPosition.Y, CrossTexSize.X, CrossTexSize.Y);

	Amount = ""$value;
	Canvas.Reset();
	Canvas.SetPos(X + SnowAmmoTexSize.X + CrossTexSize.X + 20, Y);
    Canvas.SetDrawColor(R, G, B, 255);
    Canvas.Font = Font'SB_GameHUD.Font.FrostyLarge';
    Canvas.DrawText(Amount, , 1.5,1.5);

	// Draw the amount
	/*
	Canvas.DrawColor = WhiteColor;
	Canvas.TextSize(Amount, TX, TY);
	TX *= HUDFontScale.X; TY *= HUDFontScale.Y;

	AmmoTextOffsetPOS = ResolveHUDOffset(POS, AmmoTextOffset, TX, TY);
	Canvas.SetPos(AmmoTextOffsetPOS.X,AmmoTextOffsetPOS.Y);
	Canvas.DrawText(Amount,,HUDFontScale.X * ResolutionScale,HUDFontScale.Y * ResolutionScale);
	*/
}

defaultproperties
{
	HUDBaseTex=Texture2D'SB_GameHUD.HUD.SB_BaseHUD'
}