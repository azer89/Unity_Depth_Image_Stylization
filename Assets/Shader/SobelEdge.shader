
// Sobel Edge Detection on depth map

Shader "Custom/SobelEdge" 
{
	Properties 
	{
		_MainTex ("Main Texture", 2D) = "white" { }	// depth map input
		_SearchRange("Normal Search Range", Float) = 2.0
		_Threshold("Threshold", Float) = 0.005
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
			float _SearchRange;
			float _Threshold;
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
				float xStep = _SearchRange / 1024.0;
				float yStep = _SearchRange / 512.0;
				
				float d_t = tex2D(_MainTex, float2(i.uv.x, i.uv.y -  yStep)).w;
				float d_r = tex2D(_MainTex, float2(i.uv.x + xStep, i.uv.y)).w;
				float d_b = tex2D(_MainTex, float2(i.uv.x, i.uv.y +  yStep)).w;
				float d_l = tex2D(_MainTex, float2(i.uv.x -  xStep, i.uv.y)).w;
				
				float d_tl = tex2D(_MainTex, float2(i.uv.x - xStep, i.uv.y - yStep)).w;
				float d_tr = tex2D(_MainTex, float2(i.uv.x + xStep, i.uv.y - yStep)).w;
				float d_bl = tex2D(_MainTex, float2(i.uv.x - xStep, i.uv.y + yStep)).w;
				float d_br = tex2D(_MainTex, float2(i.uv.x + xStep, i.uv.y + yStep)).w;
				
				/*
					-1  0  1
					-2  0  2
					-1  0  1				
				*/
				float dx = d_tr + 2.0 * d_r + d_br - d_tl - 2.0 * d_l - d_bl;
				
				/*
					-1 -2 -1
					 0  0  0
					 1  2  1
				*/
				float dy = d_bl + 2.0 * d_b + d_br - d_tl - 2.0 * d_t - d_tr; 
				
				float val = dx * dx + dy * dy;
				
				float edge = 0.0;					// line (black)
				if(val < _Threshold) edge = 1.0;	// background (white)				
				return float4(float3(0.0), edge);	// save it to alpha channel
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
