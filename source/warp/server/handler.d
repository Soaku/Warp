module warp.server.handler;

import std.conv;
import std.socket;
import std.format;

import warp.server.structs;

/// Represents a client request.
class Handler {

    private enum Phase {

        method,
        headers,
        body

    }

    /// Options of the server.
    ServerOptions options;

    /// The socket.
    Socket socket;

    /// User request.
    Request request;

    /// Server response.
    Response response;

    private {

        /// Current parsing phase.
        Phase phase;

        /// Current line
        string line;

        /// Remaining POST content length
        size_t contentLeft;

    }

    this(ServerOptions options, Socket socket) {

        this.options = options;
        this.socket = socket;

    }

    /// Fetch new data from the client.
    void fetch() {

        try {

            string content;

            // Read content
            while (true) {

                immutable bufferSize = 1024;

                char[bufferSize] data;
                const dataSent = socket.receive(data);

                // Check status
                switch (dataSent) {

                    // Connection closed
                    case Socket.ERROR:
                    case 0:
                        socket.close();
                        break;

                    // Receiving data
                    default:

                        // Get a string
                        content ~= data[0 .. dataSent].to!string;


                }

                if (dataSent != bufferSize) break;

            }

            // While there is content to process
            while (content.length) {

                import std.algorithm : findSplit;

                // If this is the body phase
                if (phase == Phase.body) {

                    line ~= content;

                    // Submitted all
                    if (content.length >= contentLeft) parseLine();

                    // Still waiting for content
                    else contentLeft -= content.length;

                    return;


                }

                // Find the split
                if (auto split = content.findSplit("\n")) {

                    // Get this line and parse it
                    line ~= split[0];
                    parseLine();

                    // Clear the line
                    line = "";

                    // Advance the content
                    content = split[2];

                }

                // Not found
                else {

                    // Append to this line
                    line ~= content;
                    continue;

                }

            }

        }

        // Handle status code exceptions
        catch (StatusException status) {

            response.status = status.msg;
            response.content = cast(ubyte[]) status.msg;
            flush();

        }

        // Release exception, rethrow
        catch (HandleReleaseException exception) throw exception;

        // Handle other exceptions
        catch (Exception exception) {

            response.status = "500 Server Error";
            response.content = cast(ubyte[]) "500 Server Error";
            flush();

            // Rethrow the exception
            throw exception;

        }

    }

    /// Generate a response for the request and flush afterwards.
    void respond() {

        if (options.handler) options.handler(request, response);
        flush();

    }

    /// Send the response. Will reset the current request/response data.
    void flush() {

        import std.algorithm : startsWith;

        const contentGiven = response.content.length;

        // If there was no content given
        if (!contentGiven && response.status.startsWith("200")) {

            response.status = "204 No Content";

        }

        // Head
        socket.send(response.status.format!"HTTP/1.1 %s\n");
        socket.send(response.headers);

        // Content
        if (contentGiven) {

            // Add headers
            socket.send(
                response.content.length.format!"Content-Length: %s\n"
                ~ response.contentType.format!"Content-Type: %s\n"
                ~ "Content-Language: en-US\n"
                ~ "\n"
            );

            // Send the content
            socket.send(response.content);

        }

        // End the head
        else socket.send("\n");

        // Create new data
        resetData();

    }

    /// Parse the current line
    private void parseLine() {

        import std.string : toLower, stripLeft;
        import std.exception : enforce;

        final switch (phase) {

            // First line
            case Phase.method: {

                // Make the line lowercase
                line = line.toLower;

                // Request method
                {

                    import std.algorithm : skipOver;

                    // Remove space
                    line = line.stripLeft;

                    // Get the method
                    request.method = line.skipOver("get") ? Request.Method.get
                        : line.skipOver("post") ? Request.Method.post
                        : line.skipOver("head") ? Request.Method.head
                        : Request.Method.invalid;

                    // Require it to be valid
                    enforce!StatusException(request.method != Request.Method.invalid, "501 Not Implemented");
                    // 405 implies the server knows the method, but there doesn't seem to be any better alternative

                }

                // Read request path
                {

                    import std.algorithm : until;

                    // Remove space
                    line = line.stripLeft;

                    // Set the path
                    request.path = line.until(" ").to!string;

                }

                // Change phase
                phase = Phase.headers;

                // Ignore the rest, we don't care for now
                break;

           }

            // Headers
            case Phase.headers: {

                import std.algorithm : until;
                import std.string : strip, stripRight;

                line = line.strip;

                // If the line is empty
                if (line == "") {

                    // Advance stage
                    phase = Phase.body;
                    try contentLeft = request.headers.get("content-length", "0").to!size_t;

                    // bruh
                    catch (ConvException) throw new StatusException("400 Bad Request");

                    // No content was sent, respond
                    if (contentLeft == 0) respond();

                    break;

                }

                const key = line.until(":").to!string.toLower.stripRight;
                const value = line[key.length+1 .. $].stripLeft;

                request.headers[key] = value;
                break;

            }

            case Phase.body: {

                string key, value;
                bool parsingValue;

                void submitPair() {

                    import std.uri : decodeComponent;

                    // Ignore if there's no key
                    if (key == "") return;

                    // Add the data
                    request.body[key.decodeComponent] = value.decodeComponent;

                    key = value = "";
                    parsingValue = false;

                }

                // Check each character on the line
                foreach (ch; line) {

                    switch (ch) {

                        // Begin value
                        case '=':
                            parsingValue = true;
                            break;

                        // Submit pair
                        case '&':
                            submitPair();
                            break;

                        // Other characters
                        default:

                            // Add the character
                            if (parsingValue) value ~= ch;
                            else key ~= ch;

                    }

                }

                // Submit the content
                submitPair();

                // Respond now
                respond();

                break;

            }

        }

    }

    private void resetData() {

        request = Request();
        response = Response();
        phase = Phase.method;
        line = "";

    }

}
