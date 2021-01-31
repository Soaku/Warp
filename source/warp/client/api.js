const api = new function() {

    this.listenStream = "";
    this.listenControl = new AbortController;
    this.lastAnchor = 0;
    this.messageElem = null;

    this.restoreChanges = () => {

        this.changes = {
            "events": "",
            "theme": 8,
            "mapMode": 0,
        };

    }
    this.restoreChanges();

}

/// Find the last message
function findLastMessage() {

    api.messageElem = document.byTag("main")[0].lastChild;

}

/// Bind all links on the page
function bindAllLinks() {

    for (let item of document.byTag("a")) bindLink(item);
    for (let item of document.byTag("button")) bindLink(item);

}

/// Modify the given link element to perform an API request instead of reloading the whole page.
function bindLink(element) {

    if (element.nodeName == "A") {

        const url = new URL(element.href);

        // Check if the domain matches
        if (url.host !== window.location.host) return;

        element.addEventListener("click", e => {

            const target = url.pathname;

            history.pushState({}, "", target);
            requestAPI(target, "GET");
            e.preventDefault();

        });

    }

    else if (element.nodeName = "BUTTON") {

        element.addEventListener("click", e => {

            const target = window.location.pathname;

            history.pushState({}, "", target);
            requestAPI(target, "POST", element.value);
            e.preventDefault();

        });

    }

}

/// Make an API call to refresh this page, used for history handling.
function refreshAPI() {

    requestAPI(window.location.pathname, "GET");

}

/// Listen to an API event stream.
function listenAPI(stream) {

    // Ignore if the stream is at the same address
    if (stream === api.listenStream) return;

    // Stop previous stream
    api.listenControl.abort();

    // Mark as listening
    api.listenStream = stream;

    // Don't proceed if ordered to stop
    if (stream === "") return;

    // Create a new control
    api.listenControl = new AbortController;

    // Build the request
    const init = {
        "signal": api.listenControl.signal,
    };

    fetch("/api/event/" + stream, init)
        .then(response => response.text())
        .then(parseAPI);

}

/// Make a request to the API.
function requestAPI(url, method, action) {

    // Build the request
    const init = {
        "method": method,
    };

    // If doing a POST request
    if (method === "POST") {

        // Attach form data
        const form = document.byTag("form")[0];
        const formData = new FormData(form);
        const urlData = new URLSearchParams();

        // Convert to x-www-urlencoded
        for (let pair of formData) {

            urlData.append(pair[0], pair[1]);

        }

        // Add action
        urlData.append("action", action);

        // Create URL search params
        init.body = urlData;

    }

    // Perform the request
    fetch("/api" + url, init)

        .then(response => response.text())
        .then(parseAPI);

}

/// Parse an API response
function parseAPI(text) {

    const main = document.byTag("main")[0];

    // Create a separator
    const sep = document.createElement("p");
    sep.id = "anchor-" + api.lastAnchor++;
    api.messageElem.append(sep);

    // Get its position
    const setOffset = sep.offsetTop;

    // Read the message
    readAPI(JSON.parse(text));

    // If focus is in the menu
    const nav = document.byTag("nav")[0];
    const focus = document.activeElement;

    // Clear it
    if (nav.contains(focus)) focus.blur();

    // Scroll the the separator
    main.scrollTop = setOffset;

}

/// Read API messages
function readAPI(messages) {

    // Clear some values to defaults
    api.restoreChanges();

    for (let item of messages) {

        readAPIMessage(item);

    }

    // Update some queued values
    listenAPI(api.changes.events);
    setTheme(api.changes.theme);
    updateMapMode(api.changes.mapMode);

}

/// Read a single API message
function readAPIMessage(message) {

    console.log(message);

    const msgElem = api.messageElem;

    // Check message type
    switch (message[0]) {

        // Start a content message
        case "message": {

            const main = document.byTag("main")[0];

            // Find the message parent
            if (message[1] !== "..") {

                // Start from the end, skip first child
                for (let i = main.childElementCount-1; i >= 1; i--) {

                    // Find the child
                    const child = main.children[i];

                    // End once the parent is found
                    if (child.getAttribute("data-uri") === message[1]) break;

                    // Delete the child otherwise
                    main.removeChild(child);

                }

            }

            // Create an element for the object
            const elem = document.createElement("div");
            elem.setAttribute("data-uri", window.location.pathname);

            // Assign as the current message element
            api.messageElem = elem;

            // Append the message element
            main.appendChild(elem);

            break;

        }

        // Add new item to the content
        case "addContent": {

            // Create an element
            const tag = message[1]
                ? ("h" + message[1])
                : ("p");
            const elem = document.createElement(tag);

            elem.classList.add(color(message[2]));
            elem.innerText = message[3]

            msgElem.appendChild(elem);
            break;

        }

        // Add link
        case "addLink": {

            // Create an element
            const elem = document.createElement("a");
            elem.classList.add("box-link");
            elem.title = message[2];
            elem.href = message[3];

            // Modify it
            addBoxContent(elem, message[1], message[2]);
            bindLink(elem);

            msgElem.appendChild(elem);
            break;

        }

        // Add an action
        case "addAction": {

            const elem = document.createElement("button");
            elem.classList.add("box-link");
            elem.name = "action";
            elem.value = message[3];

            addBoxContent(elem, message[1], message[2]);
            bindLink(elem);

            msgElem.appendChild(elem);
            break;

        }

        // Update the action token
        case "setToken": {

            const tokenInput = document.byName("action-token")[0];
            tokenInput.value = message[1];
            break;

        }


        // Change map mode
        case "mapMode": {

            api.changes.mapMode = message[1];
            break;

        }

        // Set page theme
        case "setTheme": {

            // Queue changing theme
            api.changes.theme = message[1];
            break;

        }

        // Listen for updates
        case "listen": {

            // Queue changing stream
            api.changes.events = message[1];
            break;

        }

    }

}

/// Fill a box-link with content
function addBoxContent(element, icon, text) {

    // If there is an icon
    if (icon.length) {

        // Create an img
        const img = document.createElement("img");
        img.src = "/resources/icons/" + icon + ".png";
        img.alt = "";
        element.appendChild(img);

    }

    // Add text
    element.appendChild(
        document.createTextNode(text)
    );

}
