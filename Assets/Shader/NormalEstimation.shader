
// Normal estimation
// Taking 8 vector to build 4 tangential vectors
// and computer the normal vector

Shader "Custom/NormalEstimation" 
{
	Properties 
	{
		_MainTex ("Main Texture", 2D) = "white" { }
		_NormRange("Normal Search Range", Float) = 2.0
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
			
			sampler2D _MainTex;		// depth map input
			float _NormRange;		// make it bigger if you want smooth result
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
				//half step = _NormRange / 512.0;	// 512.0 is texture size
				//half step2 = step * 0.7071067811;	// rotated 45 degrees
				//half minStep = -step;
				//half minStep2 = -step2;
				
				half xStep = _NormRange / 1024.0;
				half yStep = _NormRange / 512.0;
				
				half xStep2 = xStep * 0.7071067811;	// rotated 45 degrees
				half yStep2 = yStep * 0.7071067811;	// rotated 45 degrees
				
				half xMinStep = -xStep;
				half yMinStep = -yStep;
				
				half xMinStep2 = -xStep2;
				half yMinStep2 = -yStep2;
				
				half d_t = tex2D(_MainTex, half2(i.uv.x, i.uv.y -  yStep)).w;	// top
				half d_r = tex2D(_MainTex, half2(i.uv.x + xStep, i.uv.y)).w;	// right
				half d_b = tex2D(_MainTex, half2(i.uv.x, i.uv.y +  yStep)).w;	// bottom
				half d_l = tex2D(_MainTex, half2(i.uv.x -  xStep, i.uv.y)).w;	// left
				
				half d_tl = tex2D(_MainTex, half2(i.uv.x - xStep2, i.uv.y -  yStep2)).w;	// topleft
				half d_tr = tex2D(_MainTex, half2(i.uv.x + xStep2,  i.uv.y - yStep2)).w;	// topright
				half d_bl = tex2D(_MainTex, half2(i.uv.x - xStep2,  i.uv.y + yStep2)).w;	// bottomleft
				half d_br = tex2D(_MainTex, half2(i.uv.x + xStep2,  i.uv.y + yStep2)).w;	// bottomright
				
				half3 t = half3(0, yMinStep, d_t);
				half3 r = half3(xStep, 0, d_r);
				half3 b = half3(0, yStep, d_b);
				half3 l = half3(xMinStep, 0, d_l);
				
				half3 tl = half3(xMinStep2, yMinStep2, d_tl);
				half3 tr = half3(xStep2, yMinStep2, d_tr);
				half3 bl = half3(xMinStep2, yStep2, d_bl);
				half3 br = half3(xStep2,  yStep2, d_br);
				
				float3 normal = normalize(cross(t - b, r - l) + cross(tl - br, tr - bl));				
				return float4(normal, 1.0);	// save normal vector to RGB channel				
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
