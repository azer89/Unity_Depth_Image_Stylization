
// Implementation of 3x3 Morphological Dilation operator
// note: only works on binary image

Shader "Custom/MorphologicalDilation" 
{
	Properties 
	{
		
		_MainTex ("Texture", 2D) = "white" { }	 
        _backgroundColor ("BackgroundColor", Color) = (0, 0, 0, 0)
        _foregroundColor ("ForegroundColor", Color) = (0, 0, 0, 0)
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
			
			struct v2f 
			{
				float4  pos : SV_POSITION;
				float2  uv : TEXCOORD0;
			};
			
			float _dimension;
			float4 _backgroundColor;
			float4 _foregroundColor;
			float4 _MainTex_ST;
            
			v2f vertex_program (appdata_base v)
			{
				v2f o;
                o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
			}
			
			float4 fragment_program (v2f i) : COLOR
			{   
                float3x3 kernel = {0, 1, 0, 
				                   1, 1, 1, 
								   0, 1, 0};
								   
                float4 colorval = _backgroundColor;
				
                for(int x = 0; x < 3; x++)
                {
                    for(int y = 0; y < 3; y++)
                    {
						float k = kernel[x][y];
						
						float xMargin = i.uv.x + (x - 1) / _dimension;
						float yMargin = i.uv.y + (y - 1) / _dimension;
						 
                        float4 c = tex2D(_MainTex, float2(xMargin, yMargin));
						   
                        if(k == 1 &&
							c[0] == _foregroundColor[0] && 
							c[1] == _foregroundColor[1] && 
							c[2] == _foregroundColor[2] && 
							c[3] == _foregroundColor[3])
                        {
							colorval = _foregroundColor;
                        }  
                    }
                }
                
				return colorval;
			}
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}