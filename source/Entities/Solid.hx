package;

import flixel.FlxBasic;
import flixel.tile.FlxTileblock;
import flixel.FlxG;

class Solid extends Entity
{
    var ladderSprite : FlxTileblock;

    var xRemainder : Float;
    var yRemainder : Float;

    var ridingActors : Array<Actor>;

    public function new(X : Float, Y : Float, Width : Float, Height : Float, World : World)
    {
        super(X, Y, World);

        handleGraphic(Width, Height);
    }

    function handleGraphic(?Width : Float = -1, ?Height : Float = -1)
    {
        ladderSprite = null;

        var c = 0x88FF0a00; // Full solid
        if (Height < 14)
            c = 0x8800FF0a; // One way solid
        if (Width < 7)
        {
            c = 0x88ffA00a; // Ladder
            ladderSprite = new FlxTileblock(Std.int(x-2), Std.int(y), 7, Std.int(Height));
            ladderSprite.loadTiles("assets/images/ladder.png", 7, 14);
            ladderSprite.color = c;
            makeGraphic(1, 1, 0x00000000);
        }
        else
            makeGraphic(Std.int(Width), Std.int(Height), c);

        setSize(Std.int(Width), Std.int(Height));

        visible = false;
    }

    override public function onUpdate(elapsed : Float)
    {
        #if (desktop || web)
        if (FlxG.keys.justPressed.O)
            visible = !visible;
        #end
        if (ladderSprite != null)
            visible = true;

        super.onUpdate(elapsed);
    }

    public function lateUpdate()
    {
        /* DEBUG: Moveable solid */
        if (width > 7 && height > 14)
        {
            var h : Float = 0;
            var v : Float = 0;
            #if (desktop || web)
            if (FlxG.keys.pressed.L)
                h = 1;
            else if (FlxG.keys.pressed.J)
                h = -1;
            if (FlxG.keys.pressed.I)
                v = -1;
            else if (FlxG.keys.pressed.K)
                v = 1;
            #end
            
            if (h != 0 || v != 0)
                move(h, v);
        }
    }

    override public function draw()
    {
        if (ladderSprite != null)
            ladderSprite.draw();
        
        super.draw();
    }

    public function move(horizontal : Float, vertical : Float)
    {
        xRemainder += horizontal;
        yRemainder += vertical;
        var moveX : Int = Std.int(xRemainder);
        var moveY : Int = Std.int(yRemainder);

        if (moveX != 0 || moveY != 0)
        {
            // Fetch all riding actors
            getAllRidingActors(); 

            var itIsSolid = true;
            solid = false;
            if (world.solids.members.indexOf(this) >= 0)
            {
                world.solids.remove(this);
                itIsSolid = true;
            }
            else if (world.oneways.members.indexOf(this) >= 0)
            {
                world.oneways.remove(this);
                itIsSolid = false;
            }

            var allActors : Array<Actor> = [];
            world.forEachOfType(Actor, function(actor : Actor) {
                // Avoid moving hazards
                if (!Std.is(actor, Hazard))
                    allActors.push(actor);
            }, true);

            if (moveY != 0)
            {
                yRemainder -= moveY;
                y += moveY;

                for (actor in allActors)
                {
                    if (overlaps(actor))
                    {
                        // Push actor
                        if (moveY > 0)
                            actor.moveY(y + height - actor.y, actor.squish);
                        else if (moveY < 0)
                            actor.moveY(y - (actor.y + actor.height), actor.squish);
                    }
                    else if (ridingActors.indexOf(actor) >= 0)
                    {
                        // Carry actor
                        actor.yRemainder = 0;
                        actor.moveY(moveY);
                        // Special player case
                        if (Std.is(actor, Player))
                        {
                            cast(actor, Player).handleAfterMovement();
                        }
                    }
                }
            }

            if (moveX != 0)
            {
                xRemainder -= moveX;
                x += moveX;
                
                for (actor in allActors)
                {
                    if (overlaps(actor))
                    {
                        // Push actor
                        if (moveX > 0)
                            actor.moveX(x + width - actor.x, actor.squish);
                        else if (moveX < 0)
                            actor.moveX(x - (actor.x + actor.width), actor.squish);
                    }
                    else if (ridingActors.indexOf(actor) >= 0)
                    {
                        // Carry actor
                        actor.moveX(moveX);
                    }
                }
            }

            if (itIsSolid)
                world.solids.add(this);
            else 
                world.oneways.add(this);
                
            solid = true;
        }
    }

    function getAllRidingActors()
    {
        ridingActors = [];

        // Player
        if (world.player.isRiding(this))
            ridingActors.push(world.player);

        world.items.forEach(handleRiding);
        world.enemies.forEach(handleRiding);

        // TODO: Add the rest        
        // No more ?    
    }

    function handleRiding(actor : FlxBasic) {
        if (cast(actor, Actor).isRiding(this))
            ridingActors.push(cast(actor, Actor));
    }

    override public function drawDebugOnCamera(camera : flixel.FlxCamera) : Void
    {
        // NOP!
    }
}
