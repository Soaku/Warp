module warp.worlds.world;

import warp.user;

/// Represents a world
shared final class World {

    enum Type {
        regular
    }

    /// Name of the world (reserved).
    string name;

    /// Type of this world.
    Type type;

    /// World seed
    ulong seed;

    /// Owner of the world.
    User owner;

}
