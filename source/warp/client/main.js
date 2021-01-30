// Main
document.addEventListener("DOMContentLoaded", () => {

    // Bind events
    window.addEventListener("resize", resize);

    // Generate content
    generateMap();
    generatePortalParticles();

    // remove later and perform based on API input
    setInterval(drawPortal, 100);

    // Resize layout
    resize();

    // Remove all instances of this stupid class
    for (element of document.byClass("requires-js")) {

        element.classList.remove("requires-js");

    }

});
