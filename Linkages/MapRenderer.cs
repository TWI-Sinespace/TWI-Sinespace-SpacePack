using System.Linq;
using UnityEngine;

#if !SPACE_MAIN
[AddComponentMenu("")]
#endif
public class MapRenderer : MapRendererBaseInternal
{

    new public static MapRenderer Instance
    {
        get { return (MapRenderer)_mapRender; }
    }

    new public void Start()
    {
        _mapRender = this;
        base.Start();
    }
}