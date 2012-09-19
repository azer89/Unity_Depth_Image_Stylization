
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
				half step = _NormRange / 512.0;	// 512.0 is texture size
				half step2 = step * 0.7071067811;	// rotated 45 degrees
				half minStep = -step;
				half minStep2 = -step2;
				
				half d_t = tex2D(_MainTex, half2(i.uv.x, i.uv.y -  step)).w;	// top
				half d_r = tex2D(_MainTex, half2(i.uv.x + step, i.uv.y)).w;	// right
				half d_b = tex2D(_MainTex, half2(i.uv.x, i.uv.y +  step)).w;	// bottom
				half d_l = tex2D(_MainTex, half2(i.uv.x -  step, i.uv.y)).w;	// left
				
				half d_tl = tex2D(_MainTex, half2(i.uv.x - step2, i.uv.y -  step2)).w;	// topleft
				half d_tr = tex2D(_MainTex, half2(i.uv.x + step2, i.uv.y - step2)).w;	// topright
				half d_bl = tex2D(_MainTex, half2(i.uv.x - step2, i.uv.y +  step2)).w;	// bottomleft
				half d_br = tex2D(_MainTex, half2(i.uv.x +  step2, i.uv.y + step2)).w;	// bottomright
				
				half3 t = half3(0, minStep, d_t);
				half3 r = half3(step, 0, d_r);
				half3 b = half3(0, step, d_b);
				half3 l = half3(minStep, 0, d_l);
				
				half3 tl = half3(minStep2, minStep2, d_tl);
				half3 tr = half3(step2, minStep2, d_tr);
				half3 bl = half3(minStep2, step2, d_bl);
				half3 br = half3(step2,  step2, d_br);
				
				float3 normal = normalize(cross(t - b, r - l) + cross(tl - br, tr - bl));				
				return float4(normal, 1.0);	// save normal vector to RGB channel
				
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
