
// Implementation of shock filter (upsampling algorithm)

Shader "Custom/ShockFilter" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }
		_shockMagnitude("ShockMagnitude", Float) = 0.05
		_xDestSize("XDestSize", Float) = 1.0
		_yDestSize("YDestSize", Float) = 1.0
		_dimension ("Dimension", Float) = 512
	}

	SubShader 
	{
		Pass   
		{
			CGPROGRAM
            #pragma target 3.0
			#pragma vertex vertex_program
			#pragma fragment fragment_program			
			#include "UnityCG.cginc"

			sampler2D _MainTex;
			float _dimension;
			float _shockMagnitude;
			float _xDestSize;
			float _yDestSize;
			float4 _MainTex_ST;
			
			struct v2f 
			{
				float4  pos : SV_POSITION;
				float2  uv : TEXCOORD0;
			};
            
			v2f vertex_program (appdata_base v)
			{
				v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
			}
			
			float4 fragment_program (v2f i) : COLOR
			{  
				float4 ones = float4(1.0);
				float2 destSize = float2(_xDestSize, _yDestSize);
				float3 inc = float3(1.0/destSize/_dimension, 0.0); // could be a uniform

				float4 curCol = tex2D(_MainTex, i.uv);
				float4 upCol = tex2D(_MainTex, i.uv + inc.zy);
				float4 downCol = tex2D(_MainTex, i.uv - inc.zy);
				float4 rightCol = tex2D(_MainTex, i.uv + inc.xz);
				float4 leftCol = tex2D(_MainTex, i.uv - inc.xz);
				float4 Convexity = 4.0 * curCol - rightCol - leftCol - upCol - downCol;
				float2 diffusion = float2(dot((rightCol - leftCol) * Convexity, ones),
					dot((upCol - downCol) * Convexity, ones));
				diffusion *= _shockMagnitude/(length(diffusion) + 0.0); // 0.00001

				curCol += (diffusion.x > 0 ? diffusion.x * rightCol :
					-diffusion.x*leftCol) +
					(diffusion.y > 0 ? diffusion.y * upCol :
					-diffusion.y * downCol);

				return curCol / (1 + dot(abs(diffusion), ones.xy));
			}
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}