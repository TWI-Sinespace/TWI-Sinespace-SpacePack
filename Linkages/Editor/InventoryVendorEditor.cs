using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

// DISTRIBUTABLE WITH EDITOR PACK
[CustomEditor(typeof (InventoryVendor))]
class InventoryVendorEditor : Editor
{
    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        //var vendor = target as InventoryVendor;

        GUILayout.Label("Item", EditorStyles.boldLabel);

        EditorGUILayout.PropertyField(serializedObject.FindProperty("GameItemID"), new GUIContent("Curator ID"));

        GUILayout.Label("Canvas Display", EditorStyles.boldLabel);

        EditorGUILayout.PropertyField(serializedObject.FindProperty("LabelText"), new GUIContent("Item Display (Name)"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("MiosLabel"), new GUIContent("Price Display (Silver)"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("GoldLabel"), new GUIContent("Price Display (Gold)"));
        
        GUILayout.Label("Preview Focus", EditorStyles.boldLabel);

        EditorGUILayout.PropertyField(serializedObject.FindProperty("PreviewTransform"), new GUIContent("Preview Object"));

        serializedObject.ApplyModifiedProperties();
        
        //base.OnInspectorGUI();
    }
}
