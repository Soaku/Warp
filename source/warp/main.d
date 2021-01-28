module warp.main;

import elemi;
import std.conv;
import std.concurrency;

import warp.html;
import warp.server;
import warp.handle;
import warp.scripts;
import warp.structs;
import warp.file_sender;
import warp.worlds.worldgen;

static {

    Tid worldgen;

}

void main(string[] argv) {

    // Get the connection port
    const port = argv.length > 1 ? argv[1].to!ushort : 8080;

    // Generate scripts
    debug generateScripts();

    // Start secondary threads
    worldgen = spawn(&startWorldgen);

    // Prepare the server
    ServerOptions server = {

        address: new InternetAddress("127.0.0.1", port),

        handler: (request, ref response) {

            response.addHeader("Server", "warp/1.0");

            // Serve files in debug
            debug if (fileSender(request, response)) return;

            // Create context
            auto context = Context(request, response);
            auto messages = context.serve();

            // If responding with HTML
            if (context.response.contentType == "text/html") {

                auto api = APIData(context, messages);

                // Write the content
                response.content = cast(ubyte[]) context.htmlTemplate(api);

            }

            // Responding with JSON
            else if (context.response.contentType == "application/json") {

                import std.json : JSONValue, toJSON;
                import std.array : array;
                import std.algorithm : map;

                auto json = messages
                    .map!(a => a.serialize)
                    .array
                    .JSONValue;

                response.content = cast(ubyte[]) json.toJSON;

            }

        }

    };

    server.start();

}
