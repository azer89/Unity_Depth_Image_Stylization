
using System;
using System.Collections;
using UnityEngine;

///  A Triangle in 2D
///
public class Triangle
{
    // the triangles vertices
    public Vector3[] p;
    // saves "outside" lines index positions
    public int[] outerline;
    // constructor
    public Triangle()
    {
        p = new Vector3[3];
        outerline = new int[2];
        outerline[0] = -1;
        outerline[1] = -1;
    }
}

