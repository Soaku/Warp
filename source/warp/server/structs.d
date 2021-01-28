module warp.server.structs;

import std.socket;
import std.exception;

import warp.server.handler;

class StatusException : Exception {

    mixin basicExceptionCtors;

}

package class HandleReleaseException : Exception {

    alias ServerCallback = void delegate(shared Handler);

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

    /// Request handler.
    void delegate(Request, ref Response) handler;

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

    /// Other headers not served by the library. All must end with a LF.
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
