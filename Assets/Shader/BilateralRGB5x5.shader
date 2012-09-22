
// shader to smooth depth map using bilateral filter
// resulted value is saved in alpha channel

// this shader is only works on alpha channel
// although it can be easily modified to work with float3 or float4

Shader "Custom/BilateralRGB5x5Filter" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }	// depth map input
		domain_sigma ("Domain Sigma", Float) = 15
		range_sigma ("Range Sigma", Float) = 0.5
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
			float domain_sigma;      
			float range_sigma;    
			
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
			
			float4 frag (v2f i) : COLOR
			{	
				float d_sigma2 = domain_sigma * domain_sigma;  
				float d_sigma2_2 = d_sigma2 * 2.0;
				float d_sigma2_2_pi = d_sigma2_2 * 3.1415926;
				float r_sigma2 = range_sigma * range_sigma;
				
				float3 c1 = tex2D(_MainTex, i.uv).xyz;
				
				float3 colorSum  = float3(0.0);
				float3 sum = float3(0.0);
				float3 val = float3(0.0);
				
				float3 inten = float3(0.0);
				float3 c2 = float3(0.0);
				float dist = 0.0;
				float3 colorDif = float3(0.0);
				
				for(int xIter = 0; xIter < 5; xIter++)
				{
					for(int yIter = 0; yIter < 5; yIter++)
					{
						float2 uvCoord = float2((xIter - 2) / 1024.0, (yIter - 2) / 512.0);
						c2 = tex2D(_MainTex, i.uv + uvCoord).xyz;
						dist = length(float2(xIter, yIter));
						colorDif = c1 - c2;
						
						inten = exp(-1.0 * dist / d_sigma2_2) /
							d_sigma2_2_pi * 
							exp( (-1.0 * colorDif * colorDif/ r_sigma2));
						
						sum += inten ;
						colorSum += inten * c2;						
					}
				}
				
				val = colorSum / sum;
				
				return float4(val, 1.0);
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
