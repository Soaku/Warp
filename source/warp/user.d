module warp.user;

import std.range;
import std.digest;
import std.algorithm;

import warp.structs;

/// Represents an user.
synchronized final class User {

    private {

        /// Data for login (service:userID). If empty, the user is anonymous.
        string loginData;

        /// Token to be used on the next POST request.
        string _actionToken;  // @dbExclude

        /// Messages queued on event streams.
        Message[][string] eventQueue;

    }

    this() {

        // Get an action token
        replaceActionToken();

    }

    // Action token related functions
    struct {

        /// Get the current action token.
        string actionToken() shared const {

            return _actionToken;

        }

        /// Check if the given token matches the current action token.
        bool verifyActionToken(string token) shared {

            // Verify them
            const result = _actionToken == token;

            // Get a new token
            replaceActionToken();

            return result;

        }

        /// Generate a new action token.
        private void replaceActionToken() shared {

            static import std.random;

            // Generate 4 random bytes for the token
            // It's small, but good enough for this case
            _actionToken = iota(4)
                .map!(a => cast(ubyte) std.random.uniform(0, 256))
                .array
                .toHexString;

        }

    }

    // Event queue
    struct {

        /// Send messages to the user's event queue.
        void sendEvent(string stream, Message[] messages...) {

            // The item exists
            if (auto p = stream in eventQueue) {

                // Append the messages
                *p ~= cast(shared) messages;

            }

            // Create the item
            else eventQueue[stream] = cast(shared) messages;

        }

        /// Fetch messages from given event queue
        Message[] getEvents(const string stream) {

            // Check if the stream exists
            if (auto p = stream in eventQueue) {

                // Clone the result
                auto messages = *p;

                // Clear the array
                *p = null;

                return cast(Message[]) messages;

            }

            // Return an empty array otherwise
            else return null;

        }

    }

}
