using UnityEngine;
using System.Collections;
using UnityEditor;

[CustomEditor(typeof(TreeBuilder))]
public class TreeBuilderEditor : Editor
{
    public GameObject obj;

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        TreeBuilder myScript = (TreeBuilder)target;
        if (GUILayout.Button("Build Object"))
        {
            myScript.BuildTerrainTrees();
        }
    }
}