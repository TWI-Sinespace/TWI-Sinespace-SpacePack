using System;
using UnityEngine;

[Serializable]
public enum CommonRegionNames
{
    Custom = 0,
    Sol = 11,
    Aria = 13,
    Noom = 2,
    Turqua = 8,
    Mauryavaas = 3,
    Promenade = 9,
    Snowflash = 4,
    Neon = 20
}

[AddComponentMenu("Sinespace/Scenes/Inter-Region Teleport (TeleportWorld)")]
[SpaceScript]
public class TeleportWorld : TeleportWorldBaseInternal
{
}
