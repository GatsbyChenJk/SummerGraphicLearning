using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using System;

public class Clock : MonoBehaviour
{
    public TMP_Text clockText;
    public GameObject TestObj;
    public GameObject[] TestObjs;
    public RectTransform textBoxSize;

    public List<string> ObjPosInfo;
    public List<string> ObjRotInfo;
    public List<string> ObjHashInfo;


    void Start()
    {
        clockText = this.GetComponent<TMP_Text>();
        TestObjs = GameObject.FindGameObjectsWithTag("Player");
        TestObj = GameObject.FindGameObjectWithTag("Test");    
        textBoxSize = this.GetComponent<RectTransform>();
        for (int i = 0; i < TestObjs.Length; i++)
        {
            ObjPosInfo.Add(TestObjs[i].GetComponent<PlayerInfo>().GetPlayerPos());
            ObjRotInfo.Add(TestObjs[i].GetComponent<PlayerInfo>().GetPlayerRot());
            ObjHashInfo.Add(TestObjs[i].GetComponent<PlayerInfo>().GetPlayerHash());
        }
    }

    void Update()
    {

 

        clockText.text = DateTime.Now.ToString() + "\n";
        //按下鼠标按键改变字体颜色
        if(Input.GetMouseButtonDown(0))
        {
            clockText.color = Color.blue;
        }
        if(Input.GetMouseButtonDown(1))
        {
            clockText.color = Color.green;
        }

        //按下小键盘数字1显示Test标签物体信息
        if(Input.GetKey(KeyCode.Keypad1))
        {
            clockText.text += "Object Info :" + TestObj.name;
        }

        //按下小键盘数字2显示Player标签物体信息
        if(Input.GetKey(KeyCode.Keypad2))
        {
            foreach(var item in TestObjs)
            {
                clockText.text += "Player["+ item.name + "]Material Info :" + item.GetComponent<MeshRenderer>().material.name + "\n";
            }
        }

        if(Input.GetKey(KeyCode.Keypad3))
        {            
            foreach (var item in ObjPosInfo)
            {
                clockText.text += item + "\n";
            }
        }

        if(Input.GetKey(KeyCode.Keypad4))
        {
            foreach(var item in ObjRotInfo)
            {
                clockText.text += item + "\n";
            }
        }

        if(Input.GetKey(KeyCode.Keypad5))
        {
            foreach(var item in ObjHashInfo)
            {
                clockText.text += item + "\n";
            }
        }

        //根据添加的字符串动态改变文本框大小（长和宽）
        Vector2 textSize = clockText.GetPreferredValues();
        textBoxSize.sizeDelta = new Vector2(textSize.x, textSize.y);

    }
}
