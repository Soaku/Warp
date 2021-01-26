module warp.html;

import elemi;
import std.conv;

import warp.structs;
import warp.server.structs;

string htmlTemplate(Response response, Element body) {

    return Element.HTMLDoctype ~ elem!"html"(

        elem!"head"(

            // Page metadata
            elem!"title"(
                response.title
                    ? text(response.title, " — WARP")
                    : "WARP"
            ),

            // Settings
            Element.MobileViewport,
            Element.EncodingUTF8,

            // Resources
            elem!("link", q{
                rel="stylesheet"
                href="/resources/main.css"
            }),

            elem!("script", q{
                src="/resources/main.js"
            }),

        ),

        elem!"body"(

            elem!("div", q{ class="body-wrapper" })(

                // Navigation
                elem!("div", q{ id="map-column" class="column" })(

                    // Map
                    elem!("div", q{ id="map" })(

                        "WARP".elem!("h1", q{ class="title" }),

                    ),

                    // Navigation items
                    elem!"nav"(

                        "Home"         .elem!("a", q{ href="/" }),
                        "Characters"   .elem!("a", q{ href="/characters" }),
                        "Owned worlds" .elem!("a", q{ href="/worlds/make" }),
                        "Public worlds".elem!("a", q{ href="/worlds/public" }),
                        "Friends"      .elem!("a", q{ href="/friends" }),

                    ),

                ),

                // Main content
                elem!("main", q{ class="column" })(

                    elem!("div", q{ id="profile" class="yellow" })(

                        // User
                        "Anonymous".elem!("a", q{ href="/user" class="yellow" }),
                        "0 crystals".elem!("p", q{ style="float:right" }),

                        elem!("div", q{ class="progress-content" })
                            .elem!("div", q{ class="progress" }),

                    ),

                    body,

                )

            ),

        ),

    );

}
/// Display the given message list.
///
/// Effect of this is limited, some of the features only work from JS.
Element display(Message[] messages) {

    Element elements;

    // Check each message
    foreach (message; messages) {

        switch (message.type) {

            // Add content
            case MessageType.addContent:

                auto attributes = ["class": message.content[1].get!int.to!Color.to!string];

                sw: final switch (message.content[0].get!int) {

                    static foreach (i, el; ["p", "h1", "h2", "h3", "h4", "h5", "h6"]) {

                        case i:
                            elements.add(

                                elem!el(
                                    attributes,
                                    message.content[2].str,
                                )

                            );
                            break sw;

                    }

                }

                break;

            default: break;

        }

    }

    return elements;

}
