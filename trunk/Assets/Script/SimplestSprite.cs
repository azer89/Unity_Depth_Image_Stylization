using UnityEngine;
using System.Collections;

/// <summary>
/// 至為簡單的 Sprite, 貼整張 material 的貼圖
/// 目標: 簡單, 無負擔, 也不會有和其他物件統合增進效率問題(請使用 Simple Sprite 或 Packed Sprite)
/// </summary>
//[ExecuteInEditMode]
public class SimplestSprite : MonoBehaviour 
{	
	public Vector3 upVector = Vector3.up;
	public Vector3 rightVector = Vector3.right;
	public float width = 1;
	public float height = 1;
	public Rect textureUV = new Rect(0, 0, 1, 1);
	public Material useMaterial;
	public bool bothSides = false;

	protected MeshFilter meshFilter;
	protected MeshRenderer meshRenderer;
	protected Vector3[] vertices;
	
	void Awake () 
    {
        gameObject.AddComponent("MeshFilter");

        // access the Mesh of the mesh filter
        meshFilter = (MeshFilter)GetComponent(typeof(MeshFilter)); 
        
        // render meshes inserted by the MeshFilter or TextMesh
        meshRenderer = (MeshRenderer)GetComponent(typeof(MeshRenderer)); 

		if(meshRenderer == null)
        {
			gameObject.AddComponent("MeshRenderer");
			meshRenderer = (MeshRenderer)GetComponent(typeof(MeshRenderer));
		}
		
        if(useMaterial != null)
        {
	        meshRenderer.renderer.material = useMaterial;
		}

		// init vertices
		ChangeSize(new Vector2(width, height), false);
    }

	// Use this for initialization
	void Start () 
    {
		buildMesh();
	}
	
	// 改 size
	public void ChangeSize(Vector2 newSize, bool rebuild)
	{
		vertices = new Vector3[4];
		Vector3 nR = rightVector * newSize.x / 2;
		Vector3 nU = upVector * newSize.y / 2;
		vertices[0] = -nR + nU;
		vertices[1] =  nR + nU;
		vertices[2] =  nR - nU;
		vertices[3] = -nR - nU;
        if (rebuild) buildMesh();
	}
	
	protected virtual void buildMesh()
	{
		int vertexs = 4;
		int totalTris;
		if(bothSides){ totalTris = 4; } 
        else { totalTris = 2; }

		Vector2[] meshTexUV = new Vector2[vertexs];
		Color[] meshColors = new Color[vertexs];
		int[] meshIndices = new int[totalTris * 3];
		
		meshTexUV[0] = new Vector2(textureUV.xMin, textureUV.yMax);		
		meshTexUV[1] = new Vector2(textureUV.xMax, textureUV.yMax);		
		meshTexUV[2] = new Vector2(textureUV.xMax, textureUV.yMin);		
		meshTexUV[3] = new Vector2(textureUV.xMin, textureUV.yMin);
		
        meshColors[0] = Color.white;
        meshColors[1] = Color.white;
        meshColors[2] = Color.white;
        meshColors[3] = Color.white;

		if(bothSides)
        {
			meshIndices[0] = 0;
			meshIndices[1] = 1;
			meshIndices[2] = 2;
			meshIndices[3] = 0;
			meshIndices[4] = 2;
			meshIndices[5] = 3;
			meshIndices[6] = 1;
			meshIndices[7] = 0;
			meshIndices[8] = 2;
			meshIndices[9] = 0;
			meshIndices[10] = 3;
			meshIndices[11] = 2;
		} 
        else 
        {
			meshIndices[0] = 0;
			meshIndices[1] = 1;
			meshIndices[2] = 2;
			meshIndices[3] = 0;
			meshIndices[4] = 2;
			meshIndices[5] = 3;
		}
		
		Mesh myMesh = meshFilter.mesh;
		myMesh.Clear();
		myMesh.vertices = vertices;
		myMesh.colors = meshColors;
		myMesh.triangles = meshIndices;
		myMesh.uv = meshTexUV;
	}
}
