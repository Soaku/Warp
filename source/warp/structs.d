module warp.structs;

import std.conv;
import std.json;
import std.meta;
import std.array;
import std.algorithm;

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

    /// URL path has changed. [string path]
    changePath,

    /// Push new content text. [ubyte level, ColoredText content], 0 = `<p>`, 1 = `<h1>`.
    addContent,

    /// Change the user position on the map. [ubyte x, ubyte y]
    mapPosition,

    /// Change text of a map line. [ubyte lineNumber, ColoredText content x100]
    mapLineContent,

    /// Change height of a map line. [ubyte lineNumber, ubyte x100]
    mapLineHeight,

    /// Moved to a different area. [string areaName]
    changeArea,

    /// Change theme. [Color theme]
    changeTheme,

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

    string serialize() {

        auto arr = JSONValue([type.to!string].JSONValue ~ content);
        return arr.toJSON;

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
    static addContent(string text, ubyte level = 0, Color color = Color.white) {

        return Message(MessageType.addContent, level, color, text);

    }

    /// Change the theme
    static changeTheme(Color color) {

        return Message(MessageType.changeTheme, color);

    }

}

/// Context
struct Context {

    /// Parent request.
    Request request;

    /// Response data.
    Response* response;

    /// URL parts.
    string[] urlParts;

    /// Current theme.
    auto theme = Color.cyan;

    alias request this;

    this(Request request, ref Response response) {

        this.request = request;
        this.response = &response;
        this.urlParts = request.path.splitter("/").filter!(a => a != "").array;

    }

    /// Get a param from the URL, if exists, or return a default value.
    string param(size_t index, string def = null) const {

        return index < urlParts.length
            ? urlParts[index]
            : def;

    }

}
