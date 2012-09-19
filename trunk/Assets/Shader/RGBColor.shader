
Shader "Custom/RGBColor" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }	
		_RGBTex ("RGB Texture", 2D) = "white" { }	
		_NormalTex ("Normal Texture", 2D) = "white" { }
		//_refColor ("Reflective Color", Color) = (0, 0, 0, 0)
		_backgroundColor ("BackgroundColor", Color) = (0, 0, 0, 0)	
		
		//normalStrength ("Normal Strength", Range(0.0, 1.0)) = 0.0
		brightness ("Brightness", Range(-1.0, 1.0)) = 0.0
		contrast ("Contrast", Range(0.0, 1.0)) = 0.0
		
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
			sampler2D _RGBTex;
			sampler2D _NormalTex;
			//float4 _refColor;
			float4 _backgroundColor;
			
			//float normalStrength;			
			float contrast;			// color contrast adjustment
			float brightness;		// color brightness adjustment
			
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
				float4 mask = tex2D(_MainTex, float2(i.uv.x, i.uv.y));	
				float4 rgbCol = tex2D(_RGBTex, float2(i.uv.x, i.uv.y));				
				float4 col = _backgroundColor;
				
				float3 n = tex2D(_NormalTex, float2(i.uv.x, i.uv.y)).xyz;
				float3 v = float3(0.0, 0.0, 1.0);
				float dotNV = dot(n, v);
				
				if(any(mask - _backgroundColor))	// is it foreground ?
				{
					col = rgbCol;
					col = col * contrast + brightness;
					col = lerp(col, rgbCol, dotNV);
					col.w = mask.w;
				}
				
				return col;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
