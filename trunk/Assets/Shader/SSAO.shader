
// Screen Space Ambient Occlusion

Shader "Custom/SSAO" 
{  
	Properties 
	{
		_MainTex ("Z Buffer", 2D) = "white" { }	
		norm_buffer ("Normal Buffer", 2D) = "white" { }	
		rand_buffer ("Random Texture", 2D) = "white" { }
		
		g_sample_rad ("Sample Radius", Float) = 1.0
		g_scale ("Scale", Float) = 1.0
		g_bias ("Bias", Float) = 0.0		
		contrast ("Contrast", Float) = 1.0
		brightness ("Brightness", Range(0.0, 1.0)) = 1.0
		discontinuity("Discontinuity", Range(0.0, 0.5)) = 0.0
	}

	SubShader
	{
		Pass 
		{		
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D norm_buffer;
			sampler2D rand_buffer;
			
			float g_sample_rad;		// sampling radius
			float g_scale;			// scale distance between occludee and occluder
			float g_bias;			// controls the width of occusion cone considered by the occludee
			float contrast;			// color contrast
			float brightness;		// color brightness
			float discontinuity;	// adding color discontinuity (color discretization)
						
			struct v2f 
			{
				float4  pos : SV_POSITION;
				float2  uv : TEXCOORD0;
			};
			
			float4 _MainTex_ST;
			
			v2f vert (appdata_base v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			float getPosition(float2 uv)
			{
				float4 c = tex2D(_MainTex, uv);
				return c[3];
			}
			
			float3 getNormal(float2 uv)
			{			
				return tex2D(norm_buffer, uv).xyz;
			}
			
			float2 getRandom(float2 uv)
			{	 
				/*	1024.0 x 512.0 is texture size
					64.0 is random texture size */
				return normalize(tex2D(rand_buffer, float2(uv.x * 1024.0, uv.y * 512.0) / 64.0).xy);
			}
						
			float doAmbientOcclusion(float2 uv, float2 coord, float p, float3 n)
			{
				float z = getPosition(uv + coord);
				float3 c1 = float3(0.0, 0.0, p);
				float3 c2 = float3(coord, z);
				float3 diff = c2 - c1;
				float d = length(diff) * g_scale;
				float3 v = normalize(diff);
				float ao = max(0.0, dot(n, v) - g_bias) * (1.0 / (1.0 + d));
				
				return ao;
			}
			
			
			float4 frag (v2f i) : COLOR
			{					
				float p = getPosition(i.uv);
				float3 n = getNormal(i.uv);
				float2 rand = getRandom(i.uv);
				float rad = g_sample_rad / p;
				
				// precomputed value for texture size 1024x512
				float2 vec[4] = {float2(0.0009765625, 0.0),
								 float2(-0.0009765625, 0.0),
								 float2(0.0, 0.001953125),
								 float2(0.0, -0.001953125)};
				
				float ao = 0.0;				
				int iter = 4;
				float2 coord1 = float2(0.0);
				float2 coord2 = float2(0.0);
				
				for (int a = 0; a < iter; ++a)
				{
					coord1 = reflect(vec[a], rand) * rad;
					coord2 = float2(coord1.x * 0.7071067811 - coord1.y * 0.7071067811,
								    coord1.x * 0.7071067811 + coord1.y * 0.7071067811);
					
					ao += doAmbientOcclusion(i.uv, coord1, p, n);
					ao += doAmbientOcclusion(i.uv, coord2, p, n);
					ao += doAmbientOcclusion(i.uv, coord1 * 0.5, p, n);
					ao += doAmbientOcclusion(i.uv, coord2 * 0.5, p, n);
				}
				
				ao /= ((float)iter * 3.0);	
				
				ao = ao * contrast + (1.0 - brightness);				
				
				if(discontinuity > 0.0)
				{
					float remainder = fmod(ao, discontinuity);
					ao -= remainder;
				}
				
				ao = clamp(ao, 0.0, 1.0);
				
				return float4(0.0, 0.0, 0.0, 1.0 - ao);				
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
