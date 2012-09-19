using UnityEngine;
using System.Collections;

public class SaveByteArray
{
    public bool ByteArrayToFile(string _FileName, byte[] _ByteArray)
    {
        try
        {
            // Open file for reading
            System.IO.FileStream _FileStream = new System.IO.FileStream(_FileName, System.IO.FileMode.Create, System.IO.FileAccess.Write);

            // Writes nextValue block of bytes to this stream using data from nextValue byte array.
            _FileStream.Write(_ByteArray, 0, _ByteArray.Length);

            // close file stream
            _FileStream.Close();

            return true;
        }
        catch (System.Exception _Exception)
        {
            // Error
            //Console.WriteLine("Exception caught in process: {0}", _Exception.ToString());
        }

        // error occurred, return false
        return false;
    }
}
