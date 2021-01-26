module warp.home;

import warp.server;
import warp.structs;

/// Serve the home page
Message[] serveHome(const Request) {

    return [
        Message(MessageType.addContent, 1, "Welcome to WARP..."),
        Message(MessageType.addContent, 0, "Explore, fight, interact with others and WARP between worlds."),
    ];

}
