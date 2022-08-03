#if !UNITY_2018_1_OR_NEWER
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

#if !SPACE_MAIN
[AddComponentMenu("")]
#endif
[RequireComponent(typeof(LightProbeGroup))]
public class ProbeArea : ProbeAreaBaseInternal
{
}
#endif