/// Contains map data.
const map = new function() {

    this.size = [25, 15];
    this.center = [
        Math.floor(this.size[0] / 2),
        Math.floor(this.size[1] / 2),
    ];
    this.scaleX = this.size[1] / this.size[0];
    this.mode = 0

    // Start the portal drawing interval
    this.portal = null;
    this.step = 0;  // 0–360 in degrees, used for sin() transitions
    this.portalParticles = [];

}

/// Generate the map layout if not present.
function generateMap() {

    // Get the map contents element
    const mapContents = document.byID("map-contents");

    // Generate the content
    generateMapContents(mapContents);

    // Add a portal transition helper
    const trans = document.createElement("div");
    trans.id = "transition-helper";
    trans.style.opacity = "0";

    mapContents.appendChild(trans);

}

/// Generate map contents in the given element
/// @private
function generateMapContents(mapContents) {

    // Ignore if it has children
    if (mapContents.children.length > 0) return;

    let rowHTML = "";
    let contentHTML = "";

    // Generate HTML for each row
    for (let i = 0; i < 25; i++) {

        rowHTML += "<div class=\"c\"> </div>";

    }

    rowHTML = "<div class=\"row\">" + rowHTML + "</div>";

    // Generate contents
    for (let i = 0; i < 15; i++) {

        // Add a row
        contentHTML += rowHTML;

    }

    // Set the content
    mapContents.innerHTML = contentHTML;

}

/// Update the map mode
function updateMapMode(newMode) {

    // Set the new value
    map.mode = newMode;

    // 0 or 1
    if (map.mode <= 1) {

        // Unless there is already a portal spawned
        if (!map.portal) {

            // Create one
            map.portal = setInterval(drawPortal, 100);

        }

    }

    else {

        // Wait until the current portal stops

    }

}

/// Draw the map
function drawMap() {

}
