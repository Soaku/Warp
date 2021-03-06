module warp.worlds.height;

import std.meta;

import warp.structs;
import warp.worlds.world;
import warp.worlds.worldgen;

/// Generate terrain height for the given world.
void generateHeight(WorldData worldData) {

    // Mountains
    updateStatus("Building mountains...");

    const summits = worldData.generateMountains;
    worldData.placeMountains(summits);

    // Noise
    updateStatus("Adding terrain noise...");

    worldData.heightNoise;

    // Send the resulting map
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
                angle += params.random(-30, 30, 100 + i*30 + j) * PI / 180;

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
private void placeMountains(shared World world, const WorldParams params, const Position[] summits) {

    import std.container : DList;

    uint seed = 160;

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

            // Get the average height
            const uint average = heightSum / neighborCount;

            // Set a chance to lower
            bool lower = params.random(1, 6, seed++) <= average;

            // Set the height as the average of neighbors minus 1
            area.height = max(1, average - lower);

        }

        // There are none, assume a summit
        else area.height = 12;

    }

}

/// Make the terrain height more random, generate hills, change summit height.
private void heightNoise(shared World world, const WorldParams params) {

    ubyte[100][2] mask;

    foreach (y; 0..100) {

        foreach (x; 0..100) {

            ubyte count, sum;

            // Get previous item in the row
            if (x != 0) {
                sum += mask[1][x - 1];
                count++;
            }

            // Get previous item in the column
            if (y != 0) {
                sum += mask[0][x];
                count++;
            }

            // Get previous item in diagonal
            if (count == 2) {
                sum += mask[0][x - 1];
                count++;
            }


            // Top-left corner
            if (count == 0) {

                mask[1][x] = cast(ubyte) params.random(1, 4, 200);

            }

            // Other cases
            else {

                import std.math : round;
                import std.algorithm : clamp;

                // Get the average of those neighbors
                const average = cast(int) round(cast(float) sum / count);

                // Get a random value
                const random = params.random(1, params.heightStability, 200 + y*100 + x);

                // Modify the result based on the value, 3 = increment, 1 = decrement
                const height = average + (random <= 3 ? random-2 : 0);

                // Get the final height
                mask[1][x] = cast(ubyte) clamp(height, 1, 4);

            }

            // Apply the mask
            world.areas[y][x].height = world.areas[y][x].height + mask[1][x];

        }

        // Shift rows
        mask[0] = mask[1];

    }

}
