Shader "Custom/Planet"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _StormDivisions ("Storm Divisions", float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        
        #include "Utils.cginc"

        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float3 viewDir;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float _StormDivisions;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)


        float3 checker(float2 coord, float size)
        {
            coord += float2(2.0, 0.0);
            
            float tile = max((size * coord.x) + 
                (size * coord.y), 1.0);
            float col = 0.02 * abs(sin(.25 * tile * _Time.y));
            
            return float3(col, col, col);
        }


        /*
        * Creates a storm looking thing
        */
        float storm(float2 coord)
        {
            float2 n_coord = coord;
            n_coord.x += 0.1 * sin(1.1 * _Time.y);
            n_coord.y += 0.2 * _Time.y;

            float col = sin(n_coord.y * _StormDivisions) / (distance(float2(0.2, 0.2), coord) + .5) +
                (0.05 * cos(_Time.y) + 0.2) * sin(n_coord.x * _StormDivisions);

            return col;
        }


        /*
        * Creates another storm looking thing
        */
        float pseudo_storm(float2 coord, float size)
        {
            coord += float2(
                0.2 * abs( sin(0.1 * _Time.y)) + 
                    0.15 * abs(cos(0.2 * _Time.y)), 
                _Time.y);

            float col = .05*(
                sin(coord.y * 18.0) * (distance(float2(0.,0.), coord) + 0.2) +
                (0.02 * cos(_Time.y) + 0.2) * sin(coord.x * 18.0)
            );
            return col;
        }


        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            float2 coord = IN.worldPos.yx;
            float3 color = float3(0.0, 0.0, 0.0);

            _StormDivisions = _StormDivisions * (0.2 * sin(0.25 * _Time.y) + 1.0);

            float s = storm(coord);
            color.r += 0.5*s;// + 0.01 * sin(0.4 * _Time.y);
            color.g += 0.04*s;// + 0.005 * sin(0.8 * _Time.y);
            color.b += 0.01*s;// + 0.02 * sin(0.8 * _Time.y);

            //color -= checker(coord / _Time.y, 0.5);
            //color -= pseudo_storm(coord, .05);

            color = rgb2hsv(color);
            color.y *= 1.;
            color.z = 0.2;
            color = hsv2rgb(color);

            _Glossiness += (0.2 * sin(0.5 * _Time.y));

            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = color.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
