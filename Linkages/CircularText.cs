using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

[ExecuteInEditMode]
#if !SPACE_MAIN
[AddComponentMenu("")]
#endif
[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class CircularText : CircularTextBaseInternal
{
}
