module warp.pages.home;

import warp.structs;

/// Serve the home page
Message[] serveHome(const Context) {

    return [
        Message.addContent("Welcome to WARP...", 1, Color.theme),
        Message.addContent("Explore, fight, interact with others and WARP between worlds."),
    ];

}
