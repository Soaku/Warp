module warp.worlds.height;

import std.meta;

import warp.structs;
import warp.worlds.worldgen;

/// Generate terrain height for the given world.
void generateHeight(WorldData worldData) {

    worldData.generateMountains;

}

void generateMountains(shared World world, const WorldParams params) {

    updateStatus("Building mountains...");

    // Place the mountain
    foreach (i, mountain; params.mountains) {

        // Create summits
        foreach (j; 0 .. i) {

            // Get a random position
            auto position = Position(
                params.random(0, 99, params.seed + 100 + i),
                params.random(0, 99, params.seed + 120 + i),
            );

        }

    }

}
