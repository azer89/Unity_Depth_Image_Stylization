
// Unlit alpha-cutout shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Custom/TransparentCutout" 
{
	Properties 
	{
		_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
		_Cutoff ("Alpha cutoff", Range(0, 1)) = 0.5
	}

	SubShader 
	{
		Pass 
        {
			//Lighting Off
			Alphatest Greater [_Cutoff]
			SetTexture [_MainTex] { combine texture } 
	    }
    }
}