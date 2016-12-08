using UnityEngine;
using System.Collections;

public class RaftDynamic : MonoBehaviour {

    public float occilationSpeedX;
    public float occilationSpeedY;
    public float occilationSpeedZ;

    void Start()
    {
        occilationSpeedZ = 0.05f;
        transform.Rotate(0, 0, -5.0f);
    }

    void Update()
    {
        transform.Rotate((Mathf.Sin(Time.time) * occilationSpeedX), (Mathf.Sin(Time.time) * occilationSpeedY), (Mathf.Sin(Time.time) * occilationSpeedZ));
    }
}
