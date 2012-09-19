
// Interpolation between two colors using value of dot product of
// normal vector and (0.0, 0.0, 1.0)

Shader "Custom/SpecularNormal" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }				// this input should be normal map
		_ColorTex ("Color Texture", 2D) = "white" { }
		_color1 ("Lower Color", Color) = (0, 0, 0, 0)
		_color2 ("Reflective Color", Color) = (0, 0, 0, 0)
		//margin ("Margin", Range(0.0, 1.0)) = 0.0
		brightness ("Brightness", Range(-1.0, 1.0)) = 0.0
		contrast ("Contrast", Range(0.0, 1.0)) = 0.0
	}

	SubShader 
	{
		Pass 
		{
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			
			float4 _color1;
			float4 _color2;
			//float margin;
			float contrast;			// color contrast adjustment
			float brightness;		// color brightness adjustment
			sampler2D _MainTex;
			sampler2D _ColorTex;
			
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
			
			half4 frag (v2f i) : COLOR
			{			
				half3 v = half3(0.0, 0.0, 1.0);
                half3 n = tex2D(_MainTex, float2(i.uv.x, i.uv.y)).xyz;
				half4 playerColor = tex2D(_ColorTex, float2(i.uv.x, i.uv.y));
								
				half4 col = lerp(_color1, playerColor, smoothstep(smoothstep(i.uv.y)));
				col = lerp(col, _color2, dot(n, v));
				col = col * contrast + brightness;
				
				return col;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
