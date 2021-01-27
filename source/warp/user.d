module warp.user;

import std.range;
import std.digest;
import std.algorithm;

/// Represents an user.
class User {

    /// Data for login. If empty, the user is anonymous.
    string loginData;

    /// Token to be used on the next POST request.
    string actionToken;

    this() {

        // Get an action token
        replaceActionToken();

    }

    /// Check if the given token matches the current action token.
    bool verifyActionToken(string token) {

        // Verify them
        const result = actionToken == token;

        // Get a new token
        replaceActionToken();

        return result;

    }

    /// Generate a new action token.
    private void replaceActionToken() {

        static import std.random;

        // Generate 4 random bytes for the token
        // It's small, but good enough for this case
        actionToken = iota(4)
            .map!(a => cast(ubyte) std.random.uniform(0, 256))
            .array
            .toHexString;

    }

}
