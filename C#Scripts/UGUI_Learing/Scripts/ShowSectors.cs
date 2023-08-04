using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class ShowSectors : MonoBehaviour
{
    public int SectorIndex;
    public TMP_Text SectorInfo;
    public GameObject Sector;
    public RectTransform InfoTextSize;
    public RectTransform CanvasRect;
    public GameObject SectorCamera;

    public void ShowSectorInfo()
    {       
        SectorCamera = GameObject.FindGameObjectWithTag("MainCamera");
        if (CanvasRect.rotation == Quaternion.Euler(0, 0, 0))
        {
            CanvasRect = SectorCamera.transform.GetChild(0).GetComponent<RectTransform>();
            CanvasRect.rotation *= Quaternion.Lerp(Quaternion.Euler(0, 0, 0), Quaternion.Euler(0, 30, 0), 0.5f);
        }

        SectorInfo = GameObject.FindGameObjectWithTag("Respawn").GetComponent<TMP_Text>();
        InfoTextSize = GameObject.FindGameObjectWithTag("Respawn").GetComponent<RectTransform>();
        SectorIndex = transform.GetComponent<ShowInvertory>().typeIndex;
        SectorInfo.text = "";
        switch(SectorIndex)
        {
            case 0:               
                Sector = GameObject.FindGameObjectWithTag("S1");
                SectorCamera.GetComponent<CameraControllor>().target = Sector.transform;
                SectorInfo.text += "Radius : [" + Sector.GetComponent<CapsuleCollider>().radius.ToString() + "] \n"; 
                SectorInfo.text += "Name : [" + Sector.GetComponent<MeshRenderer>().name + "]" + "\n";
                break;
            case 1:
                Sector = GameObject.FindGameObjectWithTag("S2");
                SectorCamera.GetComponent<CameraControllor>().target = Sector.transform;
                SectorInfo.text += "Radius : [" + Sector.GetComponent<CapsuleCollider>().radius.ToString() + "] \n";
                SectorInfo.text += "Name : [" + Sector.GetComponent<MeshRenderer>().name + "]" + "\n";
                break;
            case 2:
                Sector = GameObject.FindGameObjectWithTag("S3");
                SectorCamera.GetComponent<CameraControllor>().target = Sector.transform;
                SectorInfo.text += "Radius : [" + Sector.GetComponent<CapsuleCollider>().radius.ToString() + "] \n";
                SectorInfo.text += "Name : [" + Sector.GetComponent<MeshRenderer>().name + "]" + "\n";
                break;
            case 3:
                Sector = GameObject.FindGameObjectWithTag("S4");
                SectorCamera.GetComponent<CameraControllor>().target = Sector.transform;
                SectorInfo.text += "Radius : [" + Sector.GetComponent<CapsuleCollider>().radius.ToString() + "] \n";
                SectorInfo.text += "Name : [" + Sector.GetComponent<MeshRenderer>().name + "]" + "\n";
                break;
        }

        //根据字体大小调整文本框大小
        Vector2 textSize = SectorInfo.GetPreferredValues();
        InfoTextSize.sizeDelta = new Vector2(textSize.x, textSize.y);

    }
}
