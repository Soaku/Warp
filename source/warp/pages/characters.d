module warp.pages.characters;

import warp.structs;

/// Serve the character list.
Message[] serveCharacters(const Context) {

    with (Message)
    return [
        message,
        addContent("Your characters:", 1, Color.theme),
    ];

}
