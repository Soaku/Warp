module warp.pages.api;

debug import std.stdio;
import std.concurrency;

import warp.main;
import warp.events;
import warp.server;
import warp.structs;
import warp.pages.error;

/// Change context to serve API responses, if requested.
///
/// The API may invoke an event listener, and if that's the case, this function will throw an exception, however, one
/// not meant to be caught.
void serveAPI(ref Context context) {

    if (context.param(0) != "api") return;

    // Remove the API param
    context.urlParts = context.urlParts[1..$];

    // Change content type
    context.response.contentType = "application/json";

    // If this is an event listener
    if (context.param(0) != "event") return;


    import std.concurrency : send;

    switch (context.param(1)) {

        case "worldgen":

            Context newContext = context;

            // Get the handler
            context.response.serverPass((handler) {

                // Add as a listener
                newContext.addListener(handler);

            });
            break;

        default:
            throw new StatusException("404 Not Found");

    }

}
