module warp.pages;

import warp.structs;
import warp.server.structs;

public {

    import warp.pages.api;
    import warp.pages.home;
    import warp.pages.error;
    import warp.pages.worlds;
    import warp.pages.characters;

}

Message[] route(ref Context context) {

    // Move to API if requested
    context.serveAPI;

    // If the request is done with POST
    if (context.method == Request.Method.post && context.user) {

        // Get the token
        const token = context.body.get("action-token", "");

        // Verify it
        if (!context.user.verifyActionToken(token)) {

            // Failed, serve an error
            return context.serveInvalidToken;

        }

    }

    switch (context.param(0)) {

        // Menu pages
        case null: return context.serveHome;
        case "characters": return context.serveCharacters;
        case "worlds": return context.serveWorlds;

        // Not implemented
        case "user":
        case "friends":
            return context.serveNotImplemented;

        // Not found
        default: return context.serveNotFound;


    }

}
