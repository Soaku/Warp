module warp.html;

import elemi;
import std.conv;
import std.meta;
import std.array;
import std.range;
import std.string;
import std.algorithm;

import warp.structs;
import warp.server.structs;

public import warp.display_api;

string htmlTemplate(const Context context, const APIData api) {

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
                defer
            }),

        ),

        elem!"body"(

            ["class": "theme-" ~ context.theme.to!string],

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
                        ["id": "profile"],

                        // User
                        elem!"a"(
                            ["href": "/user"],
                            "Anonymous"
                        ),
                        "0 crystals".elem!("p", q{ style="float:right" }),

                        elem!("div", q{ class="progress-content" })
                            .elem!("div", q{ class="progress" }),

                    ),

                    elem!"div"(
                        ["data-uri": "/" ~ context.urlParts.join("/")],

                        api.body,

                    )

                )

            ),

        ),

    );

}

private Element link(const Context context, string content, string href) {

    return elem!"a"(["class": "theme", "href": href], content);

}
