module warp.worlds.worldgen;

import std.meta;
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
    import warp.worlds.params;

}

alias WorldData = AliasSeq!(shared World, const WorldParams);

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

        // Get a seed
        const seed = unpredictableSeed!ulong;

        // Send feedback
        format!"Building a new %s world with seed %s..."(world.type, seed)
            .updateStatus();

        // Get params for the world
        const params = newParams(order[1], seed);

        // Build the world
        buildWorld(params);

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
private void buildWorld(const WorldParams params) {

    // Bundle the params
    alias worldData = AliasSeq!(world, params);

    worldData.generateHeight;

}

private WorldParams newParams(World.Type type, ulong seed) {

    import warp.worlds.regular : regularWorld;

    final switch (type) {

        case World.Type.regular: return regularWorld(seed);

    }

}
