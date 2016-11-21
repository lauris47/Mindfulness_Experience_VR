using UnityEngine;
using System.Collections;

public class RaftBuoyancy : MonoBehaviour {
    public Transform target;
    [SerializeField]
    private float rotationMultiplier;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {

	}
    void LateUpdate()
    {
        transform.localRotation = Quaternion.Euler(new Vector3(transform.InverseTransformPoint(target.position).z, 0, -transform.InverseTransformPoint(target.position).x) * rotationMultiplier);
    }
}
