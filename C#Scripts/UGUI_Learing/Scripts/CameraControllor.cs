using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControllor : MonoBehaviour
{

    public Transform target = null; // 物体的Transform组件
    public float rotationSpeed = 1f; // 摄像机旋转速度   
    //public RectTransform CanvasTrans = null;

    private float mouseX; // 鼠标在水平方向上的移动距离
    private float mouseY; // 鼠标在竖直方向上的移动距离

    void Update()
    {
        if (Input.GetMouseButton(1))
        {
            mouseX += Input.GetAxis("Mouse X") * rotationSpeed;
            mouseY -= Input.GetAxis("Mouse Y") * rotationSpeed;
        }

        if (target)
        {
            // 计算摄像机的位置和旋转
            Vector3 offset = Quaternion.Euler(mouseY, mouseX, 0) * new Vector3(0, 0, -10);
            transform.position = target.position + offset;
            transform.LookAt(target);
        }
    }
}
