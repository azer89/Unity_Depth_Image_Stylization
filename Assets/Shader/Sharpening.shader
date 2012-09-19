
// 3x3 Sharpening filter

Shader "Custom/Sharpening" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }
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
                float3x3 kernel = {0, -1,  0, 
				                  -1,  5, -1, 
								   0, -1,  0};
								   
				float4 sum = float4(0.0);
				
                for(int x = 0; x < 3; x++)
                {
                    for(int y = 0; y < 3; y++)
                    {
						float k = kernel[x][y];
						
						float xMargin = min(max(0.0, i.uv.x + (x - 1) / _dimension), 1.0);
						float yMargin = min(max(0.0, i.uv.y + (y - 1) / _dimension), 1.0);
						 
                        float4 color = tex2D(_MainTex, float2(xMargin, yMargin));
						sum += color * k;
                    }
                }
                
				return sum;
			}
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}