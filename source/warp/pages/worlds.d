module warp.pages.worlds;

import warp.structs;
import warp.pages.error;
import warp.pages.worldgen;

/// Route worlds
Message[] serveWorlds(ref Context context) {

    switch (context.param(1, "list")) {

        case "owned":
        case "list":
            return context.listWorlds(WorldListFilter.owned);

        case "create", "new":
            return context.serveWorldgen;

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

    with (Message)
    return [
        message,
        addContent("Your worlds", 1, Color.cyan),
        addContent("You don't have any worlds... Create a new one!"),
        addContent(),

        addContent("Manage", 1, Color.cyan),
        addLink("Create a new world", "/worlds/new", "plus"),
    ];

}
