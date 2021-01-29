module warp.worlds.worldgen;

import std.stdio;
import std.format;
import std.concurrency;

import warp.user;
import warp.server;
import warp.structs;
import warp.worlds.world;

public {

    import warp.main : worldgen;
    import std.concurrency : send;

}

/// Currently built world.
private World world;

/// Start the worldgen thread
void startWorldgen() {

    while (true) {

        // Receive world creation orders
        auto order = receiveOnly!(shared User, World.Type);

        // Prepare the world
        world = new shared World;
        world.owner = order[0];
        world.type = order[1];

        // Send feedback
        world.owner.sendEvent("worldgen",
            Message.addContent(order[1].format!"Building a new %s world..."),
        );

    }

}
