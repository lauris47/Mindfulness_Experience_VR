using UnityEngine;
using System.Collections;

public class ActivateDepthBuffer : MonoBehaviour {


	void Start () {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
	}
	
}
