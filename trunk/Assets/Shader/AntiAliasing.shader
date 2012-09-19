
// GPU Gems 2 ~ A Quasi-Optimal Antialiasing Pixel Shader
// warning this shader only can be used on DirectX since OpenGL doesn't support ddx or ddy


Shader "Custom/AntiAliasing" 
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
			#pragma only_renderers d3d9
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			
			bool doTest;
			int2 texSize;
			const int SAMPLES = 5;  // should be an odd number
			const int START_SAMPLE = -2; // = -(SAMPLES-1)/2			
			sampler2D _MainTex;
			
			// Compute the inverse of a 2-by-2 matrix
			float2x2 inverse (float2x2 M)
			{

			  return float2x2(M[1][1], -M[0][1], -M[1][0], M[0][0]) / determinant(M);

			}
			
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
			
			float4 frag (v2f fi) : COLOR
			{				
				float2 texWidth = fwidth(fi.uv);
				//float4 color = float4(0, 0, 0, 0);
				float2 texStep = texWidth / SAMPLES;
				float2 pos = START_SAMPLE * texStep;
				float2x2 J = transpose(float2x2(ddx(fi.uv), ddy(fi.uv)));
				float rr, gg, bb, aa;
				
				float2x2 Jinv = inverse(J);

				for (int i = 0; i < SAMPLES; i++, pos.x += texStep.x)
				{
					pos.y = START_SAMPLE * texStep.y;
					
					for(int j = 0; j < SAMPLES; j++)
					{
						float2 test = abs(mul(Jinv, pos));
						
						if (test.x < 0.5 && test.y < 0.5)
						{  
						
							float4 colVal = tex2D(_MainTex, fi.uv + pos);
							rr += colVal[0]; 
							gg += colVal[1];
							bb += colVal[2];
							aa += 1.0;
						}
						
						pos.y += texStep.y;
					}
				}	
				
				//float4 color = float4(rr, gg, bb, aa);
				float4 color = float4(0, 0, 0, 0);
				return color / (color.a);
			
                //float4 col = tex2D(_MainTex, float2(i.uv.x, i.uv.y));				
				//return col;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}

