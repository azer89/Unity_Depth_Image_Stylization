
// Two Passes Gaussian Blur

Shader "Custom/GaussianBlur02" 
{
	Properties 
	{
		blurSizeX("BlurSizeX", Float) = 0
		blurSizeY("BlurSizeY", Float) = 0
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
			
			float blurSizeX;
			float blurSizeY;
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
				half4 sum = half4(0.0);
				                
                sum += tex2D(_MainTex, float2(i.uv.x - 5.0 * blurSizeX, i.uv.y)) * 0.025;
                sum += tex2D(_MainTex, float2(i.uv.x - 4.0 * blurSizeX, i.uv.y)) * 0.05;
                sum += tex2D(_MainTex, float2(i.uv.x - 3.0 * blurSizeX, i.uv.y)) * 0.09;
                sum += tex2D(_MainTex, float2(i.uv.x - 2.0 * blurSizeX, i.uv.y)) * 0.12;
                sum += tex2D(_MainTex, float2(i.uv.x - blurSizeX, i.uv.y)) * 0.15;
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y)) * 0.16;
                sum += tex2D(_MainTex, float2(i.uv.x + blurSizeX, i.uv.y)) * 0.15;
                sum += tex2D(_MainTex, float2(i.uv.x + 2.0 * blurSizeX, i.uv.y)) * 0.12;
                sum += tex2D(_MainTex, float2(i.uv.x + 3.0 * blurSizeX, i.uv.y)) * 0.09;
                sum += tex2D(_MainTex, float2(i.uv.x + 4.0 * blurSizeX, i.uv.y)) * 0.05;
                sum += tex2D(_MainTex, float2(i.uv.x + 5.0 * blurSizeX, i.uv.y)) * 0.025;

				return sum;
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

            float blurSizeX;
			float blurSizeY;
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
				half4 sum = half4(0.0);
				 
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y - 5.0 * blurSizeY)) * 0.025;
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y - 4.0 * blurSizeY)) * 0.05;
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y - 3.0 * blurSizeY)) * 0.09;
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y - 2.0 * blurSizeY)) * 0.12;
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y - blurSizeY)) * 0.15;
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y)) * 0.16;
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y + blurSizeY)) * 0.15;
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y + 2.0 * blurSizeY)) * 0.12;
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y + 3.0 * blurSizeY)) * 0.09;
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y + 4.0 * blurSizeY)) * 0.05;
                sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y + 5.0 * blurSizeY)) * 0.025;

				return sum;
			}
            ENDCG

        }
	}
	
	Fallback "VertexLit"
}
