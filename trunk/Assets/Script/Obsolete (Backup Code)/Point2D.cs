
using System;
using UnityEngine;

struct Point2D
{
    public int x;
    public int y;

    public Point2D(int x, int y)
    {
        this.x = x;
        this.y = y;
    }

    public void setPoint(int x, int y)
    {
        this.x = x;
        this.y = y;
    }

    public bool isEqual(Point2D p)
    {
        return (this.x == p.x && this.y == p.y);
    }

    public bool isNegative()
    {
        return (this.x == -1 || this.y == -1);
    }

    public float Distance(Point2D p)
    {
        float xDist = this.x - p.x;
        float yDist = this.y - p.y;
        return Mathf.Sqrt(xDist * xDist + yDist * yDist);
    }
}
