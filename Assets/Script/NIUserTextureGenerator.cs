
using System.Runtime.InteropServices;
using OpenNI;
using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading;

public class NIUserTextureGenerator : MonoBehaviour 
{
    public bool blurEnabled = true;                 // necessary for alpha cut, false means alpha cut disabled
    public int blurFactor = 2;                      // number of gaussian iteration
    public float alphaCutThreshold = 0.5f;          // alpha cut on the user mask edge
    public bool bilateralFilterEnabled = true;      // apply bilateral filter on depth map
    public int bilateralIteration = 1;              // number of bilateral iteration
    public bool acculumationBufferEnabled = false;	// temporal coherence
    public bool meanFilterEnabled = false;

    public ShaderEffect shaderEffect = ShaderEffect.SolidColor;

    public Material ssaoMat;                        // screen space ambient occlusion
    public Material bilateralAlphaMat;              // bilateral filter (grayscale on alpha channel)
    public Material bilateralRGBMat;
    public Material compositeImageMat;              // final compositing
    public Material normalEstimationMat;            // normal estimation
    public Material specularNormalMat;              // specular shading my manipulating surface normal
    public Material accumulationBufferMat;          // temporal coherence
    public Material meanMat;                     // smoothing 
    public Material rgbEffectMat;
    public Material enhanceDepthMat;
    public Material densityMat;
    public Material quickShiftMat;

    Material gaussianMat;   // Gaussian blur material
    Material userMapMat;    // Last pass (doing blending)

    RenderTexture renderTex01;          // intermediate buffer
    RenderTexture renderTex02;          // final texture will be in this buffer
    RenderTexture depthBufferTex;       // buffer which contains depth map
    RenderTexture normalBufferTex;      // buffer which contains normal map
    RenderTexture ssaoTex;              // buffer which contains ao map
    RenderTexture specularNormalTex;    // buffer of specular effect
    RenderTexture accBufferTex;         // temporal coherence
    RenderTexture rgbBufferTex;         // RGB texture
    RenderTexture densityBuffer;

    // Energy Effect --------------------
    //public RenderTexture humanTex;
    //public RenderTexture humanEffectTex;
    //public RenderTexture humanDestTex;
    //public Material humanGaussianMat;
    //public Material humanEffectMat;
    //public Material humanDestMat;
    // Energy Effect --------------------

    public Color32 backColor =      new Color32(255, 0, 0, 0);
    public Color32 player01Color =  new Color32(69, 127, 255, 255);
    public Color32 player02Color =  new Color32(116, 255, 116, 255);
    public Color32 player03Color =  new Color32(255, 181, 67, 255);

	NIPlayerManager playerManager;
	OpenNISettingsManager context;
	SceneMetaData sceneMetaData;    // for acquiring user mask
    ImageMetaData imageMetaData;    // for acquiring rgb image

    Texture2D userTexture;  // Texture to be displayed
    Texture2D rgbImage;     // RGB texture
    short[] rawUserMap;     // Raw user map, taken from OpenNI
    byte[] rawRGBMap;       // Raw RGB data
	Color32[] userMap;      // array contains user mask and depth map
    Color32[] rgbPixels;    // array contains RGB image

    short[] rawDepthMap;    // Raw depth map data
    float[] histogramMap;   // contain value of depth map

    int xResOri;            // original x size
	int yResOri;            // original y size
    int xResScaled;         // original divided by samplingFactor
    int yResScaled;         // original divided by samplingFactor 
    int xResPOT;
    int yResPOT;

    int xMargin;            // x-margin of POT texture
    int yMargin;            // y-margin of POT size
    int samplingFactor = 1; // scale down the texture

	private Material CreateMaterial()
	{
		Shader defaultShader = Shader.Find("Unlit/Texture");
		Material mat = new Material(defaultShader);
		return mat;
	}
    
