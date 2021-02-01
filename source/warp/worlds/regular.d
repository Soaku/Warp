module warp.worlds.regular;

import std.random;

import warp.worlds.params;

WorldParams regularWorld(ulong seed) {

    // Create the struct
    WorldParams params;
    params.seed = seed;

    // Get mountains
    foreach (i; 0 .. params.random(1, 2, seed)) {

        params.mountains ~= params.random(1, 3, seed + 1);

    }

    return params;

}
