module warp.worlds.world;

import std.typecons;

import warp.user;
import warp.structs;
import warp.worlds.params;

/// Represents a world
shared final class World {

    enum Type {
        regular
    }

    /// Name of the world (reserved).
    string name;

    /// Type of this world.
    Type type;

    /// Owner of the world.
    User owner;

}
