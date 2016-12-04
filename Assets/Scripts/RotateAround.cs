using UnityEngine;
using System.Collections;

public class RotateAround : MonoBehaviour {
    void LateUpdate(){
        transform.Rotate(Vector3.back * Time.deltaTime * 10);
    }
}
