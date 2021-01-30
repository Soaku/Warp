// Main
document.addEventListener("DOMContentLoaded", () => {

    // Bind events
    window.addEventListener("resize", resize);

    // Generate content
    generateMap();
    generatePortalParticles();
    spawnPortal();
    bindAllLinks();

    // Resize layout
    resize();

    // Remove all instances of this stupid class
    for (element of document.byClass("requires-js")) {

        element.classList.remove("requires-js");

    }

});
