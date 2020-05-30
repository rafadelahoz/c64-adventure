package;

interface IDangerous
{
    function ignoresInvincibility() : Bool;
    function damages(player : Player) : Int;
    function onPlayerKilled() : Void;
}