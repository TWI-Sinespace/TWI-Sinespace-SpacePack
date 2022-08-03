using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;

public class TerrainDataStore : TerrainDataStoreBaseInternal
{
}

public class TerrainDataStoreBaseInternal : MonoBehaviour
{
    [SerializeField] [HideInInspector]
    public float[,] Heights;

    public Texture2D[] Textures;

}