module warp.pages.not_found;

import warp.structs;

/// Serve the 404 page
Message[] serveNotFound(ref Context context) {

    context.response.status = "404 Not Found";

    return [
        Message.addContent("404 Not Found", 1, Color.red),
        Message.addContent("We cannot warp to this page, it doesn't seem to exist..."),
    ];

}

/// Serve the page
Message[] serveNotImplemented(ref Context context) {

    return [
        Message.addContent("Not Implemented", 1, Color.yellow),
        Message.addContent("Unable to warp, the page is still being built! This portal will open soon..."),
    ];

}
