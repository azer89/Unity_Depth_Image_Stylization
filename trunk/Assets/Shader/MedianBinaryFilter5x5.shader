
/*
 * Project: UnityKinect
 * Reza Adhitya Saputra
 */
 
 // Simple 3x3 Median Filter
 // Is still unoptimized since uses simple looping

Shader "Custom/MedianBinaryFilter5x5" 
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
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			float _dimension;
			float4 _backgroundColor;
			float4 _foregroundColor;
			float4 _MainTex_ST;
			
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
                return o;
			}
			
			float4 frag (v2f i) : COLOR
			{
				half bNum = 0.0;
				half fNum = 0.0;
				float4 colVal = float4(0.0);
				
				for(int x = 0; x < 3; x++)
                {
                    for(int y = 0; y < 3; y++)
                    {
						float xMargin = i.uv.x + (x - 1) / _dimension;
						float yMargin = i.uv.y + (y - 1) / _dimension;
						
						float4 c = tex2D(_MainTex, float2(xMargin, yMargin));
						
						if(any(abs(c - _backgroundColor)))
						{
							fNum += 1;
						}
						else
						{
							bNum += 1;
						}
					}
				}
				
				if(bNum > fNum) colVal = _backgroundColor;
				else colVal = _foregroundColor;
				
				return colVal;
			}
			
			ENDCG
		}

	}
	
	Fallback "VertexLit"
}
