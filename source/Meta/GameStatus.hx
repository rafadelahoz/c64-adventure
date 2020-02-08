package;

class GameStatus
{
    public static var playerGraphic : Int;
    public static var playerColor : Int;
    public static var map : String; 
    public static var room : Int;

    public static function Init()
    {
        playerGraphic = Math.random() > 0.5 ? 0 : 1;
        playerColor = Math.random() > 0.5 ? 0xFFbfce72 : 0xFF7d2140; // 0xFFfca0bf
        map = "desert";
        room = 1;

        Inventory.Init();
        Inventory.Randomize();
    }
}
