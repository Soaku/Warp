module warp.handle;

import warp.pages;
import warp.structs;
import warp.server.structs;

Message[] serve(ref Context context) {

    Message[] messageList;

    // Move to API if requested
    context.serveAPI;

    // Stop if this is an event listener
    if (!context.response.autoflush) return [];

    // If the request is done with POST
    if (context.method == Request.Method.post && context.user) {

        // Get the token
        const token = context.body.get("action-token", "");

        // Verify it
        if (!context.user.verifyActionToken(token)) {

            // Failed, serve an error
            return context.serveInvalidToken;

        }

        // Send the new token
        messageList ~= Message.setToken(context.user.actionToken);

    }

    // Route the message
    messageList ~= context.route();

    // Write the map if area has changed or if the client doesn't support history

    return messageList;

}

private Message[] route(ref Context context) {

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
