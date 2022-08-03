#if UNITY_EDITOR || SPACE_DLL
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace space.SineWave
{
    [CustomEditor(typeof(VirtualGoodBundle))]
    internal class VirtualGoodBundleEditor : VirtualGoodBundleEditorBaseInternal
    {

    }
}
#endif