
// Bilinear filter

Shader "Custom/Bilinear" 
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
			
			float4 frag (v2f i) : COLOR
			{			
				float textureSize = 512.0; 				//size of the texture
				float texelSize = 1.0 / textureSize; 	//size of one texel 
			
				float4 resVal = float4(0.0);
				// in vertex shaders you should use texture2DLod instead of texture2D
				float4 tl = tex2D(_MainTex, i.uv);
				float4 tr = tex2D(_MainTex, i.uv + float2(texelSize, 0.0));
				float4 bl = tex2D(_MainTex, i.uv + float2(0.0, texelSize));
				float4 br = tex2D(_MainTex, i.uv + float2(texelSize , texelSize));
				float2 f = frac( i.uv.xy * textureSize ); 	// get the decimal part
				float4 tA = lerp( tl, tr, f.x ); 			// will interpolate the red dot in the image
				float4 tB = lerp( bl, br, f.x ); 			// will interpolate the blue dot in the image
				resVal = lerp( tA, tB, f.y ); 				// will interpolate the green dot in the image
				  
				return resVal;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
