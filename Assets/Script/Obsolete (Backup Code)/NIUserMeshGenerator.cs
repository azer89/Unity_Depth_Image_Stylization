 
using System.Runtime.InteropServices;
using OpenNI;
using UnityEngine;
using System;
using System.Collections;
using System.Threading;

public class NIUserMeshGenerator : MonoBehaviour 
{		
	NIPlayerManager playerManager;
	OpenNISettingsManager context;
	SceneMetaData userMetaData;

    //Texture2D userTexture;
    short[] rawUserMap; // User Map
    short[] rawDepthMap;
    float[] histogramMap;

    //int scalingFactorBuffer;
    int xResOri;        // original x size
	int yResOri;        // original y size

    int samplingFactor = 2;
    float[, ] depthSampling;

    GameObject Testg;
    GameObject TestRenderg;
    SquareCell[,] cells;
    MarchingSquares marchSquares;
	Vector3 scaling;
	
	//public String _debug_ = "-0-";
	
	private Material createMaterial()
	{
		Shader defaultShader = Shader.Find("Unlit/Texture");
		Material mat = new Material(defaultShader);
		// 此 shader 只有貼圖而已, 不必額外設定
		return mat;
	}
	
	/* This function is only called once after being initialized */
	void Start() 
    {   
		//lastFrameId = -1;
				
        if(!NIUtils.CheckOpenNIAvailable())
        {
			gameObject.renderer.enabled = false;
            return;
		}
		
        context = FindObjectOfType(typeof(OpenNISettingsManager)) as OpenNISettingsManager;
        if (context == null) { throw new System.Exception("Missing OpenNISettingsManager"); }

        playerManager = FindObjectOfType(typeof(NIPlayerManager)) as NIPlayerManager;
        if (playerManager == null) { throw new System.Exception("Missing NIPlayerManager"); }
                
        userMetaData = context.UserGenerator.UserNode.GetUserPixels(0);
        xResOri = userMetaData.XRes;
        yResOri = userMetaData.YRes;
        //xResScaled = xResOri / scalingFactor;
        //yResScaled = yResOri / scalingFactor;

        //resPOT = Mathf.Max(GetPowerOfTwo(xResOri), GetPowerOfTwo(xResOri));
        //int bufferSize = resPOT * resPOT;
        //xMargin = (resPOT - xResOri) / 2;
        //yMargin = (resPOT - yResOri) / 2;

		rawUserMap = new short[xResOri * yResOri];
        //userTexture = new Texture2D(resPOT, resPOT, TextureFormat.ARGB32, false);
        //userMap = new Color32[bufferSize];

        rawDepthMap = new short[xResOri * yResOri];
        //depthTexture = new Texture2D(resPOT, resPOT, TextureFormat.ARGB32, false);
        //depthMap = new Color32[bufferSize];
        histogramMap = new float[context.CurrentContext.Depth.DeviceMaxDepth];
        
        depthSampling = new float[xResOri / samplingFactor, yResOri / samplingFactor];
        cells = new SquareCell[(xResOri / samplingFactor) - 1, (yResOri / samplingFactor) - 1];

        //initTexture();

        marchSquares = new MarchingSquares();
		scaling = new Vector3(0.1f, 0.1f, 0.1f);
		
        // create nextValue gameobject
        Testg = new GameObject();
        Testg.name = "msquare";
        Testg.transform.position = Vector3.zero;
        Testg.transform.rotation = Quaternion.identity;
        // collision meshfilter
        MeshFilter mf = (MeshFilter)Testg.AddComponent(typeof(MeshFilter));
        // normally you don't want to render the collision mesh
        MeshRenderer mr = (MeshRenderer)Testg.AddComponent(typeof(MeshRenderer));
        mr.material.color = new Color(.5f, .6f, 1f, 1f);

        // create texture sub game object
        TestRenderg = new GameObject();
        TestRenderg.transform.parent = Testg.transform;
        TestRenderg.name = "msquare__rendermesh";
        TestRenderg.transform.position = Vector3.zero;
        TestRenderg.transform.rotation = Quaternion.identity;
        TestRenderg.AddComponent(typeof(MeshFilter));
		
		//MapOutputMode mom = context.CurrentContext.Depth.MapOutputMode;
		//Debug.Log (mom.XRes + " - " + mom.YRes);
		//Debug.Log (xResOri + " - " + yResOri);
        //Debug.Log(resPOT + " - " + resPOT);
        
		/*Renderer renderer = gameObject.renderer;
		if(renderer)
        {
			if(renderer.material == null) { renderer.material = createMaterial(); }
			//renderer.material.SetTexture("_MainTex", userTexture);
		} 
        else 
        { 
            return; 
        }*/
	}
	
