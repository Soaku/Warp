let currentTheme = "theme-cyan";

function resize() {

    let map = document.byID("map");
    let height = map.offsetWidth + "px";

    // Update height
    map.style.height = height;

    // Update title height
    document.byID("area-name").style.lineHeight = height;

    // Update map text size
    let mapContent = document.byID("map-contents");
    mapContent.style.fontSize = map.offsetWidth / 16 + "px";

}

/// Update the theme variable
function updateTheme() {

    for (let cls of document.body.classList) {

        // Get the current theme
        if (!cls.startsWith("theme-")) continue;

        // Mark as the active one
        currentTheme = cls;

    }

}

/// Set page theme
function setTheme(num) {

    const theme = "theme-" + color(num);

    // Nothing changed
    if (theme === currentTheme) return;

    // Update the theme otherwise
    document.body.classList.replace(currentTheme, theme);
    currentTheme = theme;

}

/// Get color class from number
function color(num) {

    switch (num) {
        case 0: return "white";
        case 1: return "theme";
        case 2: return "grey";
        case 3: return "red";
        case 4: return "green";
        case 5: return "yellow";
        case 6: return "blue";
        case 7: return "magenta";
        case 8: return "cyan";
    }

}
