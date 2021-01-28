function resize() {

    let map = document.byID("map");
    let height = map.offsetWidth + "px";

    // Update height
    map.style.height = height;

    // Update title height
    map.querySelector("h1.title").style.lineHeight = height;

}
