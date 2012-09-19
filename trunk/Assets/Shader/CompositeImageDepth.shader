
Shader "Custom/CompositeImage" 
{
	Properties 
	{
		_MainTex ("Main Texture", 2D) = "white" { }
		_ZTex ("Depth Buffer", 2D) = "white" { }
		_NormalBuffer ("Normal Buffer", 2D) = "white" { }
		_AOBuffer ("Ambient Occlusion Buffer", 2D) = "white" { }
		_ProjectedNormalBuffer ("Specular Normal Buffer", 2D) = "white" { }
		_color1 ("AO Color (SSAO effect only)", Color) = (0, 0, 0, 0)
		//_color2 ("Color #2", Color) = (0, 0, 0, 0)
	}

	SubShader 
	{
	
		// ---------- PASS #0 DOT NORMAL EFFECT ----------
		Pass 
		{		
			CGPROGRAM
            #pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;		// origin
			sampler2D _ZTex;
			sampler2D _ProjectedNormalBuffer;
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
				float4 col = float4(0.0);
                float4 tex = tex2D(_MainTex, float2(i.uv.x, i.uv.y));
				float4 projNormal = tex2D(_ProjectedNormalBuffer, float2(i.uv.x, i.uv.y));
				float alpha = tex2D(_ZTex, float2(i.uv.x, i.uv.y)).w;
								
				if(alpha > 0.0)
				{
					col = float4(projNormal[0], projNormal[1], projNormal[2], tex.w);
				}
				
				return col;
			}
			
			ENDCG
		}
		
		// ---------- PASS #1 RAW NORMAL EFFECT ----------
		Pass 
		{		
			CGPROGRAM
            #pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;		// origin
			sampler2D _ZTex;
			sampler2D _NormalBuffer;
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
				float4 col = float4(0.0);
                float4 tex = tex2D(_MainTex, float2(i.uv.x, i.uv.y));
				float4 normal = tex2D(_NormalBuffer, float2(i.uv.x, i.uv.y));
				float alpha = tex2D(_ZTex, float2(i.uv.x, i.uv.y)).w;
								
				if(alpha > 0.0)
				{
					col = float4(normal[0], normal[1], normal[2], tex.w);
				}
				
				return col;
			}
			
			ENDCG
		}
		
		// ---------- PASS #2 RAW DEPTH EFFECT ----------
		Pass 
		{		
			CGPROGRAM
            #pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;		// origin
			sampler2D _ZTex;
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
				float4 col = float4(0.0);
                float4 tex = tex2D(_MainTex, float2(i.uv.x, i.uv.y));
				float4 depth = tex2D(_ZTex, float2(i.uv.x, i.uv.y));
				float alpha = depth.w;
								
				if(alpha > 0.0)
				{
					col = float4(alpha, alpha, alpha, tex.w);
				}
				
				return col;
			}
			
			ENDCG
		}
		
		// ---------- PASS #3 RAW SSAO EFFECT ----------
		Pass 
		{		
			CGPROGRAM
            #pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;		// origin
			sampler2D _ZTex;
			sampler2D _AOBuffer;
			float4 _color1;			// AO Color
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
				float4 col = float4(0.0);
                float4 tex = tex2D(_MainTex, float2(i.uv.x, i.uv.y));
				float ao = tex2D(_AOBuffer, float2(i.uv.x, i.uv.y)).w;
				float alpha = tex2D(_ZTex, float2(i.uv.x, i.uv.y)).w;
				float3 aoCol = lerp(float3(1.0), _color1.xyz, 1.0 - ao);
								
				if(alpha > 0.0)
				{
					col = float4(aoCol, tex.w);
				}
				
				return col;
			}
			
			ENDCG
		}
		
		// ---------- PASS #4 COLOR SSAO EFFECT ----------
		Pass 
		{		
			CGPROGRAM
            #pragma target 3.0
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			
			sampler2D _MainTex;		// origin
			sampler2D _ZTex;
			sampler2D _AOBuffer;
			float4 _color1;			// AO Color
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
				float4 col = float4(0.0);
                float4 tex = tex2D(_MainTex, float2(i.uv.x, i.uv.y));
				float4 ao = tex2D(_AOBuffer, float2(i.uv.x, i.uv.y));
				float alpha = tex2D(_ZTex, float2(i.uv.x, i.uv.y)).w;
								
				if(alpha > 0.0)
				{					
				
					float3 rgb = tex.xyz;
					//float3 shadow = float3(ao.w);
					rgb = lerp(rgb, _color1, 1.0 - ao.w);
					col = float4(rgb, tex.w); 
				
				}
				
				return col;
			}
			
			ENDCG
		}
		
	}
	
	Fallback "VertexLit"
}
