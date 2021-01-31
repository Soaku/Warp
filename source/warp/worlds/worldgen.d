module warp.worlds.worldgen;

import std.format;
import std.random;
import std.concurrency;

import warp.user;
import warp.server;
import warp.structs;
import warp.worlds.height;

public {

    import warp.main : worldgen;
    import std.concurrency : send;

    import warp.worlds.world;

}

/// Currently built world.
private shared World world;

/// Start the worldgen thread
void startWorldgen() {

    while (true) {

        // Receive world creation orders
        auto order = receiveOnly!(shared User, World.Type);

        // Prepare the world
        world = new shared World;
        world.owner = order[0];
        world.type = order[1];
        world.seed = unpredictableSeed;

        // Send feedback
        format!"Building a new %s world with seed %s..."(order[1], world.seed)
            .updateStatus();

        // Build the world
        buildWorld();

    }

}

/// Send a status update. Shouldn't be used if the job is finished.
void updateStatus(string text) {

    with (Message)
    world.owner.sendEvent("worldgen",
        listen("worldgen"),
        setTheme(Color.grey),
        mapMode(MapMode.terrain),
        addContent(text),
    );

}

/// Build the world
void buildWorld() {

    world.generateHeight();

}
