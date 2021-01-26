module warp.pages.characters;

import warp.structs;

/// Serve the character list.
Message[] serveCharacters(const Context) {

    return [
        Message.addContent("Your characters:", 1, Color.theme),
    ];

}
