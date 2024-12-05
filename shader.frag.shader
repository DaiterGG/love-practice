#pragma lanuage glsl3

number rand3dTo1d(vec3 value) {
    vec3 dotDir = vec3(12.9898, 78.233, 37.719);
    //make value smaller to avoid artefacts
    vec3 smallValue = sin(value);
    //get scalar value from 3d vector
    number random = sin(dot(smallValue, dotDir)) * 143758.5453;
    //make value more random by making it bigger and then taking the factional part
    random = fract(random);
    return random;
}
number rand2dTo1d(vec2 value) {
    vec3 dotDir = vec3(12.9898, 78.233, 37.719);
    //make value smaller to avoid artefacts
    value.x = sin(value.x * 2983.234);
    vec2 smallValue = sin(value * 6237.483);
    vec3 val = vec3((value.x * value.y) + 1, 1 - (value.x * value.y), value.x + value.y);
    //get scalar value from 3d vector
    number random = sin(dot(val, dotDir)) * 143758.5453;
    //make value more random by making it bigger and then taking the factional part
    random = fract(random);
    return random;
}

number Lerp(number a, number b, number t) {
    return a + (b - a) * t;
}
vec3 Lerp(vec3 a, vec3 b, number t) {
    return vec3(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, a.z + (b.z - a.z) * t);
}
number EaseInSquare(number t) {
    return t * t;
}
number EaseOutSquare(number t) {
    return 1 - EaseInSquare(1 - t);
}
number EaseInOutSquare(number t) {
    return Lerp(EaseInSquare(t), EaseOutSquare(t), t);
}

number rand1dTo1d(number value) {
    return fract(sin(value + .42683) * 143758.5453);
}

uniform vec2[1000] particles;
extern number particleCount;
extern number circleSize;
extern number time;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    number timer = time * 20;
    number cellSize = 40 * (sin(time) + 1.1);
    number circleSizeSqr = circleSize * circleSize;
    screen_coords += vec2(timer, timer);
    number gridX = floor(screen_coords.x / cellSize);
    number gridY = floor(screen_coords.y / cellSize);

    // virtual point in the center of each cell
    number centerX = (gridX * cellSize) + (cellSize / 2);
    number centerY = (gridY * cellSize) + (cellSize / 2);

    //fix so circles can overflow from adjacent cells
    number xOffset;
    if (screen_coords.x - centerX > 0) {
        xOffset = 1;
    } else {
        xOffset = -1;
    }
    number yOffset;
    if (screen_coords.y - centerY > 0) {
        yOffset = 1;
    } else {
        yOffset = -1;
    }

    number xCoord = (gridX + xOffset) * cellSize + (cellSize / 2);
    number yCoord = (gridY + yOffset) * cellSize + (cellSize / 2);

    number minDistAdjX = pow(xCoord - screen_coords.x, 2) + pow(centerY - screen_coords.y, 2);
    number minDistAdjY = pow(centerX - screen_coords.x, 2) + pow(yCoord - screen_coords.y, 2);

    vec2 adj;
    if (minDistAdjX < minDistAdjY) {
        adj = vec2(xCoord, centerY);
    } else {
        adj = vec2(centerX, yCoord);
    }

    number minDistSqr = 999999999;
    number minAdj = 99999999;
    for (int i = 0; i < particleCount; i++) {
        number dx = particles[i].x + timer - centerX;
        number dy = particles[i].y + timer - centerY;
        number dot = dx * dx + dy * dy;

        number jx = particles[i].x + timer - adj.x;
        number jy = particles[i].y + timer - adj.y;
        number jdot = jx * jx + jy * jy;

        if (dot < minDistSqr) {
            minDistSqr = dot;
        }
        if (jdot < minAdj) {
            minAdj = jdot;
        }
    }

    number PixelToCenter = sqrt(pow(centerX - screen_coords.x, 2) + pow(centerY - screen_coords.y, 2));
    number PixelToAdj = sqrt(pow(adj.x - screen_coords.x, 2) + pow(adj.y - screen_coords.y, 2));

    number centerMaxSize = 1 - (sqrt(minDistSqr) / circleSize);
    number centerSize = centerMaxSize * (cellSize / 2 * 1.8);

    number centerMaxAdj = 1 - (sqrt(minAdj) / circleSize);
    number centerAdj = centerMaxAdj * (cellSize / 2 * 1.8);

    vec4 colorRes = vec4(0, 0, 0, 1);
    if (PixelToCenter <= centerSize) {
        colorRes = vec4(1, 1, 1, 1);
    }
    if (PixelToAdj <= centerAdj) {
        colorRes = vec4(1, 1, 1, 1);
    }
    // if (abs(screen_coords.x - centerX) < .6 && abs(screen_coords.y - centerY) < .6) {
    //     colorRes = vec4(1, 0, 1, 1);
    // }
    return colorRes;
}
