module warp.worlds.height;

import std.meta;

import warp.structs;
import warp.worlds.world;
import warp.worlds.worldgen;

/// Generate terrain height for the given world.
void generateHeight(WorldData worldData) {

    updateStatus("Building mountains...");

    auto summits = worldData.generateMountains;
    worldData.placeMountains(summits);

    updateStatus("Adding terrain noise...");

    //worldData.heightNoise — make the terrain height more random, generate hills, change summit height.

    updateStatus(worldData[0].heightAPI);

}

/// Generate mountains from world data. They won't be placed in the world yet.
/// Returns: List of summits.
private Position[] generateMountains(shared World world, const WorldParams params) {

    Position[] result;

    // Place the mountain
    foreach (i, summits; params.mountains) {

        import std.math : PI, sin, cos;

        Position lastPosition;
        auto angle = params.random(0, 359, 100 + i*30) * PI / 180;

        // Create summits
        foreach (j; 0 .. summits) {

            // First summit
            if (j == 0) {

                // Get a random position
                lastPosition = Position(
                    params.random(0, 99, 100 + i),
                    params.random(0, 99, 120 + i),
                );

                result ~= lastPosition;


            }

            // Other summits
            else {

                import std.conv : to;

                // Change the angle
                angle += params.random(-5, 5, 100 + i*30 + j) * PI / 180;

                // Generate random distance
                const range = params.summitDistance;
                const distance = params.random(range[0], range[1], 125 + i*30 + j).to!float;

                // Get the position
                const positionX = to!int(lastPosition.x.to!int + angle.sin*distance);
                const positionY = to!int(lastPosition.y.to!int + angle.cos*distance);

                // If either is out of bounds, end this mountain
                if (positionX < 0 || 99 < positionX) break;
                if (positionY < 0 || 99 < positionY) break;

                // Set the new position
                lastPosition = Position(positionX.to!uint, positionY.to!uint);
                result ~= lastPosition;

            }

        }

    }

    return result;

}

/// Place mountains from list of summits.
///
/// This function doesn't use any randomness.
private void placeMountains(shared World world, const WorldParams params, Position[] summits) {

    import std.container : DList;

    // Add each summit to the queue
    auto queue = DList!Position(summits);

    /// Iterate on the queue
    while (!queue.empty) {

        auto position = queue.front;
        queue.removeFront;

        // Get this area
        auto area = &world.areaAt(position);

        // Skip this area if it was already checked
        if (area.height != 0) continue;

        // Get the neighbors
        uint heightSum;
        uint neighborCount;
        foreach (i; 0..4) {

            // Get the neighbor
            Position neighbor;
            try neighbor = world.neighbor(position, i);

            // Skip if out of bounds
            catch (Exception) continue;

            // Queue this neighbor
            queue.insertBack(neighbor);

            // Get the area
            auto neighborArea = &world.areaAt(neighbor);

            // Ignore the rest if the neighbor wasn't checked
            if (neighborArea.height == 0) continue;

            heightSum += neighborArea.height;
            neighborCount += 1;

        }

        // If there are neighbors
        if (neighborCount) {

            import std.algorithm : max;

            // Set the height as the average of neighbors minus 1
            area.height = max(1, heightSum / neighborCount - 1);

        }

        // There are none, assume a summit
        else area.height = 12;

    }

}
