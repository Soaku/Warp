let apiListenAddress = "";

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

/// Make a request to the API.
function requestAPI(url, method, action) {

    // Build the request
    let init = {
        "method": method
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
        .then(text => {

            const main = document.byTag("main")[0];

            main.appendChild(document.createElement("p"));
            readAPI(JSON.parse(text));

        });

}

/// Read API messages
function readAPI(messages) {

    // Clear some values to defaults
    map.mode = 0;
    // theme = 0

    for (let item of messages) {

        readAPIMessage(item);

    }

}

/// Read a single API message
function readAPIMessage(message) {

    console.log(message);

    const main = document.byTag("main")[0];

    // Check message type
    switch (message[0]) {

        // Clear content
        case "clearContent": {

            // Remove all elements except the profile
            while (main.children.length > 1) {
                main.removeChild(main.lastChild);
            }
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

            main.appendChild(elem);
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

            main.appendChild(elem);
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

            main.appendChild(elem);
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

            map.mode = message[1];

            // Portal
            if (map.mode <= 1) spawnPortal();

            // Map (TODO)
            else { }

            break;

        }


        // Listen for updates
        case "listen": {

            apiListenAddress = message[1];
            break;

        }

    }

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
