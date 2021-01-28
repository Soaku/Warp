/// Pages for controlling the world gen.
module warp.pages.worldgen;

import std.conv;
import std.format;
import std.concurrency;

import warp.main;
import warp.server;
import warp.worlds;
import warp.structs;
import warp.pages.error;

/// Serve world-gen related pages
Message[] serveWorldgen(ref Context context) {

    import std.conv, std.range, std.array;

    // Get the world type
    auto type = context.param(2);

    // None given, let the user pick
    if (type == "") return context.pickWorldType;

    // Check the type
    try return context.createWorld(type.to!(World.Type));

    // Failed, send 404.
    catch (ConvException) return context.serveNotFound;

}

/// Menu for picking world type
private Message[] pickWorldType(ref Context context) {

    with (Message)
    return [
        addLink("Back to world list", "/worlds", ""),
        addContent(),

        addContent("Pick world type", 1, Color.cyan),
        addLink("Regular", "/worlds/new/regular", "world-regular"),
    ];

}

/// Confirm world creation
private Message[] createWorld(ref Context context, World.Type worldType) {

    // Confirm world creation first
    if (context.method == Request.Method.get) {

        enum question = "Do you really want to create a new %s world?";

        with (Message)
        return [
            addContent(worldType.format!question, 1, Color.cyan),
            addLink("Cancel", "/worlds/new", "cancel"),
            addAction("Do it", "create", "confirm"),
        ];

    }

    // Confirmed
    else if (context.body.get("action", "") == "create") {

        // TODO limit to only one world in queue per user
        worldgen.send(worldType);

        with (Message)
        return [
            setTheme(Color.grey),

            clearContent(),
            addContent("Waiting in world generator queue..."),
            listen("worldgen"),

        ];

    }

    // Unknown request
    else with (Message)
    return [
        addContent("Invalid action type", 1, Color.cyan),
        addContent("Noclipping is dangerous. You don't want to end up in the backrooms, do you?"),
        addContent("Only use safe, certified portals, don't try to make your own, little hacker!"),
    ];

}
