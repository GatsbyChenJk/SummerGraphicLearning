using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class biubiu : MonoBehaviour
{

    public GameObject obj;
    public float bulletSpeed = 20.0f;
    public Transform BulletShootPos;


    void Update()
    {

        //����ʾ����ֻ������Ԥ���壬û�иı�����Ԥ���������
        //if(Input.GetMouseButtonDown(0))
        //{
         //   Instantiate(obj, BulletShootPos.position + Vector3.forward, new Quaternion(0, 0, 0, 0));  
         //    obj.GetComponent<Rigidbody>().velocity = transform.forward * bulletSpeed;
       // }

        if (Input.GetMouseButtonDown(0))
        {
            GameObject bullet = Instantiate(obj, BulletShootPos.position, BulletShootPos.rotation); //as GameObject;
            bullet.GetComponent<Rigidbody>().velocity = bullet.transform.forward * bulletSpeed;
            Destroy(bullet, 2);
        }

        
    }

    public GameObject Explodsion;
    
}
