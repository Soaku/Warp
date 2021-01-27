module warp.pages.worlds;

import warp.structs;
import warp.pages.not_found;

/// Route worlds
Message[] serveWorlds(ref Context context) {

    switch (context.param(1, "list")) {

        case "owned":
        case "list":
            return context.listWorlds(WorldListFilter.owned);

        case "public":
        case "create", "new":
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
        Message.addLink("plus", "Create a new world", "/worlds/new"),
    ];

}
