
Shader "Custom/EdgeSSAO" 
{
	Properties 
	{
		_MainTex ("Main Texture", 2D) = "white" { }
		_EdgeTex ("Edge Texture", 2D) = "white" { }
		_interpolation("Interpolation", Float) = 0.5
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
			
			float4 _MainTex_ST;
			sampler2D _MainTex;
			sampler2D _EdgeTex;
			float _interpolation;
			
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
				float ssao = tex2D(_MainTex, float2(i.uv.x, i.uv.y)).w;
				float edge = tex2D(_EdgeTex, float2(i.uv.x, i.uv.y)).w;
				
				float c = lerp(ssao, edge, _interpolation);
				
				return float4(float3(0.0), c);
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
