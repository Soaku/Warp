module warp.pages.error;

import warp.structs;

/// Serve the 404 page.
Message[] serveNotFound(ref Context context) {

    context.response.status = "404 Not Found";

    return [
        Message.addContent("404 Not Found", 1, Color.red),
        Message.addContent("We cannot warp to this page, it doesn't seem to exist..."),
    ];

}

/// Serve the not implemented page.
Message[] serveNotImplemented(ref Context context) {

    return [
        Message.addContent("Not Implemented", 1, Color.yellow),
        Message.addContent("Unable to warp, the page is still being built! This portal will open soon..."),
    ];

}

// Serve an invalid token page.
Message[] serveInvalidToken(ref Context context) {

    // TODO: add a resubmit button
    return [
        Message.addContent("Invalid token", 1, Color.yellow),
        Message.addContent("Can't warp through a closed portal..."),
        Message.addContent(),
        Message.addContent("Your request verification token has expired, this may happen if you have the game open "
            ~ "in multiple tabs."),
        Message.addContent("Return to the previous page and try again."),
    ];

}
