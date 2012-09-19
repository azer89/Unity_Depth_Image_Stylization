Shader "Fruit Effect/FruitDest"
{
	Properties
	{
		_MainTex ("Main Texture (RGBA)", 2D) = "black" {}
		_SubTex ("Sub Texture (RGBA)", 2D) = "black" {}
	}
	
	SubShader
	{
        Tags { "RenderType"="Transparent" }

		Pass
		{
            CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			sampler2D _SubTex;
			float4 _MainTex_ST;

			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert (appdata_base v)
			{
				v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
			}

			half4 frag( v2f i ) : COLOR
			{
				half4 c = tex2D(_MainTex, i.uv.xy);
				half4 c2 = tex2D(_SubTex, i.uv.xy);

				if(c.a < 0.5)
					c = lerp(c2, c, c.a);

                return c;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
