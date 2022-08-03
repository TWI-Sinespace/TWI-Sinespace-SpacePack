using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MIConvexHull;
using UnityEngine;

public class ZoneInterest
{
    public Vector3 Position;
    public Quaternion Rotation;
    public float StartInterest;
    public float EndInterest;
    public float InterestLevel;
}

#if !SPACE_MAIN
[AddComponentMenu("")]
#endif
[RequireComponent(typeof(MeshCollider))]
public class Zone : ZoneBaseInternal
{
    public void Awake()
    {
#if SPACE_MAIN
        Collider = GetComponent<MeshCollider>();
        ZoneManager.Register(this);
#endif
    }
}

