/*------------------------------------------------------------------
PirateParty Source Code
Copyright (c) 2012 International Games System CO., Inc.
上次更新資訊紀錄 --
$HeadURL: https://rd1_soft3/svn/Pirate2012/trunk/game/Assets/Scripts/OpenNI/Scripts2/NIUtils.cs $
$Rev:: 218                   $: 最新版本
$Author:: yorkwu             $: 最新作者
$Date:: 2012-07-06 18:01:33 #$: 最新日期
------------------------------------------------------------------*/ 
using UnityEngine;
using System.Collections;
using OpenNI;

/// <summary>
/// 官方板 OpenNI 的工具, 基本上多半都是 static function
/// </summary>
public class NIUtils : MonoBehaviour {
	
	private static NIPlayerManager g_PlayerManager = null;
	
	public static NIPlayerManager GetPlayerManager()
	{
		if(g_PlayerManager == null)
			g_PlayerManager = FindObjectOfType(typeof(NIPlayerManager)) as NIPlayerManager;
		return g_PlayerManager;
	}
	/// <summary>
	/// 傳回玩家是否追蹤中
	/// </summary>
	/// <returns>
	/// The player tracked.
	/// </returns>
	/// <param name='player'>
	/// If set to <c>true</c> player.
	/// </param>
	public static bool isPlayerTracked(int player)
	{
		GetPlayerManager();
		if(g_PlayerManager != null){
			NISelectedPlayer plyr = g_PlayerManager.GetPlayer(player);
			if(plyr != null && plyr.Valid && plyr.Tracking)
				return true;
		}
		return false;
	}
	
	/// <summary>
	/// 取關節位置, 並且經過一些處理
	/// </summary>
	/// <returns>
	/// The skeleton position.
	/// </returns>
	/// <param name='player'>
	/// If set to <c>true</c> player.
	/// </param>
	/// <param name='joint'>
	/// If set to <c>true</c> joint.
	/// </param>
	/// <param name='pos'>
	/// If set to <c>true</c> position.
	/// </param>
	public static bool GetSkeletonPosition(int player, SkeletonJoint joint, out SkeletonJointPosition pos)
	{
		GetPlayerManager();
		if(g_PlayerManager != null && g_PlayerManager.Valid){
			NISelectedPlayer selPlyr = g_PlayerManager.GetPlayer(player);
			if(selPlyr != null && selPlyr.Valid && selPlyr.Tracking){
				bool ret = selPlyr.GetSkeletonJointPosition(joint, out pos);
				// Z 修正
				if(pos.Position.Z == 0)
					ret = false;
				return ret;
			}
		}
		pos = new SkeletonJointPosition();
		return false;
	}
	
	/// <summary>
	/// 直接抓取 OpenNI 某玩家的位置
	/// </summary>
	/// <returns>
	/// 是否成功(未追蹤則不成功)
	/// </returns>
	/// <param name='player'>
	/// 玩家號碼(0~n)
	/// </param>
	/// <param name='posAndConfidence'>
	/// 位置以及 confidence 值(放w欄位)
	/// </param>
	public static bool GetJointPosition(int player, SkeletonJoint joint, out Vector4 posAndConfidence)
	{
		SkeletonJointPosition sjp;
		bool ret = GetSkeletonPosition(player, joint, out sjp);
		if(ret){
			Vector3 pos = NIConvertCoordinates.ConvertPos(sjp.Position);
			posAndConfidence = new Vector4(pos.x, pos.y, pos.z, sjp.Confidence);
		} else
			posAndConfidence = Vector4.zero;
		return ret;
	}

	
	/// <summary>
	/// 傳回 OpenNI 是否可用? 包含一切遊戲要用的功能
	/// </summary>
	/// <returns>
	/// The open NI available.
	/// </returns>
	public static bool CheckOpenNIAvailable()
	{
		if(NIContext.Instance.Valid &&
			NIContext.Instance.Depth != null){
			OpenNISettingsManager setMgr = FindObjectOfType(typeof(OpenNISettingsManager)) as OpenNISettingsManager;
			if(setMgr != null && setMgr.UserGenerator != null && setMgr.UserSkeletonValid){
				return true;
			}
		}
		return false;
	}
	
