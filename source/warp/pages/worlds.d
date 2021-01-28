module warp.pages.worlds;

import warp.structs;
import warp.pages.error;

/// Route worlds
Message[] serveWorlds(ref Context context) {

    switch (context.param(1, "list")) {

        case "owned":
        case "list":
            return context.listWorlds(WorldListFilter.owned);

        case "create", "new":
            return context.createWorld;

        case "public":
            return context.serveNotImplemented;

        default: return context.serveNotFound;

    }

}

enum WorldListFilter {

    owned, published, friends

}

/// List worlds
Message[] listWorlds(ref Context context, WorldListFilter filter) {

    return [
        Message.addContent("Your worlds", 1, Color.cyan),
        Message.addContent("You don't have any worlds... Create a new one!"),
        Message.addContent(),
        Message.addContent("Manage", 1, Color.cyan),
        Message.addLink("Create a new world", "/worlds/new", "plus"),
    ];

}

/// Create a world
Message[] createWorld(ref Context context) {

    import std.conv, std.range, std.array;

    return [
        Message.addContent("Do you really want to create this world?", 1, Color.cyan),
        Message.addLink("Cancel", "/worlds", "cancel"),
        Message.addAction("Do it", "type.regular", "confirm"),

        // Solely for testing, remove later
        Message.mapLineHeight(50, 100.to!ubyte.iota.array),
    ];

}
