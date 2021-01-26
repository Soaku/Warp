module warp.pages.not_found;

import warp.structs;

/// Serve the 404 page
Message[] serveNotFound(Context context) {

    context.response.status = "404 Not Found";

    return [
        Message.addContent("404 Not Found", 1, Color.red),
        Message.addContent("We cannot warp to this page, it doesn't seem to exist..."),
    ];

}
