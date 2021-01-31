// Main
document.addEventListener("DOMContentLoaded", () => {

    // Bind events
    window.addEventListener("resize", resize);
    window.addEventListener("popstate", refreshAPI);

    // Prepare the map
    generateMap();
    generatePortalParticles();
    updateMapMode(0);

    // Start the API
    findLastMessage();
    bindAllLinks();

    // Prepare layout
    updateTheme();
    resize();

    // Remove all instances of this stupid class
    for (element of document.byClass("requires-js")) {

        element.classList.remove("requires-js");

    }

});