	/// <summary>
	/// 取得全域的 bypass on error 旗標
	/// </summary>
	/// <returns>
	/// The bypass on error flag.
	/// </returns>
	/*public static bool GetBypassOnErrorFlag()
	{
		OpenNISettingsManager setMgr = FindObjectOfType(typeof(OpenNISettingsManager)) as OpenNISettingsManager;
		if(setMgr != null){
			return setMgr.bypassOnError;
		} else
			return false;
	}*/
		
	public static Vector3 GetPositionFrom(SkeletonJointTransformation sjt)
	{
		return new Vector3(sjt.Position.Position.X, sjt.Position.Position.Y, sjt.Position.Position.Z);
	}
	public static Quaternion GetOrientationFrom(SkeletonJointTransformation sjt)
	{
        Point3D sensorForward = Point3D.ZeroPoint;
        sensorForward.X = sjt.Orientation.Z1;
        sensorForward.Y = sjt.Orientation.Z2;
        sensorForward.Z = sjt.Orientation.Z3;
        // convert it to Unity
        Vector3 worldForward = NIConvertCoordinates.ConvertPos(sensorForward);
        worldForward *= -1.0f; // because the Unity "forward" axis is opposite to the world's "z" axis.
        if (worldForward.magnitude == 0)
            return Quaternion.identity; // we don't have nextValue good point to work with.
        // Get the upward axis from "Y".
        Point3D sensorUpward = Point3D.ZeroPoint;
        sensorUpward.X = sjt.Orientation.Y1;
        sensorUpward.Y = sjt.Orientation.Y2;
        sensorUpward.Z = sjt.Orientation.Y3;
        Vector3 worldUpwards = NIConvertCoordinates.ConvertPos(sensorUpward);
        if (worldUpwards.magnitude == 0)
            return Quaternion.identity; // we don't have nextValue good point to work with.
        Quaternion jointRotation = Quaternion.LookRotation(worldForward, worldUpwards);
		return jointRotation;
	}
	
	/// <summary>
	/// 由真實座標轉換為圖形上座標(pixel)
	/// </summary>
	/// <returns>
	/// 貼圖座標, 但 Z 值保留原本數值
	/// </returns>
	/// <param name='realPos'>
	/// Real position.
	/// </param>
	public static Vector3 ProjectToImagePosition(Vector3 realPos)
	{
		Point3D src, dst;
		src = new Point3D(realPos.x, realPos.y, realPos.z);
		dst = NIContext.Instance.Depth.ConvertRealWorldToProjective(src);
		return new Vector3(dst.X, dst.Y, dst.Z);
	}
	
	/// <summary>
	/// 由影像座標反推回真實座標
	/// </summary>
	/// <returns>
	/// 真實座標, 但 Z 值保持不變
	/// </returns>
	/// <param name='imagePos'>
	/// Image position.
	/// </param>
	public static Vector3 UnprojectFromImagePosition(Vector3 imagePos)
	{
		Point3D src, dst;
		src = new Point3D(imagePos.x, imagePos.y, imagePos.z);
		dst = NIContext.Instance.Depth.ConvertProjectiveToRealWorld(src);
		return new Vector3(dst.X, dst.Y, dst.Z);
	}
	
	/// <summary>
	/// 取得幾 P 的實際 PlayerID, 這是動態的...
	/// </summary>
	/// <returns>
	/// 對應陣列
	/// </returns>
	public static int[] GetPlayerMapping()
	{
		NISelectedPlayer plyr;
		int maxPlyrs = GetPlayerManager().m_MaxNumberOfPlayers;
		int[] iArray = new int[maxPlyrs];
		for(int i=0;i<maxPlyrs;++i){
			plyr = GetPlayerManager().GetPlayer(i);
			if(plyr != null && plyr.Tracking){
				iArray[i] = plyr.OpenNIUserID;
			} else
				iArray[i] = 0;
		}
		return iArray;
	}
	
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
