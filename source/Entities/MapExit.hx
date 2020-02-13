package;

class MapExit extends Entity
{
    public var name : String;

    public function new(X : Float, Y : Float, Width : Int, Height : Int, Name : String, World : World)
    {
        super(X, Y, World);

        name = Name;
        
        if (!GameStatus.isExitClear(name))
            makeGraphic(Constants.TileWidth, Constants.TileHeight, 0xFFFF1f5a);
        else   
            makeGraphic(Constants.TileWidth, Constants.TileHeight, 0xFF9a9a9a);
    }
}