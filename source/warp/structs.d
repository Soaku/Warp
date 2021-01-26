module warp.structs;

import std.conv;
import std.json;
import std.meta;

enum Color {

    white,
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
    pathChange,

    /// Push new content text. [ubyte level, ColoredText content], 0 = `<p>`, 1 = `<h1>`.
    addContent,

    /// Change the user position on the map. [ubyte x, ubyte y]
    mapPosition,

    /// Change text of a map line. [ubyte lineNumber, ColoredText content x100]
    mapLineContent,

    /// Change height of a map line. [ubyte lineNumber, ubyte x100]
    mapLineHeight,

    /// Moved to a different area. [string areaName]
    areaChange,

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

            assert(Message(pathChange, "/").serialize == `["pathChange","\/"]`);
            assert(Message(addContent, 0, "Hello, World!").serialize == `["addContent",0,"Hello, World!"]`);


        }

    }

}
