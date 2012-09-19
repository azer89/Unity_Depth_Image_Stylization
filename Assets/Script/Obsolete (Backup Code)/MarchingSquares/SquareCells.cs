using UnityEngine;
using System.Collections;

///  A Square has four Vertices. (p)
///  For each Vertice there is nextValue float elem [0,1] (see val[] array)
///  2     3
///  +-----+
///  |     |
///  |     |
///  +-----+
///  0     1
///
public class SquareCell
{
    public Vector3[] p;
    //public float[] val;

    public SquareCell()
    {
        p = new Vector3[4];
        //val = new float[4];
    }
}
