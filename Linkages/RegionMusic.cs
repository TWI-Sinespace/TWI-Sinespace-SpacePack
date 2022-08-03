using System;
using System.Linq;
using UnityEngine;
using Random = UnityEngine.Random;
using AudioManager = AudioManagerBaseInternal;

[Serializable]
public class RegionMusicEntry
{
    public string URL;
    public float Length;
    public AudioClip AudioClip;
}

[AddComponentMenu("")]
[RequireComponent(typeof(AudioClip))]
public class RegionMusic : RegionMusicBaseInternal
{
}
