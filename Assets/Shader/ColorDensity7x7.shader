
Shader "Custom/ColorDensity7x7" 
{
	Properties 
	{
		_MainTex ("Texture", 2D) = "white" { }	// RGB Image
		_sigma ("Domain Sigma", Float) = 1.0
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
			float _sigma;
			
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
				float _sigma2_2 = _sigma * _sigma * 2.0;				
				
				float4 accumDensity = float4(0.0); 
				float4 density1 = tex2D(_MainTex, i.uv);
				float4 density2 = float4(0.0);
				
				for(int xIter = 0; xIter < 7; xIter++)
				{
					for(int yIter = 0; yIter < 7; yIter++)
					{
						float2 uvCoord = float2((xIter - 3) / 1024.0, (yIter - 3) / 512.0);						    
						density2 = tex2D(_MainTex, i.uv + uvCoord);								
						float4 diff = density1 - density2;						
						float4 inten = 	exp(-1 * diff * diff / _sigma2_2);								
						accumDensity += inten;
					}
				}
				
				accumDensity /= (_sigma2_2 * 3.14159265359 * 49.0);				
				return accumDensity;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}