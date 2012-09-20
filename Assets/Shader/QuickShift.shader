
Shader "Custom/QuickShift" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }	// RGB Image	
		_IntensityTex ("Texture", 2D) = "white" { }	// Intensity Image
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
			sampler2D _IntensityTex;
			
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
				float xd[25] = {
					-0.001953125,
					-0.001953125,
					-0.001953125,
					-0.001953125,
					-0.001953125,
					-0.000976563,
					-0.000976563,
					-0.000976563,
					-0.000976563,
					-0.000976563,
					0.0,
					0.0,
					0.0,
					0.0,
					0.0,
					0.000976563,
					0.000976563,
					0.000976563,
					0.000976563,
					0.000976563,
					0.001953125,
					0.001953125,
					0.001953125,
					0.001953125,
					0.001953125
				};
				
				float yd[25] = {
					-0.00390625,
					-0.001953125,
					0.0,
					0.001953125,
					0.00390625,
					-0.00390625,
					-0.001953125,
					0.0,
					0.001953125,
					0.00390625,
					-0.00390625,
					-0.001953125,
					0.0,
					0.001953125,
					0.00390625,
					-0.00390625,
					-0.001953125,
					0.0,
					0.001953125,
					0.00390625,
					-0.00390625,
					-0.001953125,
					0.0,
					0.001953125,
					0.00390625
				};
				
				float4 inten1 = tex2D(_IntensityTex, float2(i.uv.x, i.uv.y));	
				float4 inten2 = float4(0.0);
				float4 col1 = tex2D(_MainTex, float2(i.uv.x, i.uv.y));
				float4 col2 = float4(0.0);
				float dist = 1000.0;
				float intenDist1 = length(inten1);
				
				for(int iter = 0; iter < 25; iter++)
				{
					float2 uvCoord = float2(xd[iter], yd[iter]);
					
					inten2 = tex2D(_IntensityTex, i.uv + uvCoord);
					float intenDist2 = length(inten2);
					col2 = tex2D(_MainTex, i.uv + uvCoord);
					
					float d = distance(float2(0.0), uvCoord);
					
					if(intenDist2 > intenDist1 && d < dist)
					{
						intenDist1 = intenDist2;
						dist = d;
						//col1 = col2;
					}
				}
				
				return col1;
			}
			
			
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
