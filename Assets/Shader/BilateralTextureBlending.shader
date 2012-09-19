
// Blending between two textures

Shader "Custom/BilateralTextureBlending"  
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }
		_OldTexture ("Texture", 2D) = "white" { }
		_BlendValue("Blending Value", Range(0.0, 1.0)) = 1.0
		_TimeDelta("TimeDelta", Float) = 0.0
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
			sampler2D _OldTexture;
			float _TimeDelta;
			float domain_sigma;      
			float range_sigma;  
			float _BlendValue;
			
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
				float xd[9] = {
					-0.001953125,
					-0.001953125,
					-0.001953125,
					0,
					0,
					0,
					0.001953125,
					0.001953125,
					0.001953125
				};
				
				float yd[9] = {
					-0.001953125,
					0,
					0.001953125,
					-0.001953125,
					0,
					0.001953125,
					-0.001953125,
					0,
					0.001953125
				};
				
				float preDist[9] = {
					0.002762136,
					0.001953125,
					0.002762136,
					0.001953125,
					0,
					0.001953125,
					0.002762136,
					0.001953125,
					0.002762136
				};
			
				
				float pi = 3.14159265359;				
				
				float d_sigma2 = domain_sigma * domain_sigma;  
				float d_sigma2_2 = d_sigma2 * 2.0;
				float d_sigma2_2_pi = d_sigma2_2 * pi;
				float r_sigma2 = range_sigma * range_sigma * 2.0;
				float one_per_r_sigma2 = 1.0 / r_sigma2; 
				
				float4 c = tex2D(_MainTex, float2(i.uv.x, i.uv.y));
				float c1 = c.w;
				
				float colorSum  = 0.0;
				float sum = 0.0;
				float val = 0.0;
			 
				float inten = 0.0;
				float c2 = 0.0;
				float dist = 0.0;
				float colorDif = 0;									
								
				// current frame calculation
				for(int iter = 0; iter < 9; iter++)
                {
					c2 = tex2D(_MainTex, float2(i.uv.x + xd[iter], i.uv.y + yd[iter])).w;
					dist = preDist[iter];
					colorDif = abs(c1 - c2);
					
					inten = exp(-1.0 * dist / d_sigma2_2) * 
						one_per_r_sigma2 * 
						exp( (-1.0 * colorDif / (r_sigma2)));
 
					sum += inten ;
					colorSum += inten * c2;
				}
				
				
				c1 = tex2D(_OldTexture, float2(i.uv.x, i.uv.y)).w;
				
				// previous frame calculation
				for(int iter = 0; iter < 9; iter++)
                {
					c2 = tex2D(_OldTexture, float2(i.uv.x + xd[iter], i.uv.y + yd[iter])).w;
					dist = preDist[iter];
					colorDif = abs(c1 - c2);
					
					inten = exp(-1.0 * (dist + _TimeDelta * _BlendValue) / d_sigma2_2) * 
						one_per_r_sigma2 * 
						exp( (-1.0 * colorDif / (r_sigma2)));
 
					sum += inten ;
					colorSum += inten * c2;
				}
				
				val = colorSum / sum;
				
				return float4(c.xyz, val);
				
				//return float4(0.0);
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
