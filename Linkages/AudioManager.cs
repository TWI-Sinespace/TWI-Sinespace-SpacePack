using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEngine.Audio;

#if !SPACE_MAIN
[AddComponentMenu("")]
#endif
internal class AudioManager : AudioManagerBaseInternal
{
    public void Awake()
    {
        Instance = this;
        DontDestroyOnLoad(gameObject);
        Setup();
    }
}