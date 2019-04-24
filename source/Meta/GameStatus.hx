package;

class GameStatus
{
    public static var playerColor : Int;
    public static var map : String; 
    public static var room : Int;

    public static function Init()
    {
        playerColor = 0xFFbfce72;
        map = "map-ents";
        room = 1;
    }
}
