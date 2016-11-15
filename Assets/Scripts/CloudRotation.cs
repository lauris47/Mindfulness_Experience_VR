using UnityEngine;
using System.Collections;

public class CloudRotation : MonoBehaviour
{

    public Transform center;
    public Vector3 axis = Vector3.up;
    public float radius = 250.0f;
    public float rotationSpeed = 2.0f;

    private Vector3 newRotationPosition;

    public float occilationSpeed;
    private Vector3 startPosition;

    // Use this for initialization
    void Start()
    {
        transform.position = (transform.position - center.position).normalized * radius + center.position;
        occilationSpeed = 0.04f;
    }

    // Update is called once per frame
    void Update()
    {
        transform.RotateAround(center.position, axis, rotationSpeed * Time.deltaTime);
        Vector3 desiredPosition = (transform.position - center.position).normalized * radius + center.position;
        newRotationPosition = Vector3.MoveTowards(transform.position, desiredPosition, Time.deltaTime);
        startPosition = newRotationPosition;
        transform.position = new Vector3(startPosition.x, startPosition.y + (Mathf.Sin(Time.time) * occilationSpeed), startPosition.z);
    }
}