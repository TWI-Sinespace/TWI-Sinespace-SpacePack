using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class SWText : SWTextBaseInternal
{
#if UNITY_EDITOR
    public void OnDrawGizmosSelected()
    {
        if (NotLocalised || IsSymbol)
            return;

        if (string.IsNullOrEmpty(text))
            return;

        if (string.IsNullOrEmpty(TranslationKey))
        {
            UnityEditor.Handles.color = Color.red;
            UnityEditor.Handles.Label(transform.position, name + " is missing localisation");
        }
    }
#endif
}
