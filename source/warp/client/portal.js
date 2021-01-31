const portal = new function() {

    this.speed = 6;
    this.minParticleDistance = 0;
    this.maxRadius = 7.5;

    this.update = () => {

        const tween = (prop, target) => {

            const direction = Math.sign(target - this[prop]);

            // Wanting a different target
            if (this[prop] !== target) {

                this[prop] += direction;

                // Crossed the target
                if (this[prop] * direction > target * direction) {

                    this[prop] = target;

                }

            }

        }

        // Update the params
        if (map.mode === 1) {

            tween("speed", 18);
            tween("minParticleDistance", 10);
            tween("maxRadius", 3);

        }

        else {

            tween("speed", 6);
            tween("minParticleDistance", 0);
            tween("maxRadius", map.size[1]/2 + 0.5);

        }

    }

};

/// Create a portal particle.
///
/// angle = Angle (0–360) this particle is on.
/// distance = Distance of the particle away from
function PortalParticle(angle, distance) {

    this.angle = Math.random() * 360;
    this.distance = Math.random() * 8;
    this.initialDistance = this.distance;

    this.orbit = [
        0.6 + Math.random() * 0.4,
        0.6 + Math.random() * 0.4
    ];

    this.getPosition = function () {

        const angleRad = this.angle * Math.PI / 180;
        return [
            map.center[0] + this.orbit[0] * Math.sin(angleRad) * this.distance,
            map.center[1] + this.orbit[1] * Math.cos(angleRad) * this.distance,
        ];

    }

}

/// Generate portal particles to place on the map.
function generatePortalParticles() {

    for (let i = 0; i < 20; i++) {

        map.portalParticles.push(new PortalParticle);

    }

}

/// Draw a portal on the map.
function drawPortal() {

    const mapContents = document.byID("map-contents");

    // Update speed
    portal.update();

    // Get transition change
    const change = Math.sin(map.step * Math.PI / 180);
    map.step = (map.step + 5) % 360;

    // Update particle params
    for (let particle of map.portalParticles) {

        particle.angle = (particle.angle + portal.speed) % 360;
        particle.distance = Math.max(portal.minParticleDistance, particle.initialDistance);

    }

    // Also update title position
    const title = document.byClass("title")[0];
    if (title !== undefined) {

        title.style.left = change*5 + "px";
        title.style.top = Math.cos(map.step * Math.PI / 180)*5 + "px";

    }

    // Draw the portal
    for (let y = 0; y < map.size[1]; y++)
    for (let x = 0; x < map.size[0]; x++) {

        const cell = [x, y, mapContents.children[y].children[x]];

        // Clear the cell.
        resetCell(cell);

        // Draw the main circle
        drawCircle(cell, map.center, map.size[1]/2 + change/2, 1.00);
        drawCircle(cell, map.center, Math.min(portal.maxRadius, map.size[1]/3 + change/2), 1.00);

        // Draw the particles
        for (let particle of map.portalParticles) {

            drawCircle(cell, particle.getPosition(), 2 + change, 1);

        }

    }

}

/// Reset the contents of a cell.
function resetCell(cell) {

    cell[2].classList = ["c"];
    cell[2].style.opacity = "";

}

/// Draw a cell of a circle. It will be scaled on the X axis to prevent it looking like an elipse.
function drawCircle(cell, center, radius, gradient) {

    // Distance from circle center
    let distance = Math.sqrt(
        Math.pow(map.scaleX * (cell[0] - center[0]), 2)
        + Math.pow(cell[1] - center[1], 2)
    );

    // Ignore if outside of radius
    if (distance > radius) return;

    cell[2].classList.add("portal-magenta");

    let oldOpacity = parseFloat(cell[2].style.opacity);
    oldOpacity = isNaN(oldOpacity) ? 0 : oldOpacity;

    cell[2].style.opacity = oldOpacity + (1 - distance*gradient/radius) * (1 - oldOpacity);

}
