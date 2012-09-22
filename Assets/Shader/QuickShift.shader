
Shader "Custom/QuickShift" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }	// RGB Image	
		_DensityTex ("Density Texture", 2D) = "white" { }	// Intensity Image
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
			sampler2D _DensityTex;
			
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
				float densityDist1 = length(tex2D(_DensityTex, i.uv));
				float densityDist2 = 0.0;
				float4 col1 = tex2D(_MainTex, i.uv);
				float4 col2 = float4(0.0);
				float dist = 1000.0;
				float d =1000.0;
								
				for(int xIter = 0; xIter < 5; xIter++)
				{
					for(int yIter = 0; yIter < 5; yIter++)
					{						
						float2 uvCoord = i.uv + float2((xIter - 2) / 1024.0, (yIter - 2) / 512.0);						
						col2 = tex2D(_MainTex, uvCoord);
						densityDist2 = length(tex2D(_DensityTex, uvCoord));						
						d = distance(col1, col2);
						
						if(densityDist2 > densityDist1 && d < dist)
						{
							densityDist1 = densityDist2;
							dist = d;
							col1 = col2;
						}
					}
				}
				
				return col1;
			}
			
			
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
