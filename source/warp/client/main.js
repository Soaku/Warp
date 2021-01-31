// Main
document.addEventListener("DOMContentLoaded", () => {

    // Bind events
    window.addEventListener("resize", resize);
    window.addEventListener("popstate", refreshAPI);

    // Prepare the map
    generateMap();
    generatePortalParticles();
    spawnPortal();

    // Start the API
    findLastMessage();
    bindAllLinks();

    // Resize layout
    resize();

    // Remove all instances of this stupid class
    for (element of document.byClass("requires-js")) {

        element.classList.remove("requires-js");

    }

});
