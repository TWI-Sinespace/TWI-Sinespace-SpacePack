#if UNITY_EDITOR || SPACE_DLL
using SpaceUnityLib;
using SpaceUnityLib.RegionServices;
using UnityEditor.SceneManagement;
using UnityEditor;

[CustomEditor(typeof(SceneSaveSettings))]
public class SceneSaveSettingsEditor : SceneSaveSettingsEditorBaseInternal
{
}
#endif