	/// <summary>
	/// 利用新的 OpenNI 查詢有效用戶 ID
	/// </summary>
	/// <returns>
	/// 用戶 ID 陣列
	/// </returns>
	int[] checkPlayerIDs()
	{
		NISelectedPlayer player;		
		int[] ids = new int[playerManager.m_MaxNumberOfPlayers];
		for(int i = 0; i < playerManager.m_MaxNumberOfPlayers; i++)
        {
			player = playerManager.GetPlayer(i);
            if (player != null && player.Tracking) { ids[i] = player.OpenNIUserID; }
            else { ids[i] = -1; }
		}

		return ids;
	}

	void DepthSampling()
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
        
        //int[] fixedUsrId = checkPlayerIDs();        
        int rawIdx = 0;

        for (int y = 0; y < yResOri; y++)
        {
            for (int x = 0; x < xResOri; x++)
            {
                // depth sampling
                if (x % samplingFactor == 0 && y % samplingFactor == 0)
                {
                    int xIndex = (x / samplingFactor);
                    int yIndex = (yResOri / samplingFactor) - (y / samplingFactor) - 1;
                    short d = rawUserMap[rawIdx];   // user mask
                    short pixel = rawDepthMap[rawIdx];     // depth pixel

                    if (d > 0) 
					{ 
						depthSampling[xIndex, yIndex] = histogramMap[pixel];
                        //depthSampling[xIndex, yIndex] = 1.0f;
					}
                    else { depthSampling[xIndex, yIndex] = 0.0f; }
                }
                rawIdx++;
            }
        }
	}

	// Update is called once per frame
	void Update () 
    {       
        Marshal.Copy(context.CurrentContext.Depth.DepthMapPtr, rawDepthMap, 0, rawDepthMap.Length);
        Marshal.Copy(userMetaData.LabelMapPtr, rawUserMap, 0, rawUserMap.Length);
        DepthSampling();

        for (int i = 0; i < depthSampling.GetLength(0); i++)
        {
            for (int j = 0; j < depthSampling.GetLength(1); j++)
            {
                // do not process the edges of the data array since cell.dim + 1 == data.dim
                if (i < depthSampling.GetLength(0) - 1 && j < depthSampling.GetLength(1) - 1)
                {
                    SquareCell cell = new SquareCell();
                    //cell.p[0] = new Vector3(i * scaling.x, j * scaling.y, depthSampling[i, j]);
                    //cell.p[1] = new Vector3((i + 1) * scaling.x, j * scaling.y, depthSampling[i + 1, j]);
                    //cell.p[2] = new Vector3(i * scaling.x, (j + 1) * scaling.y, depthSampling[i, j + 1]);
                    //cell.p[3] = new Vector3((i + 1) * scaling.x, (j + 1) * scaling.y, depthSampling[i + 1, j + 1]);

                    cell.p[0] = new Vector3(i * scaling.x, j * scaling.y, depthSampling[i, j]);
                    cell.p[1] = new Vector3((i + 1) * scaling.x, j * scaling.y, depthSampling[i + 1, j]);
                    cell.p[2] = new Vector3(i * scaling.x, (j + 1) * scaling.y, depthSampling[i, j + 1]);
                    cell.p[3] = new Vector3((i + 1) * scaling.x, (j + 1) * scaling.y, depthSampling[i + 1, j + 1]);

                    cells[i, j] = cell;
                }
            }
        }

        Mesh mesh;
        marchSquares.MarchSquares(out mesh, ref cells, 0.1f);
		
        // update the render mesh
        MeshFilter mf = (MeshFilter)Testg.GetComponent(typeof(MeshFilter));
        mf.mesh.Clear();
        mf.mesh.vertices = mesh.vertices;
        mf.mesh.uv = mesh.uv;
        mf.mesh.triangles = mesh.triangles;
        mf.mesh.normals = mesh.normals;
        Destroy(mesh);
	}

    private int GetPowerOfTwo(int num)
    {
        int pot = 1;
        while (pot < num) pot <<= 1;
        return pot;
    }
}
