module warp.main;

import elemi;
import std.conv;

import warp.server;
import warp.file_sender;
import warp.html_template;

void main(string[] argv) {

    // Get the connection port
    const port = argv.length > 1 ? argv[1].to!ushort : 8080;

    ServerOptions server = {

        address: new InternetAddress("127.0.0.1", port),

        handler: (request, ref response) {

            response.addHeader("Server", "wrap/1.0");

            // Server files in debug
            debug if (fileSender(request, response)) return;

            import std.stdio : writeln;
            writeln(request.method, " ", request.path);

            auto body = elem!"p"(

                "Hello, World!"

            );


            // Write the content
            response.content = cast(ubyte[]) response.htmlTemplate(body);
        }

    };

    server.start();

}
