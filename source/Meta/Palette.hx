package;

class Palette
{
    public static var black       : Array<Int> = [0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000, 0xFF000000];
    public static var white       : Array<Int> = [0xFF202020, 0xFF404040, 0xFF606060, 0xFF808080, 0xFF9f9f9f, 0xFFbfbfbf, 0xFFdfdfdf, 0xFFffffff];
    public static var red         : Array<Int> = [0xFF580902, 0xFF782922, 0xFF984942, 0xFFb86962, 0xFFd88882, 0xFFf7a8a2, 0xFFffc8c2, 0xFFffe8e2];
    public static var cyan        : Array<Int> = [0xFF00373d, 0xFF08575d, 0xFF27777d, 0xFF47969d, 0xFF67b6bd, 0xFF87d6dd, 0xFFa7f6fd, 0xFFc7ffff];
    public static var purple      : Array<Int> = [0xFF4b0056, 0xFF6b1f76, 0xFF8b3f96, 0xFFaa5fb6, 0xFFca7fd6, 0xFFea9ff6, 0xFFffbfff, 0xFFffbfff];
    public static var green       : Array<Int> = [0xFF004000, 0xFF156009, 0xFF358029, 0xFF55a049, 0xFF74c069, 0xFF94e089, 0xFFb4ffa9, 0xFFd4ffc9];
    public static var blue        : Array<Int> = [0xFF20116d, 0xFF40318d, 0xFF6051ac, 0xFF8071cc, 0xFF9f90ec, 0xFFbfb0ff, 0xFFdfd0ff, 0xFFfff0ff];
    public static var yellow      : Array<Int> = [0xFF202f00, 0xFF404f00, 0xFF606f13, 0xFF808e33, 0xFF9fae53, 0xFFbfce72, 0xFFdfee92, 0xFFffffb2];
    public static var orange      : Array<Int> = [0xFF4b1500, 0xFF6b3409, 0xFF8b5429, 0xFFaa7449, 0xFFca9469, 0xFFeab489, 0xFFffd4a9, 0xFFfff4c9];
    public static var brown       : Array<Int> = [0xFF372200, 0xFF574200, 0xFF776219, 0xFF978139, 0xFFb7a158, 0xFFd7c178, 0xFFf6e198, 0xFFffffb8];
    public static var yellowgreen : Array<Int> = [0xFF093a00, 0xFF285900, 0xFF487919, 0xFF689939, 0xFF88b958, 0xFFa8d978, 0xFFc8f998, 0xFFe8ffb8];
    public static var pink        : Array<Int> = [0xFF5d0120, 0xFF7d2140, 0xFF9c4160, 0xFFbc6180, 0xFFdc809f, 0xFFfca0bf, 0xFFffc0df, 0xFFffe0ff];
    public static var bluegreen   : Array<Int> = [0xFF003f20, 0xFF035f40, 0xFF237f60, 0xFF439e80, 0xFF63be9f, 0xFF82debf, 0xFFa2fedf, 0xFFc2ffff];
    public static var lightblue   : Array<Int> = [0xFF002b56, 0xFF154b76, 0xFF356b96, 0xFF558bb6, 0xFF74abd6, 0xFF94cbf6, 0xFFb4eaff, 0xFFd4ffff];
    public static var darkblue    : Array<Int> = [0xFF370667, 0xFF572687, 0xFF7746a7, 0xFF9766c6, 0xFFb786e6, 0xFFd7a6ff, 0xFFf6c5ff, 0xFFffe5ff];
    public static var lightgreen  : Array<Int> = [0xFF004202, 0xFF086222, 0xFF278242, 0xFF47a262, 0xFF67c282, 0xFF87e2a2, 0xFFa7ffc2, 0xFFc7ffe2];

    public static var colors : Array<Array<Int>>;

    public static var palette : Array<Int>;
    
    public static function Init()
    {
        palette = [];
        colors = [black, white, red, cyan, purple, green, blue, yellow, orange, brown, yellowgreen, pink, bluegreen, lightblue, darkblue, lightgreen];

        for (hue in colors)
        {
            for (color in hue)
                palette.push(color);
        }
    }
}