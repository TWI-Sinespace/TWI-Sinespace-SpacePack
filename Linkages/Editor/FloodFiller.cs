using System.Collections.Generic;
using UnityEngine;

#if !SPACE_MAIN
[AddComponentMenu("")]
#endif
[ExecuteInEditMode]
[RequireComponent(typeof(MeshFilter),typeof(MeshRenderer))]
internal class FloodFiller : FloodFillerBaseInternal
{
}
