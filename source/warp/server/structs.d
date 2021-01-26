module warp.server.structs;

import elemi;

import std.socket;
import std.exception;

class StatusException : Exception {

    mixin basicExceptionCtors;

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

}
