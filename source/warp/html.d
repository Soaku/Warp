module warp.html;

import elemi;
import std.conv;
import std.meta;
import std.array;
import std.range;
import std.algorithm;

import warp.structs;
import warp.server.structs;

public import warp.display_api;

string htmlTemplate(const Context context, const APIData api) {

    // Theme is grey, make the profile color grey too
    auto profileTheme = context.theme == Color.grey ? "grey"

        // Make it yellow otherwise
        : "yellow";

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

            elem!("form", q{ class="body-wrapper" method="POST" })(

                // Add a hidden form item with the token
                elem!("input")([
                    "type": "hidden",
                    "name": "action-token",
                    "value": cast() context.user.actionToken,
                ]),

                // Navigation
                elem!("div", q{ id="map-column" class="column" })(

                    // Map
                    elem!("div", q{ id="map" })(

                        "WARP".elem!("h1", q{ class="title" }),

                        // Generate the map
                        api.map,

                        // Enable middle align of the map content
                        elem!("div", q{ class="middle-helper" }),

                    ),

                    elem!("a", q{ class="mobile menu" href="javascript:void(0)" title="Menu" })(

                        elem!("img", q{
                            alt="" src="/resources/icons/menu.png"
                        })

                    ),

                    // Navigation items
                    elem!"nav"(

                        elem!"ul"(

                            context.link("Home", "/")                       .elem!"li",
                            context.link("Characters", "/characters")       .elem!"li",
                            context.link("Owned worlds", "/worlds")         .elem!"li",
                            context.link("Public worlds", "/worlds/public") .elem!"li",
                            context.link("Friends", "/friends")             .elem!"li",

                        )

                    ),

                ),

                // Main content
                elem!("main", q{ class="column" })(

                    elem!"div"(
                        ["id": "profile", "class": profileTheme],

                        // User
                        elem!"a"(
                            ["href": "/user", "class": profileTheme],
                            "Anonymous"
                        ),
                        "0 crystals".elem!("p", q{ style="float:right" }),

                        elem!("div", q{ class="progress-content" })
                            .elem!("div", q{ class="progress" }),

                    ),

                    api.body,

                )

            ),

        ),

    );

}

private Element link(const Context context, string content, string href) {

    return elem!"a"(["class": context.theme.to!string, "href": href], content);

}
