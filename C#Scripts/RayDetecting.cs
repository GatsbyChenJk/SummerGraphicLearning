using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayDetecting : MonoBehaviour
{
    //������ʵ�����ʰȡ
    void Update()
    {
        if(Input.GetMouseButtonDown(1))
        {
            RaycastHit hit;
            Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);   
            
            if(Physics.Raycast(ray, out hit))
            {
                if(hit.collider != null)
                {
                    Debug.Log("Hit on Object" + hit.collider.name);
                }
            }
        }
    }
}
