#pragma lanuage glsl3

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
    number pW = 1 / love_ScreenSize.x; //pixel width
    number pH = 1 / love_ScreenSize.y; //pixel height

    vec4 pixel = Texel(texture, texture_coords); //This is the current pixel

    vec2 coords = vec2(texture_coords.x - pW, texture_coords.y);
    vec4 Lpixel = Texel(texture, coords); //Pixel on the left

    coords = vec2(texture_coords.x + pW, texture_coords.y);
    vec4 Rpixel = Texel(texture, coords); //Pixel on the right

    coords = vec2(texture_coords.x, texture_coords.y - pH);
    vec4 Upixel = Texel(texture, coords); //Pixel on the up

    coords = vec2(texture_coords.x, texture_coords.y + pH);
    vec4 Dpixel = Texel(texture, coords); //Pixel on the down

    pixel.a += 10 * 0.0166667 * (Lpixel.a * 1.5 + Rpixel.a * 1.5 + Dpixel.a * 1.5 + Upixel.a * 1.5 - pixel.a * 6.1);

    pixel.rgb = vec3(1.0, 1.0, 1.0);

    return pixel;
}
