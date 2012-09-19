
// Make foreground pixel (user mask) has specified alpha value
// since the texture pixel has depth data on alpha channel 

Shader "Custom/ResetAlpha" 
{
	Properties 
	{
		_MainTex ("Main Texture", 2D) = "white" { }
		_AlphaValue("Alpha Value", Range(0, 1)) = 0.75	
		_backgroundColor ("BackgroundColor", Color) = (0, 0, 0, 0)		
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
			
			sampler2D _MainTex;		// origin			
			float _AlphaValue;		// actual alpha
			float4 _backgroundColor;
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
                float4 col = tex2D(_MainTex, float2(i.uv.x, i.uv.y));				
				if(any(abs(col - _backgroundColor))) col[3] = _AlphaValue;				
				return col;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
