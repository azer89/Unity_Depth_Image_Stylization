
// Manipulate value of depth data using smoothstep (easing)

Shader "Custom/Smoothstep" 
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
			
			float smoothstep(float x)
			{
				return x * x * (3 - 2 * x);
			}
			
			float4 frag (v2f i) : COLOR
			{				
                float4 col = tex2D(_MainTex, float2(i.uv.x, i.uv.y));	
				
				float a = col[3];	// the depth data is saved in alpha channel				
				a = smoothstep(a);				
				col[3] = a;
				
				return col;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