    // This function is only called once after being initialized
	void Start() 
    {
        //DebugConsole.IsOpen = true;

        if(!NIUtils.CheckOpenNIAvailable())
        {
			gameObject.renderer.enabled = false;
            return;
		}
		
        context = FindObjectOfType(typeof(OpenNISettingsManager)) as OpenNISettingsManager;
        if (context == null) { throw new System.Exception("Missing OpenNISettingsManager"); }

        playerManager = FindObjectOfType(typeof(NIPlayerManager)) as NIPlayerManager;
        if (playerManager == null) { throw new System.Exception("Missing NIPlayerManager"); }
        
        sceneMetaData = context.UserGenerator.UserNode.GetUserPixels(0);
        imageMetaData = new ImageMetaData();
        xResOri = sceneMetaData.XRes;
        yResOri = sceneMetaData.YRes;
        xResScaled = xResOri / samplingFactor;
        yResScaled = yResOri / samplingFactor;

        xResPOT = GetPowerOfTwo(xResOri);
        yResPOT = GetPowerOfTwo(yResOri);

        DebugConsole.Log(xResOri + " - " + yResOri);

        xMargin = (xResPOT - xResScaled) / 2;
        yMargin = (yResPOT - yResScaled) / 2;

        rawUserMap = new short[xResOri * yResOri];
        rawRGBMap = new byte[xResOri * yResOri * 3];
        userTexture = new Texture2D(xResPOT, yResPOT, TextureFormat.ARGB32, false);
        rgbImage = new Texture2D(xResPOT, yResPOT, TextureFormat.RGB24, false);
        rgbPixels = new Color32[xResPOT * yResPOT];
        userMap = new Color32[xResPOT * yResPOT];
        for (int a = 0; a < userMap.Length; a++) userMap[a] = backColor;
        rawDepthMap = new short[xResOri * yResOri];
        histogramMap = new float[context.CurrentContext.Depth.DeviceMaxDepth];

        /*
        xMargin = (resPOT - xResScaled) / 2;
        yMargin = (resPOT - yResScaled) / 2;

		rawUserMap = new short[xResOri * yResOri];
        rawRGBMap = new byte[xResOri * yResOri * 3];
        userTexture = new Texture2D(resPOT, resPOT, TextureFormat.ARGB32, false);
        rgbImage = new Texture2D(resPOT, resPOT, TextureFormat.RGB24, false);
        rgbPixels = new Color32[resPOT * resPOT];
        userMap = new Color32[resPOT * resPOT];
        for (int a = 0; a < userMap.Length; a++) userMap[a] = backColor;
        rawDepthMap = new short[xResOri * yResOri];
        histogramMap = new float[context.CurrentContext.Depth.DeviceMaxDepth];
        */

        gaussianMat = new Material(Shader.Find("Custom/GaussianBlur"));
        PrepareRenderTextures();
		Renderer renderer = gameObject.renderer;		
        if(renderer)
        {
			if(renderer.material == null) { renderer.material = CreateMaterial(); }
            userMapMat = renderer.material;
            renderTex02 = userMapMat.GetTexture("_MainTex") as RenderTexture;   
		} 
        else  { return; }
	}

    // Preparing buffers for multipass shader
    void PrepareRenderTextures()
    {
        // most of these textures are only buffer so no filtering
        depthBufferTex =    InitiateRenderTexture(xResPOT, yResPOT, FilterMode.Point);
        normalBufferTex =   InitiateRenderTexture(xResPOT, yResPOT, FilterMode.Point);
        ssaoTex =           InitiateRenderTexture(xResPOT, yResPOT, FilterMode.Point);
        accBufferTex =      InitiateRenderTexture(xResPOT, yResPOT, FilterMode.Point);
        specularNormalTex = InitiateRenderTexture(xResPOT, yResPOT, FilterMode.Point);
        rgbBufferTex =      InitiateRenderTexture(xResPOT, yResPOT, FilterMode.Point);
        densityBuffer =     InitiateRenderTexture(xResPOT, yResPOT, FilterMode.Point);
        renderTex01 =       InitiateRenderTexture(xResPOT, yResPOT, FilterMode.Bilinear);   // use bilinear filter
    }

    RenderTexture InitiateRenderTexture(int xSize, int ySize, FilterMode filterMode)
    {
        RenderTexture renderTex = new RenderTexture(xSize, ySize, 0, RenderTextureFormat.ARGB32);
        renderTex.useMipMap = false;
        renderTex.wrapMode = TextureWrapMode.Clamp;
        renderTex.filterMode = filterMode;
        return renderTex;
    }

