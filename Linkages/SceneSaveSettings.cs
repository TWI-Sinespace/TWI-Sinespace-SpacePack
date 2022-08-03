using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using space.SineWave;
#if UNITY_EDITOR
using SpaceUnityLib;
using SpaceUnityLib.RegionServices;
using UnityEditor.SceneManagement;
using UnityEditor;
#endif
using UnityEngine;
using UnityEngine.SceneManagement;
using Object = UnityEngine.Object;
using SceneManager = UnityEngine.SceneManagement.SceneManager;

[SpaceScript]
[AddComponentMenu("Sinespace/Scenes/Scene Save Settings", 0)]
[RequireComponent(typeof(VirtualGood))]
public class SceneSaveSettings : SceneSaveSettingsBaseInternal
{
#if UNITY_EDITOR || SPACE_DLL
    [MenuItem("Sinespace/Scene Settings")]
    public static void PlaceGameObject()
    {
        var existing = FindObjectOfType<SceneSaveSettings>();

        if (existing != null)
        {
            Debug.Log("Already a Scene Settings in the scene.");
            Selection.activeGameObject = existing.gameObject;
            return;
        }

        var o = new GameObject("Scene Export Settings", typeof(SceneSaveSettings));
        Selection.activeGameObject = o;

        var virtualGood = o.GetComponent<VirtualGood>();
        if (virtualGood != null)
        {
            virtualGood.Type = ContentType.Region;
        }
    }
#endif
}

