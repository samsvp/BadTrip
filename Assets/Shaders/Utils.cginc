#ifndef UTILS
#define UTILS


const float PI = 3.1415926535;

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
 * Generates a random number between 0 and 1
 */
float rand1d(float v)
{
    return cos(v + cos(v * 90.1415) * 100.1415) * 0.5 + 0.5;
}

float rand1d(float v, float min_v, float max_v)
{
    return (max_v - min_v) * rand1d(v) + min_v;
}

float rand1d(float2 coord, float2 seed)
{
    return frac(
        sin(
            dot(coord, seed)
        ) * 43758.5453
    );
}

float rand1d(float2 coord)
{
    return rand1d(coord, float2(12.9898, 78.233));
}

float2 rand2d(float2 value)
{
    return float2(
		rand1d(value, float2(12.989, 78.233)),
		rand1d(value, float2(39.346, 11.135))
	);
}

float2 rand2d(float2 v, float min_v, float max_v)
{
    return (max_v - min_v) * rand2d(v) + min_v;
}

/*
 * Returns wheter p1 is close to p2
 */
bool close(float p1, float p2, float eps)
{
    return p1 < p2 + eps && p1 > p2 - eps;
}


float deg2rad(float angle)
{
    return PI * angle / 180.0;
}


/*
 * Rotates the given coordinates by
 * theta rads. This changes the input
 * coordinates
 */
void rotate_coord(float theta, out float2 coord)
{
    float2x2 R = float2x2(cos(theta), -sin(theta),
                  sin(theta), cos(theta));

    coord = mul(coord, R);
}


/*
 * Scales the given coordinates by s.
 * This changes the input coordinates
 */
void scale_coord(float s, float2 coord)
{
    coord /= s;
}


/*
 * Rotates the given coordinates by
 * theta rads
 */
float2 rotate(float theta, float2 coord)
{
    float2x2 R = float2x2(cos(theta), -sin(theta),
                  sin(theta), cos(theta));

    return mul(coord, R);
}

float2 rotate(float k, float theta, float2 coord)
{
    float2x2 R = float2x2(cos(theta), -k * sin(theta),
                  sin(theta) / k, cos(theta));

    return mul(coord, R);
}

/*
 * Scales the given coordinates by s
 */
float2 scale(float s, float2 coord)
{
    return coord / s;
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