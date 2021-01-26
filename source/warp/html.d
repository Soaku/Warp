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

                elem!("div", q{ id="map" class="column" })(

                    "WARP".elem!("h1", q{ class="title" }),

                ),

                elem!("main", q{ class="column" })(

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

                sw: final switch (message.content[0].get!int) {

                    static foreach (i, el; ["p", "h1", "h2", "h3", "h4", "h5", "h6"]) {

                        case i:
                            elements.add!el(message.content[1].str);
                            break sw;

                    }

                }

                break;

            default: break;

        }

    }

    return elements;

}
