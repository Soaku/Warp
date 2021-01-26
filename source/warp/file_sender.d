module warp.file_sender;

import warp.server.structs;

/// Send requested files. Debug only.
/// Returns: true if a file was loaded into content.
debug
bool fileSender(Request request, ref Response response) {

    import std.file : exists, read, isFile;
    import std.string : stripLeft;

    const path = request.path.stripLeft("/");

    // Serve files in debug
    if (path.exists && path.isFile) {

        import std.path : extension;

        immutable mimes = [
            ".css": "text/css",
            ".js": "application/javascript",
        ];

        response.contentType = mimes.get(path.extension, "application/octet-stream");
        response.content = cast(ubyte[]) path.read;

        return true;

    }

    return false;

}
