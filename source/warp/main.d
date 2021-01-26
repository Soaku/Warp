module warp.main;

import elemi;
import std.conv;

import warp.html;
import warp.pages;
import warp.server;
import warp.scripts;
import warp.structs;
import warp.file_sender;

void main(string[] argv) {

    // Get the connection port
    const port = argv.length > 1 ? argv[1].to!ushort : 8080;

    // Generate scripts
    debug generateScripts();

    // Prepare the server
    ServerOptions server = {

        address: new InternetAddress("127.0.0.1", port),

        handler: (request, ref response) {

            response.addHeader("Server", "wrap/1.0");

            // Serve files in debug
            debug if (fileSender(request, response)) return;

            // Create context
            auto context = Context(request, response);
            auto messages = context.route();

            // Write the content
            response.content = cast(ubyte[]) response.htmlTemplate(messages.display);
        }

    };

    server.start();

}
