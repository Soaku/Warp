module warp.worlds.params;

import warp.structs;

/// Parameters for world creation.
struct WorldParams {

    /// Seed for this world
    ulong seed;

    /// Number of mountains in the world and the amount of summits per each.
    ///
    /// Those values will only be used for generating height, the actual mountains generated later might not match this
    /// value.
    size_t[] mountains;

    /// Min and max distance between summits of a single mountain.
    size_t[2] summitDistance;

    /// Get a random number in range
    T random(T)(T min, T max, ulong seedOffset) const {

        static import std.random;

        auto rng = std.random.Mt19937_64(seed + seedOffset);
        return std.random.uniform!"[]"(min, max, rng);

    }

}
