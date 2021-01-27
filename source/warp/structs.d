module warp.structs;

import std.conv;
import std.json;
import std.meta;
import std.array;
import std.algorithm;

import warp.user;
import warp.server.structs;

enum Color {

    white,
    theme,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,

}

alias ColoredText = AliasSeq!(Color, string);

/// Type of the message sent
enum MessageType {

    /// Push new content text. `[ubyte level, ColoredText content]`, 0 = `<p>`, 1 = `<h1>`, n = `<hn>`.
    addContent,
    // Implemented: server (yes); TODO client

    /// Add a link. Icon may be empty. `[string icon, string text, string href]`
    addLink,
    // Implemented: server (yes); TODO client

    /// Add an "action" link using POST to be verified with a token. It should submit to the same page, but include
    /// the given text in the action parameter. Icon may be empty. `[string icon, string text, string action]`
    addAction,
    // Implemented: server (yes); TODO client

    /// Change the user position on the map. `[ubyte x, ubyte y]`
    mapPosition,
    // TODO

    /// Change text of a map line. `[ubyte lineNumber, ColoredText content x100]`
    mapLineContent,
    // TODO

    /// Change height of a map line. `[ubyte lineNumber, ubyte x100]`
    mapLineHeight,
    // TODO

    /// Moved to a different area. `[string areaName]`
    changeArea,
    // TODO

    /// Change theme. `[Color theme]`
    changeTheme,
    // Implemented: server (yes); TODO client

}

/// Represents a message from the server to the client.
struct Message {

    /// Type of the message
    MessageType type;

    /// Message content
    JSONValue[] content;

    this(T...)(MessageType type, T args) {

        import std.algorithm : map;

        this.type = type;

        foreach (item; args) {

            content ~= JSONValue(item);

        }

    }

    JSONValue serialize() {

        return JSONValue([type.to!string].JSONValue ~ content);

    }

    unittest {

        with (MessageType) {

            import std.stdio;

            assert(Message(pathChange, "/").serialize
                == `["pathChange","\/"]`);
            assert(Message.addContent("Hello, World!").serialize
                == `["addContent",0,0,"Hello, World!"]`);


        }

    }

    /// Create a content message
    static addContent(string text = "", ubyte level = 0, Color color = Color.white) {

        return Message(MessageType.addContent, level, color, text);

    }

    /// Create a link
    static addLink(string text, string href, string icon = null) {

        return Message(MessageType.addLink, icon, text, href);

    }

    /// Create an action link
    static addAction(string text, string action, string icon = null) {

        return Message(MessageType.addAction, icon, text, action);

    }

    /// Change the theme
    static changeTheme(Color color) {

        return Message(MessageType.changeTheme, color);

    }

}

/// Context
struct Context {

    // TODO: proper login
    static User globalUser;

    /// Parent request.
    Request request;

    /// Response data.
    Response* response;

    /// User to perform the request.
    User user;

    /// URL parts.
    string[] urlParts;

    /// Current theme.
    auto theme = Color.cyan;

    alias request this;

    static this() {

        globalUser = new User;

    }

    this(Request request, ref Response response) {

        // Get the params
        this.request = request;
        this.response = &response;
        this.urlParts = request.path.splitter("/").filter!(a => a != "").array;

        // Check the user
        user = globalUser;

    }

    /// Get a param from the URL, if exists, or return a default value.
    string param(size_t index, string def = null) const {

        return index < urlParts.length
            ? urlParts[index]
            : def;

    }

}
