module warp.worlds.regular;

import std.random;

import warp.worlds.params;

WorldParams regularWorld(ulong seed) {

    // Create the struct
    WorldParams params;
    params.seed = seed;

    // Get mountains
    params.summitDistance = [8, 12];
    foreach (i; 0 .. params.random(1, 2, 0)) {

        params.mountains ~= params.random(2, 8, i);

    }

    return params;

}
