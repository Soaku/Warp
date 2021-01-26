module warp.scripts;

import std.file;
import std.array;
import std.algorithm;

/// Generate the scripts needed for the client.
///
/// This is only done for debug executables.
debug
void generateScripts() {

    const mainScript = "source/warp/client"
        .dirEntries("*.js", SpanMode.depth)
        .map!(file => file.readText)
        .join;

    debug write("resources/main.js", "/* AUTOGENERATED */\n" ~ mainScript);

}
