
using UnityEngine;
using System.Collections;

class EdgeDetector
{
    short[] tempMask;
    short[] filter = new short[9] {0, 1, 0, 
                                   1, 1, 1, 
                                   0, 1, 0 };
    int arrayLength;

    public EdgeDetector()
    {
        tempMask = null;
    }

    public void Dilation(short[] userMask, int width, int height)
    {
        int length = userMask.Length;

        if (tempMask == null || arrayLength != length)   // instantiated once
        {
            tempMask = new short[length];
            this.arrayLength = length;
        }

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                tempMask[x + y * width] = 0;
                if (userMask[x + y * width] != (short)MaskConstant.BACKGROUND) continue;
                bool keep = true;

                for (int n = 0; n < 3; n++)
                {
                    for (int m = 0; m < 3; m++)
                    {
                        int xIdx = Mathf.Min(Mathf.Max(0, x + m - 3 / 2), width - 1);
                        int yIdx = Mathf.Min(Mathf.Max(0, y + n - 3 / 2), height - 1);

                        if (userMask[xIdx + yIdx * width] != filter[m + n * 3] &&
                            filter[m + n * 3] != 1)
                        {
                            keep = false;
                            break;
                        }
                    }
                }

                tempMask[x + y * width] = (short)(keep ? 0 : 1);
            }
        }


        for (int i = 0; i < length; i++)
        {
            if (tempMask[1] == 0) userMask[i] = (short)MaskConstant.BACKGROUND;
            //userMask[i] = (tempMask[i] == 0) ? (short)MaskConstant.PLAYER :
            //    (short)MaskConstant.BACKGROUND;
        }
    }

    public void Erosion(short[] userMask, int width, int height)
    {
        int length = userMask.Length;

        if (tempMask == null || arrayLength != length)   // instantiated once
        {
            tempMask = new short[length];
            this.arrayLength = length;
        }

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                tempMask[x + y * width] = 0;
                if (userMask[x + y * width] == (short)MaskConstant.BACKGROUND) continue;
                bool keep = true;

                for (int n = 0; n < 3; n++)
                {
                    for (int m = 0; m < 3; m++)
                    {
                        int xIdx = Mathf.Min(Mathf.Max(0, x + m - 3 / 2), width - 1);
                        int yIdx = Mathf.Min(Mathf.Max(0, y + n - 3 / 2), height - 1);

                        if (userMask[xIdx + yIdx * width] != filter[m + n * 3] &&
                            filter[m + n * 3] != 0)
                        {
                            keep = false;
                            break;
                        }
                    }
                }

                tempMask[x + y * width] = (short)(keep ? 1 : 0);
            }
        }


        for (int i = 0; i < length; i++)
        {
            userMask[i] = (tempMask[i] == 1) ? (short)MaskConstant.PLAYER1 :
                (short)MaskConstant.BACKGROUND;
        }
    }

    public void ErosionEdgeDetect(short[] userMask, int width, int height)
    {
        int length = userMask.Length;

        if (tempMask == null || arrayLength != length)   // instantiated once
        {
            tempMask = new short[length];
            this.arrayLength = length;
        }

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {               
                if (userMask[x + y * width] == (short)MaskConstant.BACKGROUND) continue;
                bool keep = true;

                for (int n = 0; n < 3; n++)
                {
                    for (int m = 0; m < 3; m++)
                    {
                        int xIdx = Mathf.Min(Mathf.Max(0, x + m - 3 / 2), width - 1);
                        int yIdx = Mathf.Min(Mathf.Max(0, y + n - 3 / 2), height - 1);

                        if (userMask[xIdx + yIdx * width] != filter[m + n * 3] &&
                            filter[m + n * 3] != 0)
                        {
                            keep = false;
                            break;
                        }
                    }
                }

                tempMask[x + y * width] = (short)(keep ? 1 : 0);
            }
        }

        
        for (int i = 0; i < length; i++)
        {
            userMask[i] = (userMask[i] - tempMask[i] == 1) ? (short)MaskConstant.EDGE :
                (short)MaskConstant.BACKGROUND;
        }
    }
    
    public void EdgeDetect(short[] userMask, int width, int height, short userMark)
    {
        int length = userMask.Length;
        
        if (tempMask == null || arrayLength != length)   // instantiated once
        {
            tempMask = new short[length];
            this.arrayLength = length;
        }

        for (int i = 0; i < length; i++) { tempMask[i] = (short)MaskConstant.BACKGROUND; }
        
        int idx = 0;
        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                short cell = userMask[idx];

                if (cell == userMark &&
                   ((x > 0 && y > 0 && cell != userMask[x - 1 + ((y - 1) * width)]) ||                   // upleft
                   (x < width - 1 && y > 0 && cell != userMask[x + 1 + ((y - 1) * width)]) ||           // upright
                   (x < width - 1 && y < height - 1 && cell != userMask[x + 1 + ((y + 1) * width)]) ||  // downright
                   (x > 0 && y < height - 1 && cell != userMask[x - 1 + ((y + 1) * width)]) ||          // downleft
                   (x > 0 && cell != userMask[x - 1 + (y * width)]) ||              // left
                   (y > 0 && cell != userMask[x + ((y - 1) * width)]) ||            // up
                   (x < width - 1 && cell != userMask[x + 1 + (y * width)]) ||      // right
                   (y < height - 1 && cell != userMask[x + ((y + 1) * width)])))    // down
                {
                    tempMask[idx] = (short)MaskConstant.EDGE;
                }

                idx++;
            }
        }

        // copy all
        for (int i = 0; i < length; i++) { userMask[i] = tempMask[i]; }
    }
}
