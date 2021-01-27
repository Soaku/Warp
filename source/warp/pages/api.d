module warp.pages.api;

import warp.structs;

/// Change context to serve API responses, if requested.
void serveAPI(ref Context context) {

    if (context.param(0) != "api") return;

    // Remove the API param
    context.urlParts = context.urlParts[1..$];

    // Change content type
    context.response.contentType = "application/json";

}
