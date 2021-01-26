module warp.pages;

import warp.structs;
import warp.server.structs;

public {

    import warp.pages.home;
    import warp.pages.not_found;
    import warp.pages.characters;

}

Message[] route(ref Context context) {

    switch (context.param(0)) {

        case null: return context.serveHome;
        case "characters": return context.serveCharacters;

        // Not found
        default: return context.serveNotFound;


    }

}
