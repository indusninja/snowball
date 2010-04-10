// SnowBall Game HUD

class SBHUD extends UTHUD
	config(SnowBall);

//var config name ThermometerMaterial;
var Texture2D thermometerTex;

function DrawGameHud()
{
    if ( !PlayerOwner.IsDead() && !UTPlayerOwner.IsInState('Spectating') )
    {
		if(PlayerOwner.Pawn != none && PawnOwner != none)
		{
			DrawBar("Health", PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax, 20, 20, 200, 80, 80);
			DrawBar("Ammo", UTWeapon(PawnOwner.Weapon).AmmoCount, UTWeapon(PawnOwner.Weapon).MaxAmmoCount, 20, 40, 80, 80, 200);
			DrawThermometer(20, 60);
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
	//local float XLength,YLength;

	//XLength=Canvas.ClipX;
	//YLength=Canvas.ClipY;

	Canvas.Reset();
	//Canvas.SetPos(X, Y);
	//`Log("Drawing Thermometer");
	Canvas.SetPos(X, Y);
    //Canvas.SetDrawColor(R, G, B, 200);
    //Canvas.Font = class'Engine'.static.GetSmallFont();
    //Canvas.DrawTile(thermometerTex, 1.0, 1.0, 0, 0, thermometerTex.SizeX, thermometerTex.SizeY);
	Canvas.DrawTile(thermometerTex, thermometerTex.SizeX, thermometerTex.SizeY, 0, 0, thermometerTex.SizeX, thermometerTex.SizeY);
	//DrawMaterialTile (Material Mat, float XL, float YL, float U, float V, float UL, float VL);
}

defaultproperties
{
	thermometerTex=Texture2D'SB_GameHUD.HUD.SB_HUDThermo'
}