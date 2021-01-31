module warp.server.structs;

import core.time;
import std.socket;
import std.exception;

import warp.server.handler;

class StatusException : Exception {

    mixin basicExceptionCtors;

}

package class HandleReleaseException : Exception {

    alias ServerCallback = void delegate(Handler);

    ServerCallback callback;

    this(ServerCallback callback) {

        super("");
        this.callback = callback;

    }

}

/// Options of the server
struct ServerOptions {

    /// Address of the server.
    InternetAddress address;

    /// Data refresh timeout. This is the minimal time to pass between frame callbacks.
    Duration refreshTimeout;

    /// Request handler.
    void delegate(Request, ref Response) handler;

    /// Callback to run after every data refresh in order to perform asynchronous operations on the server thread.
    /// Useful for managing handles passed through `Response.serverPass`.
    void delegate() frameCallback;

}

struct Request {

    /// Represents current request method
    enum Method {

        invalid,
        get,
        post,
        head,

    }

    /// Used request method.
    Method method;

    /// Requested path
    string path;

    /// Headers attached to the request. Names are lowercase.
    string[string] headers;

    /// Body of the request
    string[string] body;

}

struct Response {

    /// Status of the response.
    string status = "200 OK";

    /// Response title.
    string title;

    /// Mimetype of the content.
    string contentType = "text/html";

    /// Other headers not served by the library. All must end with a LF. Use `addHeader` to safely add new ones.
    string headers;

    /// Content text.
    ubyte[] content;

    /// Handler for this reponse.
    private Handler handler;

    /// If true, the response should be automatically flushed once the handler callback returns.
    ///
    /// Use delayResponse to control this behavior.
    bool autoflush = true;

    this(Handler handler) {

        this.handler = handler;

    }

    void addHeader(string key, string value) {

        import std.conv : text;

        headers ~= text(key, ": ", value, "\n");

    }

    /// Prevent the server from automatically flushing the content, in order to respond to the socket later.
    ///
    /// Provides a `Handler` object to manage the connection. Use `Handler.flush` to send the data and
    /// `Handler.socket.close` to close the socket after.
    ///
    /// The server will automatically close the socket if the client disconnects. Check `Handler.socket.isAlive`
    Handler delay() {

        autoflush = false;
        return handler;

    }

}
