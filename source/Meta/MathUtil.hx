package;

class MathUtil
{
    public static function sign(num : Float) : Int
    {
        if (num < 0)
            return -1;
        else if (num > 0)
            return 1;
        else
            return 0;
    }
}
