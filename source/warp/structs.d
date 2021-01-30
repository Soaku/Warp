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
    grey,
    red,
    green,
    yellow,
    blue,
    magenta,
    cyan,

}

enum MapMode {

    portal,
    warping,
    terrain,
    political,

}

alias ColoredText = AliasSeq!(Color, string);

/// Type of the message sent
enum MessageType {

    /// Clear the content.
    clearContent,
    // TODO

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

    /// Change the current map mode. `[MapMode mapMode]`
    mapMode,

    /// Change the user position on the map. `[ubyte x, ubyte y]`
    /// If not present, map should be zoomed out.
    mapPosition,
    // TODO

    /// Change text of a map line. `[ubyte lineNumber, ColoredText[100] content]`
    mapLineContent,
    // TODO

    /// Change height of a map line. `[ubyte lineNumber, ubyte[100] height]`
    mapLineHeight,
    // TODO

    /// Moved to a different area. If the area name is empty, return to splash. `[string areaName]`
    changeArea,
    // TODO

    /// Set theme for this page. `[Color theme]`
    setTheme,
    // Implemented: server (yes); TODO client

    /// Listen to events under given name. `[string name]`
    ///
    /// Make a TCP connection to `/api/events/<name>`, wait for response and evaluate given messages. Repeat until
    /// the same opcode is sent with an empty name.
    listen,
    // Implemented: server (partial, via <noscript>), TODO client
    // server needs to leave the client info telling them to connect.

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

    // Main content
    struct {

        /// Clear the content
        static clearContent() {

            return Message(MessageType.clearContent);

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

    }

    // Map
    struct {

        /// Set map mode
        static mapMode(MapMode mode) {

            return Message(MessageType.mapMode, mode);

        }

        /// Change map line height
        ///
        /// Line number is `0..100`, height[n] is `1..11`
        static mapLineHeight(ubyte lineNumber, ubyte[] height)
        in (height.length == 100)
        do {

            return Message(MessageType.mapLineHeight, lineNumber, height);

        }

    }

    /// Change the theme
    static setTheme(Color color) {

        return Message(MessageType.setTheme, color);

    }

    /// Listen to an event provider
    static listen(string name) {

        return Message(MessageType.listen, name);

    }

}

/// Serialize a message list
JSONValue serialize(Message[] messageList) {

    return messageList
        .map!(a => a.serialize)
        .array
        .JSONValue;

}

/// Context
struct Context {

    // TODO: proper login
    static shared User globalUser;

    /// Parent request.
    Request request;

    /// Response data.
    Response* response;

    /// User to perform the request.
    shared User user;

    /// URL parts.
    string[] urlParts;

    /// Current theme.
    auto theme = Color.cyan;

    alias request this;

    static this() {

        globalUser = new shared User;

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