    void ShaderPasses(Texture2D tex)
    {  
        Graphics.Blit(tex, renderTex01);

        /*if (energyEffectEnabled)	// glowing effect on player's surrounding
        {     
            Graphics.Blit(renderTex01, humanTex);

            if (blurEnabled)
            {
                for (int a = 0; a < blurFactor; a++)
                {
                    Graphics.Blit(humanTex, humanTex, gaussianMat, 0);
                    Graphics.Blit(humanTex, humanTex, gaussianMat, 1);
                }
            }

            Graphics.Blit(humanEffectTex, humanEffectTex, humanEffectMat, 0);
            Graphics.Blit(humanTex, humanEffectTex, humanEffectMat, 1);

            Graphics.Blit(humanEffectTex, humanEffectTex, gaussianMat, 0);
            Graphics.Blit(humanEffectTex, humanEffectTex, gaussianMat, 1);
            
            FinalComposition(humanTex);
			AccumulationBlending(humanTex);

            humanDestMat.SetTexture("_SubTex", humanEffectTex);
            Graphics.Blit(humanTex, humanDestTex, humanDestMat);
            userMapMat.SetFloat("_Cutoff", 0.0f);
            Graphics.Blit(humanDestTex, renderTex02, userMapMat);
        }
        else	// only show user'shape
        {
        */
            if (blurEnabled)
            {
                for (int a = 0; a < blurFactor; a++)
                {
                    Graphics.Blit(renderTex01, renderTex01, gaussianMat, 0);
                    Graphics.Blit(renderTex01, renderTex01, gaussianMat, 1);
                }
            }
            
            FinalComposition(renderTex01);
			AccumulationBlending(renderTex01);
            
            userMapMat.SetFloat("_Cutoff", alphaCutThreshold);            
            Graphics.Blit(renderTex01, renderTex02, userMapMat);
        //}
    }

    // temporal coherence calculation
    void AccumulationBlending(RenderTexture renderTex)
    {
        if (acculumationBufferEnabled)
        {
            accumulationBufferMat.SetTexture("_OldTexture", accBufferTex);
            Graphics.Blit(renderTex, renderTex, accumulationBufferMat);
            Graphics.Blit(renderTex, accBufferTex);
        }
    }

    // compositing several buffers
    void FinalComposition(RenderTexture tex)
    {
        // solid color doesn't need complex calculation of normal/depth buffer
        if (shaderEffect != ShaderEffect.SolidColor)
        {
            Graphics.Blit(tex, depthBufferTex);

            if (bilateralFilterEnabled)
            {
                for (int a = 0; a < bilateralIteration; a++)
                    Graphics.Blit(depthBufferTex, depthBufferTex, bilateralAlphaMat);
            }

            Graphics.Blit(depthBufferTex, normalBufferTex, normalEstimationMat);
            ssaoMat.SetTexture("norm_buffer", normalBufferTex);

            if (shaderEffect == ShaderEffect.RawSSAO || shaderEffect == ShaderEffect.ColorSSAO)
            {
                Graphics.Blit(depthBufferTex, ssaoTex, ssaoMat);
                compositeImageMat.SetTexture("_AOBuffer", ssaoTex);
            }

            compositeImageMat.SetTexture("_NormalBuffer", normalBufferTex);
            compositeImageMat.SetTexture("_ZTex", depthBufferTex);
        }

        // do compositing effect
        if (shaderEffect == ShaderEffect.RawSSAO)   // shows AO buffer
        {
            Graphics.Blit(tex, tex, compositeImageMat, 3);
        }
        else if (shaderEffect == ShaderEffect.RawNormal)    // shows normal map
        {
            Graphics.Blit(tex, tex, compositeImageMat, 1);
        }
        else if (shaderEffect == ShaderEffect.RawDepth) // shows depth map
        {
            Graphics.Blit(depthBufferTex, depthBufferTex, enhanceDepthMat);
            Graphics.Blit(tex, tex, compositeImageMat, 2);
        }
        else if (shaderEffect == ShaderEffect.SpecularNormal)    // shows specular effect
        {
            specularNormalMat.SetTexture("_ColorTex", tex);
            Graphics.Blit(normalBufferTex, specularNormalTex, specularNormalMat);
            compositeImageMat.SetTexture("_ProjectedNormalBuffer", specularNormalTex);
            Graphics.Blit(tex, tex, compositeImageMat, 0);
        }
        else if (shaderEffect == ShaderEffect.ColorSSAO)    // shows AO combined with color
        {
            Graphics.Blit(tex, tex, compositeImageMat, 4);
        }
        else if (shaderEffect == ShaderEffect.RGBColor)
        {
            
            Graphics.Blit(rgbImage, rgbBufferTex);
            /*
            Graphics.Blit(rgbBufferTex, rgbBufferTex, gaussianMat, 0);
            Graphics.Blit(rgbBufferTex, rgbBufferTex, gaussianMat, 1);
            
            rgbEffectMat.SetColor("_backgroundColor", backColor);
            rgbEffectMat.SetTexture("_RGBTex", rgbBufferTex);
            rgbEffectMat.SetTexture("_NormalTex", normalBufferTex);
            
            Graphics.Blit(tex, tex, rgbEffectMat);*/

            //for (int a = 0; a < 10; a++)
            //{

            //Graphics.Blit(rgbBufferTex, densityBuffer, densityMat);
            //quickShiftMat.SetTexture("_DensityTex", densityBuffer);
            //Graphics.Blit(rgbBufferTex, rgbBufferTex, quickShiftMat);
            
            //}

            if (bilateralFilterEnabled)
            {
                for (int a = 0; a < bilateralIteration; a++)
                    Graphics.Blit(rgbBufferTex, rgbBufferTex, bilateralRGBMat);
            }

            Graphics.Blit(rgbBufferTex, tex);
        }

        if (meanFilterEnabled) Graphics.Blit(tex, tex, meanMat);
    }

