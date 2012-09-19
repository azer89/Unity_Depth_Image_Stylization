
// Bilinear filter
// Grayscale version only works on alpha channel

Shader "Custom/BilinearAlpha" 
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
				float texelSize = 2.0 / textureSize; 	//size of one texel 
			
				float resVal = 0.0;
				// in vertex shaders you should use texture2DLod instead of texture2D
				float tl = tex2D(_MainTex, i.uv).w;
				float tr = tex2D(_MainTex, i.uv + float2(texelSize, 0.0)).w;
				float bl = tex2D(_MainTex, i.uv + float2(0.0, texelSize)).w;
				float br = tex2D(_MainTex, i.uv + float2(texelSize , texelSize)).w;
				float2 f = frac( i.uv * textureSize ); 	// get the decimal part
				float4 tA = lerp( tl, tr, f.x ); 			// will interpolate the red dot in the image
				float4 tB = lerp( bl, br, f.x ); 			// will interpolate the blue dot in the image
				resVal = lerp( tA, tB, f.y ); 				// will interpolate the green dot in the image
				  
				return float4(float3(0.0), resVal);
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
