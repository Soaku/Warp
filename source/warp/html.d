module warp.html;

import elemi;
import std.conv;

import warp.structs;
import warp.server.structs;

string htmlTemplate(const Context context, Element body) {

    return Element.HTMLDoctype ~ elem!"html"(

        elem!"head"(

            // Page metadata
            elem!"title"(
                context.response.title
                    ? text(context.response.title, " — WARP")
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

                    elem!("a", q{ class="mobile menu" href="javascript:void(0)" })(

                        elem!("img", q{
                            alt="Menu" src="/resources/icons/menu.png"
                        })

                    ),

                    // Navigation items
                    elem!"nav"(

                        context.link("Home", "/"),
                        context.link("Characters", "/characters"),
                        context.link("Owned worlds", "/worlds"),
                        context.link("Public worlds", "/worlds/public"),
                        context.link("Friends", "/friends"),

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
Element display(ref Context context, Message[] messages) {

    Element elements;

    // Check each message
    foreach (message; messages) {

        switch (message.type) {

            // Add content
            case MessageType.addContent:

                auto color = message.content[1].get!Color;
                auto attributes = ["class": to!string(color == Color.theme ? context.theme : color)];

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

            // Add link
            case MessageType.addLink:

                elements.add(
                    elem!"a"(
                        [
                            "class": "box-link",
                            "title": message.content[1].str,
                            "href": message.content[2].str,
                        ],
                        elem!"img"([
                            "src": "/resources/icons/" ~ message.content[0].str ~ ".png",
                            "alt": ""
                        ]),
                        message.content[1].str,
                    )
                );

                break;

            // Change theme
            case MessageType.changeTheme:

                context.theme = message.content[0].get!Color;

                break;

            default: break;

        }

    }

    return elements;

}

private Element link(const Context context, string content, string href) {

    return elem!"a"(["class": context.theme.to!string, "href": href], content);

}
