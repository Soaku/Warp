module warp.html_template;

import elemi;
import std.conv;

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

            elem!("main", q{
                class="requires-js"
            })(

                body,

            ),

            elem!"noscript"(
                "Sorry, but while I would love to make WARP support browsers without JavaScript, WARP is a game ",
                "and some of its important features would not be doable without the help of scripts. ",
                "As a tracking hater, I don't use third-party scripts nor track you using any.",
            ),

        ),

    );

}
