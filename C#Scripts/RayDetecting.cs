using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RayDetecting : MonoBehaviour
{

    void Update()
    {
        if(Input.GetKeyDown(KeyCode.E))
        {
            Ray detectRay = new Ray(transform.position, transform.forward);
            Debug.DrawLine(transform.position, transform.forward, Color.green);
            print(detectRay.GetPoint(5));
        }
    }
}
