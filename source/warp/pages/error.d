module warp.pages.error;

import warp.structs;

/// Serve the 404 page.
Message[] serveNotFound(ref Context context) {

    context.response.status = "404 Not Found";

    with (Message)
    return [
        message(".."),
        addContent("404 Not Found", 1, Color.red),
        addContent("We cannot warp to this page, it doesn't seem to exist..."),
    ];

}

/// Serve the not implemented page.
Message[] serveNotImplemented(ref Context context) {

    with (Message)
    return [
        message(".."),
        addContent("Not Implemented", 1, Color.yellow),
        addContent("Unable to warp, the page is still being built! This portal will open soon..."),
    ];

}

// Serve an invalid token page.
Message[] serveInvalidToken(ref Context context) {

    import std.string : join;

    // TODO: add a resubmit button
    with (Message)
    return [
        setToken(context.user.actionToken),
        message(".."),

        addContent("Invalid token", 1, Color.yellow),
        addContent("Can't warp through a closed portal..."),
        addContent(),
        addContent("Your request verification token has expired, this may happen if you have the game open in multiple "
            ~ "tabs."),
        addContent("Return to the previous page and try again."),
        addLink("Go back", "/" ~ context.urlParts.join("/"), "back"),
    ];

}
