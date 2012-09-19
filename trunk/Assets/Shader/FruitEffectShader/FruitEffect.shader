Shader "Fruit Effect/FruitEffect"
{
	Properties
	{
		_MainTex ("Base (RGBA)", 2D) = "black" {}
		_FadeOut ("FadeOut Factor", Range(0, 0.1)) = 0.0625
		_AlphaLimit ("Alpha Limit", Range(0, 1.0)) = 0.2
		_ScaleX ("ScaleX", Range(0, 0.05)) = 0.05
		_ScaleY ("ScaleY", Range(0, 0.05)) = 0.05
		_Color1 ("Color1 (RGB)", Color) = (1, 1, 1, 1)
		_Color2 ("Color2 (RGB)", Color) = (0, 0.5, 1, 1)
		_Time1 ("Color1 Time", Float) = 0.9
		_Time2 ("Color2 Time", Float) = 0.1
		//_BlurAmount ("Blur Amount", Float) = 1.0
	}
	SubShader
	{
		//Tags { "RenderType"="Transparent" }
		// 畫上一個Frame, 但是Alpha調淡
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
			float4 _MainTex_ST;
			float _FadeOut;
			float _AlphaLimit;
			float _ScaleX;
			float _ScaleY;
			//float _BlurAmount
			
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
				
				// UV Scale
				o.uv.x = (o.uv.x - 0.5) * (1.0 - _ScaleX) + 0.5;
				o.uv.y = o.uv.y * (1.0 - _ScaleY);
				return o;
			}

			half4 frag( v2f i ) : COLOR
			{
				half4 c = tex2D (_MainTex, i.uv.xy);

				// Alpha衰減
				c.a =  saturate(c.a - _FadeOut);

				// Alpha Limit
				if(c.a < _AlphaLimit)
					c = 0;

				return c;
			}

			ENDCG
		}

		// 畫出這Frame的人影
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color1;
			float4 _Color2;
			float _Time1;
			float _Time2;

			
			struct v2f 
			{
				float4  pos : SV_POSITION;
				float2  uv : TEXCOORD0;
				float4 color : COLOR0;
			};

			v2f vert (appdata_base v)
			{				
				v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

				float fracTime = fmod(_Time.y, _Time1 + _Time2);
				float f = smoothstep(0, _Time1, fracTime);
				o.color = lerp(_Color1, _Color2, f);

				return o;
			}

			half4 frag( v2f i ) : COLOR
			{
				half4 c = tex2D(_MainTex, i.uv.xy);
				c.rgb = i.color.rgb;

				if(c.a > 0.1) c.a = i.color.a;

				return c;
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}
