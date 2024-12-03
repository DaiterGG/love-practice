#pragma lanuage glsl3
// #include WiteNoise.util.shader

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

number valueNoise2d(vec2 value) {
    number a = rand2dTo1d(vec2(floor(value.x), floor(value.y)));
    number b = rand2dTo1d(vec2(ceil(value.x), floor(value.y)));
    number c = rand2dTo1d(vec2(floor(value.x), ceil(value.y)));
    number d = rand2dTo1d(vec2(ceil(value.x), ceil(value.y)));

    number interX = EaseInOutSquare(fract(value.x));
    number interY = EaseInOutSquare(fract(value.y));

    number x = Lerp(a, b, interX);
    number y = Lerp(c, d, interX);
    return Lerp(x, y, interY);
}
number rand1dTo1d(number value) {
    return fract(sin(value + .42683) * 143758.5453);
}
vec3 valueNoiseColor2d(vec2 value) {
    number a = rand2dTo1d(vec2(floor(value.x), floor(value.y)));
    number b = rand2dTo1d(vec2(ceil(value.x), floor(value.y)));
    number c = rand2dTo1d(vec2(floor(value.x), ceil(value.y)));
    number d = rand2dTo1d(vec2(ceil(value.x), ceil(value.y)));

    vec3 aR = vec3(rand1dTo1d(a), rand1dTo1d(a + .1), rand1dTo1d(a + .2));
    vec3 bR = vec3(rand1dTo1d(b), rand1dTo1d(b + .1), rand1dTo1d(b + .2));
    vec3 cR = vec3(rand1dTo1d(c), rand1dTo1d(c + .1), rand1dTo1d(c + .2));
    vec3 dR = vec3(rand1dTo1d(d), rand1dTo1d(d + .1), rand1dTo1d(d + .2));

    number interX = EaseInOutSquare(fract(value.x));
    number interY = EaseInOutSquare(fract(value.y));

    vec3 x = Lerp(aR, bR, interX);
    vec3 y = Lerp(cR, dR, interX);
    return Lerp(x, y, interY);
}

extern number time;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    gridX = floor(screen_coords.x / 50);
    gridY = floor(screen_coords.y / 50);
    dotX = rand2dTo1d(vec2(gridX, gridY));
    dotY = rand2dTo1d(vec2(gridY, gridX));
    number dist = length(vec2(dotX, dotY), vec2(texture_coords.x, texture_coords.y));
    vec4 pixel = Texel(texture, res) * color;
    screen_coords
    return pixel;
}
number randomLine(vec2 screen, vec2 texture, number ceil) {
    number cellX = screen.x / ceil;
    number cellY = screen.y / ceil;
    // number randPrev = rand1dTo1d(floor(cell));
    // number randNext = rand1dTo1d(ceil(cell));
    // number interp = EaseInOutSquare(fract(cell));
    // number rand = Lerp(randPrev, randNext, interp);
    // // number y = (texture_coords.y - 0.5) * 10;
    // number y = texture_coords.y;
    // number dist = abs(rand - y);
    // number pixelhigh = fwidth(texture_coords.y);
    // number line = smoothstep(0, pixelhigh, dist);

    return ceil;
}
// number pH = 1 / love_ScreenSize.y; //pixel height
// // vec2 coords = vec2(texture_coords.x, texture_coords.y);
// // coords = vec2(texture_coords.x + pW * 20, texture_coords.y);
// number grid = 70;
// number gridX = pW * grid;
// number gridY = pH * grid;
// vec2 coords = vec2(texture_coords.x, texture_coords.y);
// number x = texture_coords.x;
// number pW = 1 / love_ScreenSize.x; //pixel width
// number y = texture_coords.y;
// number dirX = -1;
// number dirY = -1;
// if (texture_coords.x < .5) {
//     dirX = 1;
//     x = 1 - texture_coords.x;
// }
// if (texture_coords.y < .5) {
//     dirY = 1;
//     y = 1 - texture_coords.y;
// }
// number offsetX = floor((x - .5 + gridX / 2) / gridX);
// number offsetY = floor((y - .5 + gridY / 2) / gridY);
// number resX = texture_coords.x + (offsetX * gridX * dirX);
// number resY = texture_coords.y + (offsetY * gridY * dirY);

// coords = vec2(resX, resY);
// vec4 pixel = Texel(texture, coords);
// pixel.a = 1;
// pixel.rgb = vec3(1.0, 1.0, 1.0);
