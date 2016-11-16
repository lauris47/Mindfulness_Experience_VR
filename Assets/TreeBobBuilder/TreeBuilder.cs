using UnityEngine;
using System.Collections;

public class TreeBuilder : MonoBehaviour {

    public GameObject[] obj;
    public GameObject parentObj;
    public float scaleMin;
    public float scaleMax;
    
    private TerrainData terrainData;
    public Terrain terrain;


    private GameObject BuildRandomTree()
    {
        GameObject tree = obj[(int)Random.Range(0.0f,obj.Length)];
        return tree;
    }

    public void BuildTerrainTrees()
    {
        terrainData = Terrain.activeTerrain.terrainData;

        for (int i = 0; i < terrainData.treeInstanceCount; i++)
        {
            Vector3 treePos = new Vector3(
                (terrainData.treeInstances[i].position.x * terrainData.size.x) + terrain.transform.position.x, 
                (terrainData.treeInstances[i].position.y * terrainData.size.y) + terrain.transform.position.y, 
                (terrainData.treeInstances[i].position.z * terrainData.size.z) + terrain.transform.position.z);

            GameObject terrainTree = (GameObject)Instantiate(BuildRandomTree(), treePos, transform.rotation);
            terrainTree.transform.localScale *= Random.Range(scaleMin, scaleMax);
            terrainTree.transform.rotation = Quaternion.Euler(new Vector3(0.0f, Random.Range(0.0f, 360.0f), 0.0f));
            terrainTree.transform.parent = parentObj.transform;

        }
    }

}
