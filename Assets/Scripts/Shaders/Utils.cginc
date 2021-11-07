#ifndef UTILS
#define UTILS



/*
 * Translates the coordinates in the x and y axis
 */
float2 translate(float2 coord, float2 translation)
{
    return coord + translation * 0.5;
}


/*
 * Zooms the canvas in or out
 */
float2 izoom(float2 coord, float z)
{
    return coord * z;
}


/*
 * Scales the coordinates in the x and y axis
 */
float2 scale(float2 coord, float2 scale)
{
    coord -= float2(0.5, 0.5);
    coord = mul(float2x2(scale.x + 2.0, 0.0, 0.0, scale.y + 2.0), coord);
    coord += float2(0.5, 0.5);
    return coord;
}


// All components are in the range [0…1], including hue.
float3 rgb2hsv(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}


// All components are in the range [0…1], including hue.
float3 hsv2rgb(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}



#endif