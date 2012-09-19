
// copied from http://glsl.heroku.com

Shader "Custom/LightDots" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }
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
			float4 _MainTex_ST;
			
			struct v2f 
			{
				float4  pos : SV_POSITION;
				float2  uv : TEXCOORD0;
			};
			  
			v2f vert (appdata_base v)
			{
				v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
			}
			
			float4 frag (v2f i) : COLOR
			{
				float4 colVal = float4(0.0);	
				
				float xtex = i.uv.x;
				float ytex = i.uv.y;
	
				/*
				float sinVal = 50.0 * sin(xtex * 30.0);
				float funcArgShift = -10.0;//adjusts width of the white center of the glow.
				float funcVal = abs(ytex * 800.0 - (512.0 * 0.5 + sinVal)) - funcArgShift;
				float intensity = 1000.0 / (funcVal * funcVal);
				*/
				
				float4 c = tex2D(_MainTex, float2(i.uv.x, i.uv.y));
				float intensity = c[0] * 0.8;
				
				//if(c[0] == 0.0) // white
				//{
				//	intensity = 1.0;
				//}
								
				float scaline = lerp(abs(sin(ytex * 100.0)), abs(sin(xtex * 100.0)), 0.5);		
				float3 color = float3(intensity * 0.125, intensity * 0.125, intensity * 0.5);
				color /= (scaline); 				
				colVal = float4(color, 1.0);
				
				//colVal = float4(0.5 * i.uv.y, 0.5 * i.uv.x, 0.0, 1.0);
				
				return colVal;
			}
			
			ENDCG
		}

	}
	
	Fallback "VertexLit"
}


