module warp.worlds.params;

import warp.structs;

/// Parameters for world creation.
struct WorldParams {

    /// Seed for this world
    ulong seed;

    /// Number of mountains in the world and the amount of summits per each.
    size_t[] mountains;

    /// Get a random number in range
    T random(T)(T min, T max, ulong seed) const {

        static import std.random;

        auto rng = std.random.Mt19937_64(seed);
        return std.random.uniform!"[]"(min, max, rng);

    }

}
