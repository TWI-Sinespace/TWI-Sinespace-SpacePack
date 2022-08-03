using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

#if !SPACE_MAIN
[AddComponentMenu("")]
#endif
[RequireComponent(typeof(MeshFilter),typeof(MeshRenderer))]
internal class LathedPath : LathedPathBaseInternal
{
}
