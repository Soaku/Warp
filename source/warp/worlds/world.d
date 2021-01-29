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

    /// Owner of the world.
    User owner;

}
