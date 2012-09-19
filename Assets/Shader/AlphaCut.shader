
// This shader will discard fragment which 
// has alpha within threshold (by making the alpha equal to zero) 

Shader "Custom/AlphaCut" 
{
	Properties 
	{
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Cutoff ("Alpha Threshold", Range(0, 1)) = 0.5
		_AlphaValue("Final Alpha Value", Range(0, 1)) = 0.75
	}

	SubShader 
	{
		Pass 
		{
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float _Cutoff;
			float _AlphaValue;
			
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
				float4 col = tex2D(_MainTex, float2(i.uv.x, i.uv.y));
				if(col[3] <= _Cutoff) col[3] = 0.0;
				else if(_Cutoff != 0.0) col[3] = _AlphaValue;

				return col;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
