using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{

    private Transform cameraPos;
    public float moveSpeed = 2.0f;
    public float XAxisMouseMoveSpeed = 3.0f;
    public float YAxisMouseMoveSpeed = 3.0f;
    public float verticalRotate = 0;

    void Start()
    {
        cameraPos = GetComponent<Transform>();
    }

    
    void FixedUpdate()
    {
        //if(Input.GetKey(KeyCode.W))
        //{
        //    cameraPos.Translate(Vector3.Lerp(new Vector3(0,0,0.5f), Vector3.forward * moveSpeed,Time.deltaTime));
        //}

        //if(Input.GetKey(KeyCode.S))
        //{
        //    cameraPos.Translate(Vector3.Lerp(Vector3.back * moveSpeed,new Vector3(0,0,-0.5f),Time.deltaTime));  
        //}

        //if(Input.GetKey(KeyCode.D))
        //{
        //    cameraPos.Translate(Vector3.Lerp(new Vector3(0.5f,0,0),Vector3.right * moveSpeed,Time.deltaTime));
        //}

        //if(Input.GetKey(KeyCode.A))
        //{
        //    cameraPos.Translate(Vector3.Lerp(Vector3.left * moveSpeed, new Vector3(-0.5f,0,0), Time.deltaTime));
        //}

        //if(Input.GetKey(KeyCode.Space))
        //{
        //    cameraPos.Translate(Vector3.Lerp(new Vector3(0,0.5f,0),Vector3.up * moveSpeed,Time.deltaTime));
        //}

    }

    void Update()
    {
        float MouseX = Input.GetAxisRaw("Mouse X") * XAxisMouseMoveSpeed;
        float MouseY = Input.GetAxisRaw("Mouse Y") * YAxisMouseMoveSpeed;    
        //视角垂直移动
        verticalRotate -= MouseY * YAxisMouseMoveSpeed;
        verticalRotate = Mathf.Clamp(verticalRotate, -75.0f, 75.0f);
        cameraPos.transform.localEulerAngles = new Vector3(verticalRotate, 0, 0);
        //视角水平移动
        cameraPos.parent.rotation *= Quaternion.Euler(0,MouseX, 0);
    }
}
