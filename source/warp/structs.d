module warp.structs;

import std.conv;
import std.json;
import std.meta;
import std.array;
import std.typecons;
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
alias Position = Tuple!(uint, "x", uint, "y");

/// Type of the message sent
enum MessageType {

    /// Start a message with ID equal to the current request URL. Set the parent message by given ID, if not empty.
    /// `[string parent]`
    ///
    /// This opcode is used by the server to control buffer history to keep it clean.
    ///
    /// If this opcode is sent, all next content until the next message opcode should be added to this message, and all
    /// previous content should be erased, until it belongs to an ancestor of this message.
    ///
    /// If parent is set to `..`, the client should simply set the previous message as parent.
    message,

    /// Push new content text. `[ubyte level, ColoredText content]`, 0 = `<p>`, 1 = `<h1>`, n = `<hn>`.
    addContent,

    /// Add a link. Icon may be empty. `[string icon, string text, string href]`
    addLink,

    /// Add an "action" link using POST to be verified with a token. It should submit to the same page, but include
    /// the given text in the action parameter. Icon may be empty. `[string icon, string text, string action]`
    addAction,

    /// Update the token to use for POST requests.
    setToken,

    /// Change the current map mode. `[MapMode mapMode]`
    mapMode,
    // TODO

    /// Change text of a map line. `[ubyte lineNumber, ColoredText[] content]`
    ///
    /// This, along with other map commands, sends the map scaled (to 25x15) by default, unless visiting `/map` (TODO)
    mapLineContent,
    // TODO

    /// Change height of a map line. `[ubyte lineNumber, ubyte[] height]`
    mapLineHeight,
    // TODO

    /// Moved to a different area. `[string areaName]`
    changeArea,
    // TODO

    /// Set theme for this page. `[Color theme]`
    setTheme,

    /// Listen to events under given name. `[string name]`
    ///
    /// Make a TCP connection to `/api/events/<name>`, wait for response and evaluate given messages. If meant to
    /// be repeated, the server will send another `listen` opcode.
    listen,
    // TODO server needs to leave the client info telling them to connect.

}

/// Represents a message from the server to the client.
///
/// Considering changing the name to `Command`.
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

        /// Start a message
        static message(string message = "") {

            return Message(MessageType.message, message);

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

        /// Assign a new token
        static setToken(string token) {

            return Message(MessageType.setToken, token);

        }

    }

    // Map
    struct {

        /// Set map mode
        static mapMode(MapMode mode) {

            return Message(MessageType.mapMode, mode);

        }

        /// Change map line height
        static mapLineHeight(uint lineNumber, uint[] height) {

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
