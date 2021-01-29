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

    /// Content text
    ubyte[] content;

    void addHeader(string key, string value) {

        import std.conv : text;

        headers ~= text(key, ": ", value, "\n");

    }

    /// Release this socket's `Handle` from the server's control and pass it to the given function as a shared object.
    ///
    /// This function ALWAYS throws, the exception is not meant to be caught, however.
    void serverPass(HandleReleaseException.ServerCallback callback) {

        throw new HandleReleaseException(callback);

    }

}
