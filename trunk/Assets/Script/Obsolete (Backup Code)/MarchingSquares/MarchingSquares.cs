///   Marching Squares: 2D Surface Reconstruction
///
///   Derived from "Polygonising nextValue scalar field (Marching Cubes)" by Paul Bourke
///   http://local.wasp.uwa.edu.au/~pbourke/geometry/polygonise/
///   And nextValue lot of inspiration of how to use it with Unity by Brian R. Cowan.
///   See some of his Work here: http://www.briancowan.net/unity/fx
///
///   usage:
///   Attach this script to an empty GameObject. It will look for the "Main Camera"
///   GameObject to automatically adjust the Camera to the rendered Meshes.
///
///   This script is placed in public domain. The author takes no responsibility for any possible harm.

using System;
using System.Collections;
using UnityEngine;

public class MarchingSquares
{        
    // render mesh arrays
    ArrayList vert;
    ArrayList uv;
    ArrayList tri;
    ArrayList norm;

    /// Linearly interpolate the position where an isosurface cuts
    /// an edge between two vertices, each with their own scalar value
    Vector3 Vertex3Interp(float isolevel, ref SquareCell cell, int pid1, int pid2)
    {
        Vector3 p1 = new Vector3(cell.p[pid1].x, cell.p[pid1].y, cell.p[pid1].z);
        Vector3 p2 = new Vector3(cell.p[pid2].x, cell.p[pid2].y, cell.p[pid2].z);
        float valp1 = cell.p[pid1].z;
        float valp2 = cell.p[pid2].z;        

        if (Math.Abs(isolevel - valp1) < 0.00001) return (p1);
        if (Math.Abs(isolevel - valp2) < 0.00001) return (p2);
        if (Math.Abs(valp1 - valp2) < 0.00001) return (p1);

        float mu = (isolevel - valp1) / (valp2 - valp1);
        Vector3 p = Vector3.zero;
        p.x = p1.x + mu * (p2.x - p1.x);
        p.y = p1.y + mu * (p2.y - p1.y);
        p.z = p1.z + mu * (p2.z - p1.z);
        return (p);
    }
    
