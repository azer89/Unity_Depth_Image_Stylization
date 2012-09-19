
Shader "Custom/OpticalFlowHornSchunck" 
{
	Properties 
	{
		_MainTex ("Current Texture", 2D) = "white" { }	
		_PrevTex ("Previous Texture", 2D) = "white" { }
		_lambda("Lambda", Float) = 0.1
		_offset("Offset", Float) = 1.0
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
			sampler2D _PrevTex;
			float _lambda;
			float _offset;
			
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
				
				float texOffset = _offset / 512.0;
				
				float2 nx = float2(texOffset, 0.0);
				float2 ny = float2(0.0, texOffset);
				float2 uvCoordinate = float2(i.uv.x, i.uv.y);
				
				float4 a = tex2D(_MainTex, uvCoordinate);
				float4 b = tex2D(_PrevTex, uvCoordinate);
				
				float4 currentDifference = a - b;
				
				
				float4 col = float4(1.0, 0.0, 0.0, 1.0);
				if(any(currentDifference)) col = float4(0.0, 1.0, 0.0, 1.0);
				
				
				float4 gradientX = ((tex2D(_MainTex, uvCoordinate + nx) - 
									 tex2D(_MainTex, uvCoordinate - nx)) + 
									(tex2D(_PrevTex, uvCoordinate + nx) - 
									 tex2D(_PrevTex, uvCoordinate - nx))) / 2.0;
				float4 gradientY = ((tex2D(_MainTex, uvCoordinate + ny) - 
									 tex2D(_MainTex, uvCoordinate - ny)) + 
									(tex2D(_PrevTex, uvCoordinate + ny) - 
									 tex2D(_PrevTex, uvCoordinate - ny))) / 2.0;
									 
				float4 gradientMagnitude = sqrt((gradientX * gradientX) +
												(gradientY * gradientY) +
												float4(_lambda, _lambda, _lambda, _lambda));
												
				float4 gX = gradientX / gradientMagnitude;
				float4 gY = gradientY / gradientMagnitude;				
				
				float4 velocityX = currentDifference * gX;
				float4 velocityY = currentDifference * gY;
				float4 velocity = (velocityX + velocityY) / 2.0; 
				
				return velocity;
			}
			
			ENDCG
		}
	}
	
	Fallback "VertexLit"
}
