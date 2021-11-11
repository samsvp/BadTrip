Shader "Unlit/unlit"
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
			 * Creates a point of light
			 */
			float3 light_point(float2 p, float brightness)
			{
				float3 color = float3(0.0, 0.0, 0.0);

				float l = pow(length(p), 1.3);
				color += 0.00008 / l * brightness;

				return color;
			}


			float3 light_point(float2 p)
			{
				return light_point(p, 5.0);
			}


			float3 bind_star(float x, float y, float2 point1, out float2 point2,
				float2 coord, float3 color, float brightness, float speed, float i)
			{
				point2 = float2(
					x + rand1d(x, -0.02, 0.02),
					y + rand1d(y, -0.02, 0.02));

				float r = 0.8 * distance(point2, point1);

				// rotate the star in a ellipsoid
				point2 = r * rotate(rand1d(x, 2.0, 5.0), _Time.y * speed, point2) + point1;

				color += light_point(coord + point2, 0.8 * brightness);

				if (frac(i / 10.0) == 0.0)
				{
					color.r *= rand1d(0.2 * i, 3.1, 3.5);
					color.b *= rand1d(2.0 * i, 3.0, 3.5);
				}

				return color;
			}


			//the fragment shader function
			fixed4 frag(v2f i) : SV_TARGET
			{
				// translate coords
				float2 coord = translate(i.uv, float2(0.0, 0.0));

				float3 color = float3(0.0, 0.0, 0.0);

				// generate random values to place stars in
				for (float i = 1.0; i < 50.0; i++)
				{
					float value1 = rand1d(.2 * i, -0.8, 0.8);
					float value2 = rand1d(.2 * i + rand1d(.2 * i), -0.8, 0.8);

					float2 point1 = float2(value1, value2);

					float2 n_coord = rotate(0.25 * distance(point1, float2(0.0, 0.0)) * _Time.y,
						coord);

					float brightness = 40.0 * (0.5 *
						sin(.02 * PI * _Time.y * rand1d(value1, 1.0, 2.0)) + 0.6);

					color += light_point(n_coord + point1, brightness);

					// creates a star linked to the one we have
					if (rand1d(0.8 * i) >= 0.6)
					{
						float2 point2 = float2(0.0, 0.0);
						float speed = 2.0;
						color = bind_star(value1, value2, point1, point2,
							n_coord, color, brightness, speed, i);

						if (rand1d(0.9 * i) >= 0.5)
						{
							float2 point3 = float2(0.0, 0.0);
							color = bind_star(value1, value2, point2, point3,
								n_coord, color, brightness, 1.5 * speed, i);
						}

					}

					if (frac(i / 10.0) == 0.0)
					{
						color.r *= rand1d(0.2 * i, 0.2, 0.9);
						color.g *= rand1d(0.9 * i, 0.7, 0.8);
						color.b *= rand1d(2.0 * i, 0.3, 0.5);
					}
				}

				//return the final color to be drawn on screen
				return float4(color, 1.0);
			}

			ENDCG
		}
	}
}