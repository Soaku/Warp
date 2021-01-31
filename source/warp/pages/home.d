module warp.pages.home;

import warp.structs;

/// Serve the home page
Message[] serveHome(const Context) {

    with (Message)
    return [
        message,
        addContent("Welcome to WARP...", 1, Color.theme),
        addContent("Explore, fight, interact with others and WARP between worlds."),
    ];

}
