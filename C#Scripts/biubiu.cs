using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class biubiu : MonoBehaviour
{

    public GameObject obj;
    public float bulletSpeed = 5.0f;
    private Transform BulletShootPos;

    void Start()
    {
        BulletShootPos = this.transform;
    }

    void Update()
    {
        if(Input.GetMouseButtonDown(0))
        {
           Instantiate(obj, BulletShootPos.position + Vector3.forward, new Quaternion(0,0,0,0));
            obj.GetComponent<Rigidbody>().AddForce(Vector3.forward * 5.0f);
            obj.GetComponent<Rigidbody>().velocity = transform.forward * bulletSpeed;
        }
    }

    public GameObject Explodsion;
    void OnCollisionEnter()
    {
        Instantiate(Explodsion, transform.position, transform.rotation);
        Destroy(obj);
        Destroy(Explodsion);
    }
}
