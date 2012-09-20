
Shader "Custom/ColorIntensity" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }	// RGB Image
		_sigma ("Domain Sigma", Float) = 1.0
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
			float _sigma;
			
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
				
				float _sigma2 = _sigma * _sigma;  
				float _sigma2_2 = _sigma2 * 2.0;
				
				float4 inten1 = tex2D(_MainTex, i.uv);
				float4 inten2 = float4(0.0);
				
				for(int iter = 0; iter < 25; iter++)
				{
					inten2 = tex2D(_MainTex, float2(i.uv.x + xd[iter], i.uv.y + yd[iter]));
					float4 dist = inten1 - inten2;
					dist = dist * dist;
					float4 inten = 	exp(-1.0 * dist / _sigma2_2);				
					
					inten1 += inten;
				}
				
				return inten1;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}