	void CopyTextures()
	{
        for (int x = 0; x < xResScaled; x++)
        {
            for (int y = 0; y < yResScaled; y++)
            {
                int idx = (x + xMargin) + (yResPOT - (y + yMargin) - 1) * xResPOT;
                int rawIdx = x * samplingFactor + (y * samplingFactor * xResOri);
                short d = rawUserMap[rawIdx];       // user mask
                short pixel = rawDepthMap[rawIdx];  // depth pixel
                Color32 col;
                float alpha = histogramMap[pixel];

                if (shaderEffect == ShaderEffect.RGBColor)
                {
                    int rgbIdx = rawIdx * 3;
                    rgbPixels[idx] = new Color32(rawRGBMap[rgbIdx], rawRGBMap[rgbIdx + 1], rawRGBMap[rgbIdx + 2], (byte)255);
                }

                if (d == 0) 
                {
                    col = backColor;
                }
                else
                {
                    int colIdx = d % 3;
                    if (colIdx == 1) { col = player01Color; }
                    else if (colIdx == 2)  { col = player02Color; }
                    else  { col = player03Color; }
                }

                if(d != 0) col.a = (byte)(alpha * 255);

                userMap[idx] = col;
            }
        }
    }

    int[] checkPlayerIDs()
    {
        NISelectedPlayer player;
        int[] ids = new int[playerManager.m_MaxNumberOfPlayers];
        for (int i = 0; i < playerManager.m_MaxNumberOfPlayers; i++)
        {
            player = playerManager.GetPlayer(i);
            if (player != null && player.Tracking) { ids[i] = player.OpenNIUserID; }
            else { ids[i] = -1; }
        }

        return ids;
    }

    void UpdateHistogram()
    {
        Array.Clear(histogramMap, 0, histogramMap.Length);

        int nPoints = 0;
        int depthIndex = 0;
        for (int x = 0; x < xResOri; x++)
        {
            for (int y = 0; y < yResOri; y++)
            {
                short pixel = rawDepthMap[depthIndex];
                if (pixel != 0)
                {
                    histogramMap[pixel]++;
                    nPoints++;
                }
                depthIndex++;
            }
        }

        if (nPoints > 0)
        {
            for (int i = 1; i < histogramMap.Length; i++) histogramMap[i] += histogramMap[i - 1];
            for (int i = 0; i < histogramMap.Length; i++) histogramMap[i] = 1.0f - (histogramMap[i] / nPoints);
        }
    }

	// Update is called once per frame
	void Update () 
    {
        Marshal.Copy(context.CurrentContext.Depth.DepthMapPtr, rawDepthMap, 0, rawDepthMap.Length);
        Marshal.Copy(sceneMetaData.LabelMapPtr, rawUserMap, 0, rawUserMap.Length);

        if (shaderEffect == ShaderEffect.RGBColor)
        {
            context.Image.Image.GetMetaData(imageMetaData);
            Marshal.Copy(imageMetaData.ImageMapPtr, rawRGBMap, 0, rawRGBMap.Length);
        }

        UpdateHistogram();
        CopyTextures();
        userTexture.SetPixels32(userMap);        
        userTexture.Apply();

        if (shaderEffect == ShaderEffect.RGBColor)
        {
            rgbImage.SetPixels32(rgbPixels);
            rgbImage.Apply();
        }
        ShaderPasses(userTexture);
	}

    int GetPowerOfTwo(int num)
    {
        int pot = 1;
        while (pot < num) pot <<= 1;
        return pot;
    }
}
