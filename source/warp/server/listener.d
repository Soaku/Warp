module warp.server.listener;

import std.conv;
import std.socket;
import std.algorithm;
import std.concurrency;

import warp.server.handler;
import warp.server.structs;

public import std.socket : InternetAddress;

// TODO: rewrite warp.server to a separate library

void start(ServerOptions options) {

    /// Start the server
    auto listener = new TcpSocket;
    listener.blocking = false;
    listener.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, true);
    listener.bind(options.address);
    listener.listen(100);
    scope (exit) listener.close();

    /// Active connections
    Handler[] connections;

    // Create a socket set
    auto socketSet = new SocketSet;
    while (true) {

        // Reset the set
        socketSet.reset();

        // Add the connections
        socketSet.add(listener);
        foreach_reverse (i, ref connection; connections) {

            // Check the status of the socket
            if (connection.socket.isAlive) {

                socketSet.add(connection.socket);

            }

            // The socket died, remove it from the list
            else connections = connections.remove(i);

        }

        // Check for updates
        auto ret = Socket.select(socketSet, null, null, options.refreshTimeout);

        // Run the frames if there is a callback
        if (options.frameCallback) options.frameCallback();

        // Update existing connections
        if (ret > 0)
        foreach_reverse (i, ref connection; connections) {

            // Wait for data
            if (!socketSet.isSet(connection.socket)) continue;

            import std.stdio : writeln;

            // Fetch further data
            try connection.fetch();

            // Handle released
            catch (HandleReleaseException exc) {

                // Run the callback
                exc.callback(connection);

                // Release handle
                connections = connections.remove(i);

            }

            // If failed, write the exception content
            catch (Exception exc) writeln(exc);

        }

        // Check for new connections
        if (!socketSet.isSet(listener)) continue;

        // There are
        auto socket = listener.accept();
        connections ~= new Handler(options, socket);

    }

}
