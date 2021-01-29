/// Implementation of API event listeners.
module warp.events;

import std.range;
import std.typecons;

import warp.server;
import warp.structs;

debug {
    import std.stdio;
    import std.format;
}

alias Client = Tuple!(Context, "context", Handler, "handler");

// Active listeners
private Client[] listeners;

/// Add a new listener
void addListener(Context context, Handler handler) {

    listeners ~= Client(context, handler);

}

/// Send events to listeners if available
void updateListeners() {

    // TODO: Later, those sockets should probably still be selected by the server since they're still on the same
    // thread. This would be necessary to detect disconnects.

    /// Get each handler
    foreach_reverse (i, context, handler; listeners.enumerate) {

        import std.algorithm : remove;

        // Client disconnected
        if (!handler.socket.isAlive) {

            // Close the connection
            handler.socket.close();

            // Remove from list
            listeners = listeners.remove(i);

            continue;

        }

        // Get the stream name
        const stream = context.urlParts[1];

        // Check for queued messages
        auto messages = context.user.getEvents(stream);

        if (messages.length == 0) continue;

        assert(
            handler.response.contentType == "application/json",
            handler.response.contentType.format!"Wrong content type, %s"
        );

        import std.json : toJSON;

        // Send the messages
        const serialized = messages.serialize;
        handler.response.content = cast(ubyte[]) serialized.toJSON;
        handler.flush();
        handler.socket.close();

        // Remove from list
        listeners = listeners.remove(i);

    }

}
