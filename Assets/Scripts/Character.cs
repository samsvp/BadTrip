using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Character : MonoBehaviour
{

    [SerializeField]
    private float speed = 1f;
    [SerializeField]
    private float gSpeed = 2f;

    private Vector3 lastForward;
    private Rigidbody rb;

    private float lastY;

    // Start is called before the first frame update
    void Start()
    {
        lastForward = Vector3.zero;

        rb = GetComponent<Rigidbody>();
        lastY = transform.position.y;
    }

    // Update is called once per frame
    void Update()
    {
       
    }


    private void LateUpdate()
    {
        lastY = transform.position.y;
    }


    private void FixedUpdate()
    {
        UpdateQuaternion();
    }


    private void UpdateQuaternion()
    {
        RaycastHit hit;

        Vector3 input = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));


        Vector3 forward = input.z * transform.forward;
        Vector3 right = input.x * transform.right;
        Vector3 offset = 0.5f * transform.up;
        Vector3 movement = forward + right;
        Vector3 down = transform.TransformDirection(Vector3.down);


        if (Physics.Raycast(transform.position, down, out hit, 20 ))
        {
            DrawRays(hit);

            print(hit.distance);

            transform.position += (movement * speed - ((hit.normal - offset) * gSpeed)) * Time.fixedDeltaTime;
            transform.Rotate(0.0f, input.x * 5, 0.0f);
            transform.rotation = Quaternion.FromToRotation(transform.up, hit.normal) * transform.rotation;
        }
        else
        {
            Debug.DrawRay(transform.position, down * 1000, Color.white);
            rb.MovePosition(transform.position + input * Time.fixedDeltaTime * speed);
        }

        lastForward = forward;
    }


    private void DrawRays(RaycastHit hit)
    {
        Debug.DrawRay(transform.position, transform.TransformDirection(Vector3.down) * hit.distance * 3,
                Color.yellow);
        Debug.DrawRay(transform.position,
            hit.normal * hit.distance * 3, Color.blue);
        Debug.DrawRay(transform.position, hit.transform.right * hit.distance * 3,
            Color.green);
        Debug.DrawRay(transform.position, transform.forward * hit.distance * 3,
            Color.magenta);
    }




    private void OnTriggerEnter(Collider other)
    {
        
    }


    private void OnTriggerStay(Collider other)
    {
        
    }

}