    /// All cases
    ///
    /// Case 0   Case 1   Case 2   Case 3   Case 4   Case 5   Case 6   Case 7
    /// O-----O  O-----O  O-----O  O-----O  O-----#  O-----#  O-----#  O-----#
    /// |     |  |     |  |     |  |     |  |    \|  |    \|  |  |  |  |/    |
    /// |     |  |\    |  |    /|  |-----|  |     |  |\    |  |  |  |  |     |
    /// O-----O  #-----O  O-----#  #-----#  O-----O  #-----O  O-----#  #-----#
    ///
    /// Case 8   Case 9   Case 10  Case 11  Case 12  Case 13  Case 14  Case 15
    /// #-----O  #-----O  #-----O  #-----O  #-----#  #-----#  #-----#  #-----#
    /// |/    |  |  |  |  |/    |  |    \|  |-----|  |     |  |     |  |     |
    /// |     |  |  |  |  |    /|  |     |  |     |  |    /|  |\    |  |     |
    /// O-----O  #-----O  O-----#  #-----#  O-----O  #-----O  O-----#  #-----#
    ///
    private int Polygonise(SquareCell cell, out Triangle[] triangles, float isoLevel) {
        
        triangles = new Triangle[3]; // => Max 3 Triangles needed
        
        // decide which case we have
        bool case_1 = cell.p[0].z >= isoLevel && cell.p[1].z < isoLevel && cell.p[2].z < isoLevel && cell.p[3].z < isoLevel;
        bool case_2 = cell.p[0].z < isoLevel && cell.p[1].z >= isoLevel && cell.p[2].z < isoLevel && cell.p[3].z < isoLevel;
        bool case_3 = cell.p[0].z >= isoLevel && cell.p[1].z >= isoLevel && cell.p[2].z < isoLevel && cell.p[3].z < isoLevel;
        bool case_4 = cell.p[0].z < isoLevel && cell.p[1].z < isoLevel && cell.p[2].z < isoLevel && cell.p[3].z >= isoLevel;
        bool case_5 = cell.p[0].z >= isoLevel && cell.p[1].z < isoLevel && cell.p[2].z < isoLevel && cell.p[3].z >= isoLevel;
        bool case_6 = cell.p[0].z < isoLevel && cell.p[1].z >= isoLevel && cell.p[2].z < isoLevel && cell.p[3].z >= isoLevel;
        bool case_7 = cell.p[0].z >= isoLevel && cell.p[1].z >= isoLevel && cell.p[2].z < isoLevel && cell.p[3].z >= isoLevel;
        bool case_8 = cell.p[0].z < isoLevel && cell.p[1].z < isoLevel && cell.p[2].z >= isoLevel && cell.p[3].z < isoLevel;
        bool case_9 = cell.p[0].z >= isoLevel && cell.p[1].z < isoLevel && cell.p[2].z >= isoLevel && cell.p[3].z < isoLevel;
        bool case_10 = cell.p[0].z < isoLevel && cell.p[1].z >= isoLevel && cell.p[2].z >= isoLevel && cell.p[3].z < isoLevel;
        bool case_11 = cell.p[0].z >= isoLevel && cell.p[1].z >= isoLevel && cell.p[2].z >= isoLevel && cell.p[3].z < isoLevel;
        bool case_12 = cell.p[0].z < isoLevel && cell.p[1].z < isoLevel && cell.p[2].z >= isoLevel && cell.p[3].z >= isoLevel;
        bool case_13 = cell.p[0].z >= isoLevel && cell.p[1].z < isoLevel && cell.p[2].z >= isoLevel && cell.p[3].z >= isoLevel;
        bool case_14 = cell.p[0].z < isoLevel && cell.p[1].z >= isoLevel && cell.p[2].z >= isoLevel && cell.p[3].z >= isoLevel;
        bool case_15 = cell.p[0].z >= isoLevel && cell.p[1].z >= isoLevel && cell.p[2].z >= isoLevel && cell.p[3].z >= isoLevel;
        
        // make triangles
        int ntriang = 0;
        if (case_1) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = Vertex3Interp(isoLevel, ref cell, 2, 0);
            triangles[0].p[1] = Vertex3Interp(isoLevel, ref cell, 0, 1);
            triangles[0].p[2] = cell.p[0];
            triangles[0].outerline[0] = 0;
            triangles[0].outerline[1] = 1;
            ntriang++;
        }
        if (case_2) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = Vertex3Interp(isoLevel, ref cell, 0, 1);
            triangles[0].p[1] = Vertex3Interp(isoLevel, ref cell, 1, 3);
            triangles[0].p[2] = cell.p[1];
            triangles[0].outerline[0] = 0;
            triangles[0].outerline[1] = 1;
            ntriang++;
        }
        if (case_3) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = Vertex3Interp(isoLevel, ref cell, 0, 2);
            triangles[0].p[1] = cell.p[1];
            triangles[0].p[2] = cell.p[0];
            // no outer line...
            ntriang++;
            
            triangles[1] = new Triangle();
            triangles[1].p[0] = Vertex3Interp(isoLevel, ref cell, 0, 2);
            triangles[1].p[1] = Vertex3Interp(isoLevel, ref cell, 1, 3);
            triangles[1].p[2] = cell.p[1];
            triangles[1].outerline[0] = 0;
            triangles[1].outerline[1] = 1;
            ntriang++;
        }
        if (case_4) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = Vertex3Interp(isoLevel, ref cell, 1, 3);
            triangles[0].p[1] = Vertex3Interp(isoLevel, ref cell, 2, 3);
            triangles[0].p[2] = cell.p[3];
            triangles[0].outerline[0] = 0;
            triangles[0].outerline[1] = 1;
            ntriang++;
        }
        if (case_5) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = Vertex3Interp(isoLevel, ref cell, 1, 3);
            triangles[0].p[1] = Vertex3Interp(isoLevel, ref cell, 2, 3);
            triangles[0].p[2] = cell.p[3];
            triangles[0].outerline[0] = 0;
            triangles[0].outerline[1] = 1;
            ntriang++;
            
            triangles[1] = new Triangle();
            triangles[1].p[0] = cell.p[0];
            triangles[1].p[1] = Vertex3Interp(isoLevel, ref cell, 0, 2);
            triangles[1].p[2] = Vertex3Interp(isoLevel, ref cell, 0, 1);
            triangles[1].outerline[0] = 1;
            triangles[1].outerline[1] = 2;
            ntriang++;
        }
        if (case_6) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = Vertex3Interp(isoLevel, ref cell, 2, 3);
            triangles[0].p[1] = cell.p[3];
            triangles[0].p[2] = cell.p[1];
            // no outer line...
            ntriang++;
            
            triangles[1] = new Triangle();
            triangles[1].p[0] = Vertex3Interp(isoLevel, ref cell, 0, 1);
            triangles[1].p[1] = Vertex3Interp(isoLevel, ref cell, 2, 3);
            triangles[1].p[2] = cell.p[1];
            triangles[1].outerline[0] = 0;
            triangles[1].outerline[1] = 1;
            ntriang++;
        }
        if (case_7) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = Vertex3Interp(isoLevel, ref cell, 2, 3);
            triangles[0].p[1] = cell.p[3];
            triangles[0].p[2] = cell.p[1];
            // no outer line...
            ntriang++;
            
            triangles[1] = new Triangle();
            triangles[1].p[0] = Vertex3Interp(isoLevel, ref cell, 0, 2);
            triangles[1].p[1] = Vertex3Interp(isoLevel, ref cell, 2, 3);
            triangles[1].p[2] = cell.p[1];
            triangles[1].outerline[0] = 0;
            triangles[1].outerline[1] = 1;
            ntriang++;
            
            triangles[2] = new Triangle();
            triangles[2].p[0] = cell.p[0];
            triangles[2].p[1] = Vertex3Interp(isoLevel, ref cell, 0, 2);
            triangles[2].p[2] = cell.p[1];
            // no outer line...
            ntriang++;
        }
        if (case_8) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = Vertex3Interp(isoLevel, ref cell, 2, 3);
            triangles[0].p[1] = Vertex3Interp(isoLevel, ref cell, 0, 2);
            triangles[0].p[2] = cell.p[2];
            triangles[0].outerline[0] = 0;
            triangles[0].outerline[1] = 1;
            ntriang++;
        }
        if (case_9) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = cell.p[0];
            triangles[0].p[1] = cell.p[2];
            triangles[0].p[2] = Vertex3Interp(isoLevel, ref cell, 0, 1);
            // no outer line...
            ntriang++;
            
            triangles[1] = new Triangle();
            triangles[1].p[0] = cell.p[2];
            triangles[1].p[1] = Vertex3Interp(isoLevel, ref cell, 2, 3);
            triangles[1].p[2] = Vertex3Interp(isoLevel, ref cell, 0, 1);
            triangles[1].outerline[0] = 1;
            triangles[1].outerline[1] = 2;
            ntriang++;
        }
        if (case_10) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = cell.p[2];
            triangles[0].p[1] = Vertex3Interp(isoLevel, ref cell, 2, 3);
            triangles[0].p[2] = Vertex3Interp(isoLevel, ref cell, 0, 2);
            triangles[0].outerline[0] = 1;
            triangles[0].outerline[1] = 2;
            ntriang++;
            
            triangles[1] = new Triangle();
            triangles[1].p[0] = Vertex3Interp(isoLevel, ref cell, 0, 1);
            triangles[1].p[1] = Vertex3Interp(isoLevel, ref cell, 1, 3);
            triangles[1].p[2] = cell.p[1];
            triangles[1].outerline[0] = 0;
            triangles[1].outerline[1] = 1;
            ntriang++;
        }
        if (case_11) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = cell.p[0];
            triangles[0].p[1] = Vertex3Interp(isoLevel, ref cell, 1, 3);
            triangles[0].p[2] = cell.p[1];
            // no outer line...
            ntriang++;
            
            triangles[1] = new Triangle();
            triangles[1].p[0] = Vertex3Interp(isoLevel, ref cell, 2, 3);
            triangles[1].p[1] = Vertex3Interp(isoLevel, ref cell, 1, 3);
            triangles[1].p[2] = cell.p[0];
            triangles[1].outerline[0] = 0;
            triangles[1].outerline[1] = 1;
            ntriang++;
            
            triangles[2] = new Triangle();
            triangles[2].p[0] = cell.p[2];
            triangles[2].p[1] = Vertex3Interp(isoLevel, ref cell, 2, 3);
            triangles[2].p[2] = cell.p[0];
            // no outer line...
            ntriang++;
        }
        if (case_12) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = cell.p[2];
            triangles[0].p[1] = cell.p[3];
            triangles[0].p[2] = Vertex3Interp(isoLevel, ref cell, 0, 2);
            // no outer line...
            ntriang++;
            
            triangles[1] = new Triangle();
            triangles[1].p[0] = cell.p[3];
            triangles[1].p[1] = Vertex3Interp(isoLevel, ref cell, 1, 3);
            triangles[1].p[2] = Vertex3Interp(isoLevel, ref cell, 0, 2);
            triangles[1].outerline[0] = 1;
            triangles[1].outerline[1] = 2;
            ntriang++;
        }
        if (case_13) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = Vertex3Interp(isoLevel, ref cell, 0, 1);
            triangles[0].p[1] = cell.p[0];
            triangles[0].p[2] = cell.p[2];
            // no outer line...
            ntriang++;
            
            triangles[1] = new Triangle();
            triangles[1].p[0] = Vertex3Interp(isoLevel, ref cell, 1, 3);
            triangles[1].p[1] = Vertex3Interp(isoLevel, ref cell, 0, 1);
            triangles[1].p[2] = cell.p[2];
            triangles[1].outerline[0] = 0;
            triangles[1].outerline[1] = 1;
            ntriang++;
            
            triangles[2] = new Triangle();
            triangles[2].p[0] = Vertex3Interp(isoLevel, ref cell, 1, 3);
            triangles[2].p[1] = cell.p[2];
            triangles[2].p[2] = cell.p[3];
            // no outer line...
            ntriang++;
        }
        if (case_14) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = cell.p[1];
            triangles[0].p[1] = Vertex3Interp(isoLevel, ref cell, 0, 1);
            triangles[0].p[2] = cell.p[3];
            // no outer line...
            ntriang++;
            
            triangles[1] = new Triangle();
            triangles[1].p[0] = cell.p[3];
            triangles[1].p[1] = Vertex3Interp(isoLevel, ref cell, 0, 1);
            triangles[1].p[2] = Vertex3Interp(isoLevel, ref cell, 0, 2);
            triangles[1].outerline[0] = 1;
            triangles[1].outerline[1] = 2;
            ntriang++;
            
            triangles[2] = new Triangle();
            triangles[2].p[0] = Vertex3Interp(isoLevel, ref cell, 0, 2);
            triangles[2].p[1] = cell.p[2];
            triangles[2].p[2] = cell.p[3];
            // no outer line...
            ntriang++;
        }
        if (case_15) 
        {
            triangles[0] = new Triangle();
            triangles[0].p[0] = cell.p[2];
            triangles[0].p[1] = cell.p[1];
            triangles[0].p[2] = cell.p[0];
            // no outer line...
            ntriang++;
            
            triangles[1] = new Triangle();
            triangles[1].p[0] = cell.p[1];
            triangles[1].p[1] = cell.p[2];
            triangles[1].p[2] = cell.p[3];
            // no outer line...
            ntriang++;
        }
        
        return ntriang;
    }
        
    public void MarchSquares(out Mesh rmesh, ref SquareCell[,] cells, float isolevel)
    {
        Vector2 uvScale = new Vector2(1.0f / cells.GetLength(0), 1.0f / cells.GetLength(1));
        int tricount = 0;   // triangle index counter

        // mesh data arrays - just clear when reused
        if (vert == null) vert = new ArrayList(); else vert.Clear();
        if (uv == null)   uv = new ArrayList();   else uv.Clear();
        if (tri == null)  tri = new ArrayList();  else tri.Clear();
        if (norm == null) norm = new ArrayList(); else norm.Clear();
        
        for (int i = 0; i < cells.GetLength(0); i++) {
            for (int j = 0; j < cells.GetLength(1); j++) {
                
                SquareCell cell = cells[i,j];
                
                Triangle[] triangles;
                Polygonise(cell, out triangles, isolevel);
                
                for (int k = 0; k < triangles.Length; k++) {
                    Triangle triangle = triangles[k];
                    if (triangle != null) 
                    {
                        // reversed z-axis
                        Vector3 p0 = new Vector3(triangle.p[0].x, triangle.p[0].y, -triangle.p[0].z);
                        Vector3 p1 = new Vector3(triangle.p[1].x, triangle.p[1].y, -triangle.p[1].z);
                        Vector3 p2 = new Vector3(triangle.p[2].x, triangle.p[2].y, -triangle.p[2].z);

                        vert.Add(p0);
                        vert.Add(p1);
                        vert.Add(p2);
                        // Triangles
                        tri.Add(tricount);
                        tri.Add(tricount+1);
                        tri.Add(tricount+2);
                        // Normals
                        Vector3 vn1 = p0 - p1; 
                        Vector3 vn2 = p0 - p2;
                        Vector3 n = Vector3.Normalize ( Vector3.Cross(vn1, vn2) );
                        norm.Add(n); norm.Add(n); norm.Add(n);
                        uv.Add(Vector2.Scale(new Vector2 (p0.x, p0.y), new Vector2(uvScale.x, uvScale.y)));
                        uv.Add(Vector2.Scale(new Vector2 (p1.x, p1.y), new Vector2(uvScale.x, uvScale.y)));
                        uv.Add(Vector2.Scale(new Vector2 (p2.x, p2.y), new Vector2(uvScale.x, uvScale.y)));
                        tricount += 3;                        
                    }
                }
            }
        }
        
        // prepare the render mesh
        rmesh = new Mesh();
        rmesh.vertices = (Vector3[]) vert.ToArray(typeof(Vector3));
        rmesh.uv = (Vector2[]) uv.ToArray(typeof(Vector2));
        rmesh.triangles = (int[]) tri.ToArray(typeof(int));
        rmesh.normals = (Vector3[]) norm.ToArray(typeof(Vector3));
    }
}