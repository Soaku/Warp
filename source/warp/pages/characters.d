module warp.pages.characters;

import warp.structs;

/// Serve the character list.
Message[] serveCharacters(const Context) {

    return [
        Message.clearContent,
        Message.addContent("Your characters:", 1, Color.theme),
    ];

}
