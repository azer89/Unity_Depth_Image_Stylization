
Shader "Custom/GaussianBlur" 
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
			#include "GaussianUtilities.cginc"
			
			sampler2D _MainTex;
			
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
				return Gaussian1D9x9(_MainTex, i.uv, float2(1, 0), float2(1024.0, 512.0));
			}
			ENDCG
		}
		
		Pass 
		{
			CGPROGRAM
            #pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			#include "GaussianUtilities.cginc"
			
			sampler2D _MainTex;
			
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
				return Gaussian1D9x9(_MainTex, i.uv, float2(0, 1), float2(1024.0, 512.0));
			}
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
