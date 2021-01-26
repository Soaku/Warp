// Main
document.addEventListener("DOMContentLoaded", () => {

    // Bind events
    window.addEventListener("resize", resize);

    // Resize layout
    resize();

    // Remove all instances of this stupid class
    for (element of document.byClass("requires-js")) {

        element.classList.remove("requires-js");

    }

});
