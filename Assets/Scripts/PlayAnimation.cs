using UnityEngine;
using System.Collections;

public class PlayAnimation : MonoBehaviour {

	// Use this for initialization
	void Start () {

	}
	
	// Update is called once per frame
	void Update () {

        


    }

    void OnTriggerEnter(Collider other)
    {
  
        print("in");
        GetComponent<Animator>().Play("Default");
    }
}
