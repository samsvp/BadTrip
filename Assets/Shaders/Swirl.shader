Shader "Background/Swirl"
{
	//show values to edit in inspector
	Properties
	{
		_Color("Tint", Color) = (0, 0, 0, 1)
		_MainTex("Texture", 2D) = "white" {}
	}

		SubShader
	{
		//the material is completely non-transparent and is rendered at the same time as the other opaque geometry
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }

		Pass
		{
			CGPROGRAM

			//include useful shader functions
			#include "UnityCG.cginc"
			#include "Utils.cginc"

			//define vertex and fragment shader functions
			#pragma vertex vert
			#pragma fragment frag

			//texture and transforms of the texture
			sampler2D _MainTex;
			float4 _MainTex_ST;

			//tint of the texture
			fixed4 _Color;

			//the mesh data thats read by the vertex shader
			struct appdata {
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			//the data thats passed from the vertex to the fragment shader and interpolated by the rasterizer
			struct v2f {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			//the vertex shader function
			v2f vert(appdata v) {
				v2f o;
				//convert the vertex positions from object space to clip space so they can be rendered correctly
				o.position = UnityObjectToClipPos(v.vertex);
				//apply the texture transforms to the UV coordinates and pass them to the v2f struct
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}

			/*
			* Creates a colorful swirl shape
			*/
			float3 swirl(float2 coord, float2 pos, float a1, float a2, float a3)
			{
				float angle = atan2(-coord.y + pos.x, coord.x - pos.y) * 0.5;
				float len = length(coord - float2(pos.x, pos.y));

				float3 color = float3(0.0, 0.0, 0.0);

				color.r += 20.0 * sin(len * a1 + angle * 40.0 + _Time.y) +
					0.5 * cos(a1 * _Time.y * 0.01) + 19.0 * abs(sin(_Time.y));
				color.g += 15.0 * sin(len * a2 + angle * 40.0 - _Time.y) +
					0.5 * cos(a1 * _Time.y * 0.01) + 14.0;
				color.b += 20.0 * sin(len * a3 + angle * 50.0 + 3.0) + 19.0 * abs(sin(_Time.y));

				return color;
			}

			//the fragment shader function
			fixed4 frag(v2f i) : SV_TARGET
			{
				// translate coords
				float2 coord = translate(i.uv, float2(0.0, 0.0));
				coord = izoom(coord, 3.0 * sin(_Time.y * 0.1) + 1.0);
				coord *= scale(coord, float2(0.0, 0.0));

				float3 color = float3(20.0 * sin(_Time.y) - 8.0,
					15.0 * cos(_Time.y) - 8.0,
					18.0 * (cos(0.5 * _Time.y) + sin(0.5 * _Time.y)) + 5.0);

				color += 1.0 - swirl(coord, float2(0.0, 0.0), 1.0, 1.0, 1.0) + 1.0;

				float3 colorhsv = rgb2hsv(color);
				color = hsv2rgb(float3(colorhsv.x, 0.5 * colorhsv.y, abs(0.4 * sin(_Time.y * 0.5)) + 0.2));


				//return the final color to be drawn on screen
				return float4(color, 1.0);
			}

			ENDCG
		}
	}
}