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

    /// Areas of the world.
    Area[100][100] areas;

    /// Get area at position
    ref shared(inout(Area)) areaAt(Position position) inout {

        return areas[position.y][position.x];

    }

    /// Get neighbor of area.
    /// Params:
    ///     position = Position to check
    ///     direction = Side the neighbor is located on, 0 top, 1 right, 2 bottom, 3 left.
    /// Returns: Position of the neighbor.
    /// Throws: `Exception` if the requested neighbor is out of bounds.
    Position neighbor(Position position, uint direction) const
    in (direction < 4, "neighbor only supports 4 directions")
    do {

        import std.conv : to;

        auto posX = position.x.to!int, posY = position.y.to!int;
        final switch (direction) {

            case 0:
                posY -= 1;
                break;
            case 1:
                posX += 1;
                break;
            case 2:
                posY += 1;
                break;
            case 3:
                posX -= 1;
                break;

        }

        // Check bounds
        if (posX < 0 || 99 < posX || posY < 0 || 99 < posY) {

            throw new Exception("Neighbor out of bounds");

        }

        return Position(posX, posY);

    }

    /// Get all API messages for the height map, scaled to 25x15.
    Message[] heightAPI() {

        enum mapHeight = areas.length;
        enum chunkLength = mapHeight / 15;

        Message[] messages;

        for (uint i = 0; i < mapHeight; i += chunkLength) {

            messages ~= rowHeightAPI(i);

        }

        return messages;

    }

    /// Get row height as an API message, scaled to 25:100.
    Message rowHeightAPI(uint row) {

        import std.json : JSONValue;

        enum mapWidth = areas[row].length;
        enum chunkLength = mapWidth / 25;

        auto msg = Message(MessageType.mapLineHeight);
        for (uint i = 0; i < mapWidth; i += chunkLength) {

            msg.content ~= JSONValue(areas[row][i].height);

        }

        return msg;

    }

}

/// Represents an area in the world
struct Area {

    /// Height of the area, 1–16
    uint height;

    /// Temperature of the area, 1–16.
    uint temperature;

    /// Region this area belongs to.
    Region region;

}

/// Represents a region in the world
shared class Region {

    /// Name of this region.
    string name;

    /// Biome name.
    string biome;

    /// Area of the region
    size_t area;

}
