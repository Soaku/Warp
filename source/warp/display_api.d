module warp.display_api;

import elemi;
import std.conv;

import warp.structs;

private struct MapParts {

    /// Position on the map.
    ubyte[2] mapPosition;

    /// Parts of the height map.
    Message*[100] heightMap;

    /// Parts of the content map
    Message*[100] contentMap;

}

/// Data from the API
struct APIData {

    /// Body of the message.
    Element body;

    /// Parts of the map.
    MapParts* mapParts;

    /// Read data from the API to read.
    this(ref Context context, Message[] messages) {

        // Check each message
        foreach (message; messages) {

            switch (message.type) {

                // Add content
                case MessageType.addContent: {

                    auto color = message.content[1].get!Color;
                    auto attributes = ["class": to!string(color == Color.theme ? context.theme : color)];

                    sw: final switch (message.content[0].get!int) {

                        static foreach (i, el; ["p", "h1", "h2", "h3", "h4", "h5", "h6"]) {

                            case i:
                                body.add(

                                    elem!el(
                                        attributes,
                                        message.content[2].str,
                                    )

                                );
                                break sw;

                        }

                    }

                    break;

                }

                // Add link
                case MessageType.addLink: {

                    auto link = elem!"a"(
                        [
                            "class": "box-link",
                            "title": message.content[1].str,
                            "href": message.content[2].str,
                        ],
                    );

                    link.addBoxContent(message.content[0].str, message.content[1].str);

                    // Add the link
                    body.add(link);

                    break;

                }

                // Action button
                case MessageType.addAction: {

                    auto link = elem!"button"(
                        [
                            "class": "box-link",
                            "name": "action",
                            "value": message.content[2].str,
                        ]
                    );
                    link.addBoxContent(message.content[0].str, message.content[1].str);

                    // Add the link
                    body.add(link);

                    break;

                }

                // Map fragment
                case MessageType.mapLineContent: {



                    break;

                }

                // Change theme
                case MessageType.changeTheme: {

                    context.theme = message.content[0].get!Color;

                    break;

                }

                default: break;

            }

        }

    }

    /// Get the map
    Element map() const {

        return elem!("div", q{ id="map-contents" })("");

    }

}

private void addBoxContent(ref Element link, string icon, string text) {

    // Add an icon
    if (icon.length) {

        link.add(
            elem!"img"([
                "src": "/resources/icons/" ~ icon ~ ".png",
                "alt": ""
            ])
        );

    }

    // Add text
    link.add(text);

}
