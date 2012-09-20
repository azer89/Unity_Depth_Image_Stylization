
// 5x5 Mean Filter

Shader "Custom/MeanFilter5x5" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }	 
		//_dimension ("Dimension", Float) = 512
	}

	SubShader 
	{
		Pass   
		{            
			CGPROGRAM
            #pragma target 3.0
			#pragma vertex vertex_program
			#pragma fragment fragment_program			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			
			struct v2f 
			{
				float4  pos : SV_POSITION;
				float2  uv : TEXCOORD0;
			};
			
			//float _dimension;
			//float4 _backgroundColor;
			//float4 _foregroundColor;
			float4 _MainTex_ST;
            
			v2f vertex_program (appdata_base v)
			{
				v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
			}
			
			float4 fragment_program (v2f i) : COLOR
			{
				float xs[25] = {
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
				
				float ys[25] = {
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
				
				float4 sum = float4(0.0);
				
				for(int iter = 0; iter < 25; iter++)
                {						
					sum += tex2D(_MainTex, float2(i.uv.x + xs[iter], i.uv.y + ys[iter]));
				}
				
				sum /= 25.0;
				
				return sum;
				
			}
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}