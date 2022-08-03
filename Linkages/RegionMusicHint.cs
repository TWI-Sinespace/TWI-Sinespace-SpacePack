using UnityEngine;

[AddComponentMenu("")]
public class RegionMusicHint : RegionMusicHintBaseInternal
{
    public void Start()
    {
#if SPACE_MAIN
        RegionMusicHintManager.Register(this);
#endif
    }
}
