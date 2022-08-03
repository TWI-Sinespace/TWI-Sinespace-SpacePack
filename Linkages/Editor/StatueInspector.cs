using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

// DISTRIBUTABLE WITH EDITOR PACK
[CustomEditor(typeof (Statue))]
internal class StatueInspector : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        if (false && GUILayout.Button("Mesh Bake"))
        {
            var s = target as Statue;

            GameObject combined = new GameObject();
            //var baker = combined.AddComponent<MB2_MeshBaker>();

            combined.transform.position = s.transform.position;
            combined.transform.rotation = s.transform.rotation;

            List<GameObject> combines = new List<GameObject>();

            var skins = s.GetComponentsInChildren<SkinnedMeshRenderer>();
            foreach (var skin in skins)
            {
                Mesh m = new Mesh();
                skin.BakeMesh(m);

                GameObject t = new GameObject("Child SMR - " + skin.name);
                t.transform.position = skin.transform.position;
                t.transform.rotation = skin.transform.rotation;
                t.transform.localScale = skin.transform.lossyScale;
                t.AddComponent<MeshFilter>().sharedMesh = m;
                t.AddComponent<MeshRenderer>().sharedMaterials = skin.sharedMaterials;

                combines.Add(t);
            }

            var nonskin = s.GetComponentsInChildren<MeshRenderer>();
            foreach (var skin in nonskin)
            {
                GameObject t = new GameObject("Child MR - " + skin.name);
                t.transform.position = skin.transform.position;
                t.transform.rotation = skin.transform.rotation;
                t.transform.localScale = skin.transform.lossyScale;
                t.AddComponent<MeshFilter>().sharedMesh = skin.GetComponent<MeshFilter>().sharedMesh;
                t.AddComponent<MeshRenderer>().sharedMaterials = skin.sharedMaterials;

                combines.Add(t);
            }
            


        }
    }
}
