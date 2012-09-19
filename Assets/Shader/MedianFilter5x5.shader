
/*
 * Project: UnityKinect
 * Reza Adhitya Saputra
 *
 * note: only works on binary image
 */

Shader "Custom/MedianFilter5x5" 
{
	Properties 
	{ 
		// binary image input
		_MainTex ("Texture", 2D) = "white" { }	
		
		// need to know background RGBA value, other than this
		// must be foreground pixel
		_backgroundColor ("BackgroundColor", Color) = (0, 0, 0, 0)
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
			
				// warning, these precomputed coordinates are for
				// 512x 512 texture size
				float xs[25] = {
					-0.004882813,
					-0.004882813,
					-0.004882813,
					-0.004882813,
					-0.004882813,
					-0.002929688,
					-0.002929688,
					-0.002929688,
					-0.002929688,
					-0.002929688,
					-0.0009765625,
					-0.0009765625,
					-0.0009765625,
					-0.0009765625,
					-0.0009765625,
					0.0009765625,
					0.0009765625,
					0.0009765625,
					0.0009765625,
					0.0009765625,
					0.002929688,
					0.002929688,
					0.002929688,
					0.002929688,
					0.002929688
				};
				
				float ys[25] = {
					-0.004882813,
					-0.002929688,
					-0.0009765625,
					0.0009765625,
					0.002929688,
					-0.004882813,
					-0.002929688,
					-0.0009765625,
					0.0009765625,
					0.002929688,
					-0.004882813,
					-0.002929688,
					-0.0009765625,
					0.0009765625,
					0.002929688,
					-0.004882813,
					-0.002929688,
					-0.0009765625,
					0.0009765625,
					0.002929688,
					-0.004882813,
					-0.002929688,
					-0.0009765625,
					0.0009765625,
					0.002929688
				};
			
				half bNum = 0.0;
				half fNum = 0.0;
				float4 colVal = tex2D(_MainTex, i.uv);
				
				for(int iter = 0; iter < 25; iter++)
                {						
					float4 c = tex2D(_MainTex, float2(i.uv.x + xs[iter], i.uv.y + ys[iter]));
						
					if(any(abs(c - _backgroundColor)))
                    {
						fNum += 1;
					}
					else
					{
						bNum += 1;
					}
				}
				
				if(bNum > fNum) 
                    colVal = _backgroundColor;
				
				return colVal;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}


