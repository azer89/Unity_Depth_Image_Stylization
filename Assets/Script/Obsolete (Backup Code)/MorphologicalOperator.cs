using UnityEngine;
using System.Collections;

public class MorphologicalOperator 
{
    short[] tempMask;
    int arrayLength;

    public MorphologicalOperator()
    {
        tempMask = null;
    }

    public void Dilate(short[] userMask, int width, int height)
    {
        int length = userMask.Length;
        CheckSize(length);
        short[] filter = new short[9] {0, 1, 0, 
                                       1, 1, 1, 
                                       0, 1, 0 };

        for (int y = 0; y < height; y++)
        {
            for (int x = 0; x < width; x++)
            {
                tempMask[x + y * width] = 0;
                if (userMask[x + y * width] != (short)MaskConstant.BACKGROUND)
                {
                    tempMask[x + y * width] = (short)1;
                    continue;
                }
                bool keep = false;

                for (int n = 0; n < 3; n++)
                {
                    for (int m = 0; m < 3; m++)
                    {
                        int xIdx = Mathf.Min(Mathf.Max(0, x + m - 3 / 2), width - 1);
                        int yIdx = Mathf.Min(Mathf.Max(0, y + n - 3 / 2), height - 1);

                        if (userMask[xIdx + yIdx * width] == filter[m + n * 3] &&
                            filter[m + n * 3] == 1)
                        {
                            keep = true;
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

    public void Erode(short[] userMask, int width, int height)
    {
        int length = userMask.Length;
        CheckSize(length);
        short[] filter = new short[9] {0, 1, 0, 
                                       1, 1, 1, 
                                       0, 1, 0 };

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
                            filter[m + n * 3] == 1)
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

    public void Opening(short[] userMask, int width, int height)
    {
        // erode the dilate
        Erode(userMask, width, height);
        Dilate(userMask, width, height);
    }

    public void Closing(short[] userMask, int width, int height)
    {
        // dilate the erode        
        Dilate(userMask, width, height);
        Erode(userMask, width, height);
    }

    private void CheckSize(int length)
    {
        if (tempMask == null || arrayLength != length)   // instantiated once
        {
            tempMask = new short[length];
            this.arrayLength = length;
        }
    }
}
