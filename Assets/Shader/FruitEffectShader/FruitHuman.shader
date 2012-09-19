Shader "Fruit Effect/FruitHuman"
{
	Properties
	{
		_MainTex ("Base Texture (RGBA)", 2D) = "black" {}
		_FadeFactor ("Fade Factor", Float) = 0.25
	}
	SubShader
	{
		//Tags { "RenderType"="Transparent" }
		// 畫出上Frame的人影
		Pass
		{
			//Cull back
			//ZWrite off
			//Lighting Off
			//Fog { Color (0,0,0,0) }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _FadeFactor;
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
			
			half4 frag( v2f i ) : COLOR
			{
				half4 c = tex2D( _MainTex, i.uv.xy);

				// Fade
				c.a = saturate(c.a - _FadeFactor);
				return c;
			}

			ENDCG
		}

		// 畫出這Frame的人影
		Pass
		{			
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			//sampler2D _PrevTex;
			//float _BlurAmount;
			
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
				
				o.uv.x *= 0.625;   //< (320/512)
				o.uv.y *= 0.46875; //< (240/512)
				
				return o;
			}

			half4 frag( v2f i ) : COLOR
			{
				half4 c = tex2D(_MainTex, i.uv.xy);
				return c;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
