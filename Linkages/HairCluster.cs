using System;
using System.Collections.Generic;
using System.Linq;
using MIConvexHull;
using UnityEngine;

[ExecuteInEditMode]
#if !SPACE_MAIN
[AddComponentMenu("")]
#endif
	public class HairCluster : HairClusterBaseInternal
	{
        // Tool chain should have clip planes & emit planes.
        // Emit planes wrap the surface of the model below their placement, and emit following the plane normal (with slider for influence to mesh normal)
        // Clip planes should prevent the strands from passing through
	}
