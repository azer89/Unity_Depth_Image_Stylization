
Shader "Custom/MeanFilter3x3" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }
		_range("Sampling Range", Float) = 1.0
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
			float _range;    
			
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
			
			half4 frag (v2f i) : COLOR
			{	
				float xd[9] = {
					-0.000976563,
					-0.000976563,
					-0.000976563,
					0.0,
					0.0,
					0.0,
					0.000976563,
					0.000976563,
					0.000976563
				};
				
				float yd[9] = {
					-0.001953125,
					0.0,
					0.001953125,
					-0.001953125,
					0.0,
					0.001953125,
					-0.001953125,
					0.0,
					0.001953125
				};
				
				half4 colorSum = half4(0.0); 
												
				for(int iter = 0; iter < 9; iter++)
                {						
					half4 c = tex2D(_MainTex, float2(i.uv.x + xd[iter] * _range, i.uv.y + yd[iter] * _range));
					colorSum += c;
				}
				
				colorSum = colorSum / 9.0;
				
				return colorSum;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
