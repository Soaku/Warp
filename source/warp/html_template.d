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
                href="/main.css"
            })

        ),

        elem!"body"(body),

    );

}
