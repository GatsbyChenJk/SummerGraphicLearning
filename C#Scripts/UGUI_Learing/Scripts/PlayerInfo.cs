using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInfo : MonoBehaviour
{
    public Transform PlayerPos;
    public Quaternion PlayerRot;
    public Mesh PlayerMesh;

    void Awake()
    {
        PlayerPos = this.GetComponent<Transform>(); 
        PlayerRot = this.transform.rotation;
        PlayerMesh = this.GetComponent<Mesh>();
    }

    public string GetPlayerPos()
    {
        return "Position:("+
            PlayerPos.position.x.ToString() + "," +
            PlayerPos.position.y.ToString() + "," +
            PlayerPos.position.z.ToString() 
            + ")";
    }

    public string GetPlayerRot()
    {
        return "Rotation:("+
            PlayerRot.x.ToString() + "," +
            PlayerRot.y.ToString() + "," +
            PlayerRot.z.ToString() 
            + ")";
    }

    public string GetPlayerHash()
    {
        return "Num :" + PlayerMesh.GetHashCode().ToString();
    }

}
