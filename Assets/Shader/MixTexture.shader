
// Blending of two textures by using weighted factors

Shader "Custom/MixTexture" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }
		_OldTexture ("Texture", 2D) = "white" { }		
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
				float4 sum = float4(0.0);
				
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y)) * 0.2;
				sum += tex2D(_OldTexture, float2(i.uv.x, i.uv.y)) * 0.8;
				
				return sum;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
