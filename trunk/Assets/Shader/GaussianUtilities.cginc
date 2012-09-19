
// Upgrade NOTE: excluded shader from Xbox360 and OpenGL ES 2.0 because it uses unsized arrays
#pragma exclude_renderers xbox360 gles

static float offset9x9[3] = {0.0, 1.3846153846, 3.2307692308};
static float weight9x9[3] = {0.2270270270, 0.3162162162, 0.0702702703};

//static float offset9x9[5] = {0.0, 1.0, 2.0, 3.0, 4.0};
//static float weight9x9[5] = {0.2270270270, 0.1945945946, 0.1216216216, 0.0540540541, 0.0162162162};

float4 Gaussian1D9x9(in sampler2D source,
					 in float2 center,
					 in float2 direction,
					 in float2 dimension) 
{
	float4 col = tex2D(source, center);
	float4 blended_color = col * weight9x9[0];
	//return blended_color;
    for (int i=1; i<3; ++i) {
        blended_color += tex2D(source, center + (offset9x9[i] * direction /dimension)) * weight9x9[i];
        blended_color += tex2D(source, center - (offset9x9[i] * direction /dimension)) * weight9x9[i];
    }
	
	/*for(int i = 1; i < 5; ++i) {
		blended_color += tex2D(source, center + (offset9x9[i] * direction /dimension)) * weight9x9[i];
        blended_color += tex2D(source, center - (offset9x9[i] * direction /dimension)) * weight9x9[i];
	}*/
	
	return blended_color;
}