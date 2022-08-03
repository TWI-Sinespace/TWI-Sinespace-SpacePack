#if UNITY_EDITOR || SPACE_DLL
using UnityEditor;
#endif
using UnityEngine;

[SpaceScript]
public class LandmarkBehaviour : LandmarkBehaviourBaseInternal
{
#if UNITY_EDITOR || SPACE_DLL
    [MenuItem("GameObject/Create Other/Landmark")]

    public static void PlaceLandmarkGameObject()
    {
        var pos = SceneView.lastActiveSceneView.camera.transform.position;
        var rot = SceneView.lastActiveSceneView.camera.transform.rotation.eulerAngles;
        rot.x = 0;
        rot.z = 0;


        GameObject g = new GameObject("Landmark", typeof(LandmarkBehaviour));
        g.transform.position = pos;
        g.transform.rotation = Quaternion.Euler(rot);
        Selection.activeGameObject = g;
    }

    [MenuItem("GameObject/Create Other/Landmark (at Zero)")]
    public static void PlaceLandmarkGameObjectAtZeroish()
    {
        var pos = new Vector3(0,2,0);
        var rot = new Vector3(0, 0, 0);
        rot.x = 0;
        rot.z = 0;


        GameObject g = new GameObject("Landmark", typeof(LandmarkBehaviour));
        g.transform.position = pos;
        g.transform.rotation = Quaternion.Euler(rot);
        Selection.activeGameObject = g;
        var lm = g.GetComponent<LandmarkBehaviour>();
        lm.SpawnRadius = 2f;
    }
#endif
}
