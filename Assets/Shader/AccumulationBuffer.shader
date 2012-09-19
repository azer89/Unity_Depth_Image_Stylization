
// Adding temporal coherence based on accumulation of
// current texture and previous texture

// _BlendValue == 0, texture not updated at all
// _BlendValue == 1, previous texture is ignored

Shader "Custom/AccumulationBuffer"  
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }		// current texture
		_OldTexture ("Texture", 2D) = "white" { }	// previous texture
		_BlendValue("Threshold", Range(0.0, 1.0)) = 1.0
	}

	SubShader 
	{
		Pass 
		{
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			sampler2D _OldTexture;
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
			
			half4 frag (v2f i) : COLOR
			{				
				half4 one = tex2D(_MainTex, float2(i.uv.x, i.uv.y));
				half4 two = tex2D(_OldTexture, float2(i.uv.x, i.uv.y));
								
				half4 res = _BlendValue * one + (1.0 - _BlendValue) * two;
				return res;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
