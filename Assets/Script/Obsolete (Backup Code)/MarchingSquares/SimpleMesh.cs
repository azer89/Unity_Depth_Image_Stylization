
using System;
using System.Collections;
using UnityEngine;

class SimpleMesh : MonoBehaviour
{
    GameObject Testg;
    GameObject TestRenderg;
    SquareCell[,] cells;
    MarchingSquares marchSquares;

    public void Start()
    {
        // grab the camera
        GameObject cam = GameObject.Find("Main Camera");
        cam.transform.position = new Vector3(4, 1, -10);
        cam.transform.rotation = Quaternion.Euler(340, 0, 0);

        // some 2D voxel data
        float[,] data = {{0.5f, 0.5f, 0.5f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f}, 
					      {0.5f, 0.5f, 0.5f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f}, 
						  {0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f}, 
						  {0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f}, 
						  {0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f}, 
						  {0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f}, 
						  {0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f}, 
						  {0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f}, 
						  {0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f}, 
						  {0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f, 1.0f}, };

        // prepare cell data
        cells = new SquareCell[data.GetLength(0) - 1, data.GetLength(1) - 1];
        // put data in cells

        for (int i = 0; i < data.GetLength(0); i++)
        {
            for (int j = 0; j < data.GetLength(1); j++)
            {
                // do not process the edges of the data array since cell.dim + 1 == data.dim
                if (i < data.GetLength(0) - 1 && j < data.GetLength(1) - 1)
                {
                    SquareCell cell = new SquareCell();
                    cell.p[0] = new Vector3(i, j, data[i, j]);
                    cell.p[1] = new Vector3(i + 1, j, data[i + 1, j]);
                    cell.p[2] = new Vector3(i, j + 1, data[i, j + 1]);
                    cell.p[3] = new Vector3(i + 1, j + 1, data[i + 1, j + 1]);

                    /*cell.val[0] = data[i, j];
                    cell.val[1] = data[i + 1, j];
                    cell.val[2] = data[i, j + 1];
                    cell.val[3] = data[i + 1, j + 1];*/

                    cells[i, j] = cell;
                }
            }
        }

        marchSquares = new MarchingSquares();

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
        //MeshRenderer cmr = (MeshRenderer)TestRenderg.AddComponent(typeof(MeshRenderer));
        //cmr.material.color = new Color(1f, .6f, 1f, 1f);

    }

    public void Update()
    {
        Mesh mesh;
        marchSquares.MarchSquares(out mesh, ref cells, 0.5f);
        
        // update the render mesh
        MeshFilter mf = (MeshFilter)Testg.GetComponent(typeof(MeshFilter));
        mf.mesh.Clear();
        mf.mesh.vertices = mesh.vertices;
        mf.mesh.uv = mesh.uv;
        mf.mesh.triangles = mesh.triangles;
        mf.mesh.normals = mesh.normals;
        Destroy(mesh);
    }
}

