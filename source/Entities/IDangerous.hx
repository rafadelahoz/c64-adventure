package;

interface IDangerous
{
    function damages(player : Player) : Int;
    function onPlayerKilled() : Void;
}