using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

#if !SPACE_MAIN
[AddComponentMenu("")]
#endif
internal class JukeboxVolumeHint : JukeboxVolumeHintBaseInternal
{
    public void Awake()
    {
        Jukeboxes.Add(this);
        Jukeboxes.RemoveAll(n => n == null);
    }
}
