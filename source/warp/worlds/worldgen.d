module warp.worlds.worldgen;

import std.stdio;
import std.format;
import std.concurrency;

import warp.server;
import warp.structs;
import warp.worlds.world;

public {

    import warp.main : worldgen;
    import std.concurrency : send;

}

/// Start the worldgen thread
void startWorldgen() {

    while (true) {

        // Receive messages
        receive(

            // Order world creation
            (World.Type type) {
                debug type.format!"worldgen: new task, create world %s".writeln;
            },

            // Request status update
            (shared Context context, shared Handler handlerSh) {
                debug "worldgen: requested status update".writeln;

                auto handler = cast() handlerSh;
                handler.flush();
                handler.socket.close();
            },

        );


    }

}
