using UnityEngine;
using System.Collections;

public class RaftBuoyancy : MonoBehaviour {
    public Transform target;
    [SerializeField]
    private float rotationMultiplier;
    void LateUpdate()
    {

        transform.localRotation = Quaternion.Euler(new Vector3(transform.InverseTransformPoint(target.position).z, 0, -transform.InverseTransformPoint(target.position).x) * rotationMultiplier);
    }
}
