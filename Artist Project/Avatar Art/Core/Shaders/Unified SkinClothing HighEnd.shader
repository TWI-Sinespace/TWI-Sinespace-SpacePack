Shader "Sine Wave/Skin/Unified Clothing and Skin (Metal + Tessellate)" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)

	_MainTex ("Base (RGB)", 2D) = "white" {}
	_ParallaxMap("Height Map (R)", 2D) = "white" {}
	_Displacement("Height Amount (m)",float) = 0.002
	_DisplacementOff("Height Offset",range(-1,1)) = 0
	_MetallicGlossMap ("Metal (R) Smoothness (A)", 2D) = "white" {}
	_OcclusionMap("Occlusion", 2D) = "white" {}
	_BumpMap ("Normal (RG)", 2D) = "bump" {}
    _NormalPower ("Normal Power", float) = 1.0
	_EdgeLength ("Tessellation Edge Length", range(5,100)) = 15
	_Phong ("Tessellation Phong Strength", range(0,1)) = 0.5
	
	_RimPower ("Fallback Rim Power", float) = 3.0
	_RimHDR ("Fallback Rim HDR", float) = 1.0
	_SpecColor ("Fallback Specular", Color) = (1,1,1,1)
	_Shininess ("Fallback Shininess", float) = 0.078125
	_SpecAmount ("Fallback Specular",float) = 1.0
	_GlossAmount("Fallback Gloss",float) = 1.0

	_Smoothness ("Falback Smoothness", float) = 0.6892
	_Occlusion ("Fallback Occlusion", float) = 2.5
	_OcclusionAmount("Occlusion Amount", range(0,1)) = 1

	_LoadingColor("Loading Color (Ignore)", Color) = (0.705,1.0,1.0,0.0)

}
SubShader { 
	Tags { "RenderType"="Opaque" }
	LOD 500
	
CGPROGRAM
#pragma surface surf Standard nolightmap keepalpha vertex:disp tessellate:tessEdge tessphong:_Phong

#pragma target 4.6

#include "Tessellation.cginc"

float _EdgeLength;
float _Phong;

half _Displacement;
half _DisplacementOff;

sampler2D _ParallaxMap;
sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _MetallicGlossMap;
sampler2D _OcclusionMap;
fixed4 _Color;
half _Shininess;
half _RimPower;
half _RimHDR;
half _NormalPower;
half4 _LoadingColor;
float _OcclusionAmount;

struct appdata {
				float4 tangent : TANGENT;
                float4 vertex : POSITION;
				float4 color : COLOR;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

void disp(inout appdata v)
{
	float d = (saturate(tex2Dlod(_ParallaxMap, float4(v.texcoord.xy, 0, 0)).r + _DisplacementOff) * _Displacement);
	v.vertex.xyz += v.normal * d * saturate(1.0 - v.color.r *50);
}

float4 tessEdge (appdata v0, appdata v1, appdata v2)
{
	float p = ((v0.color.r) + (v1.color.r) + (v2.color.r));

    return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength * (1+p*0));
}

struct Input {
	float2 uv_MainTex;
	float2 uv_MetallicGlossMap;
	float2 uv_BumpMap;
	float3 viewDir;
	float4 color: Color;
};

void surf (Input IN, inout SurfaceOutputStandard o) {
	fixed4 spec =  tex2D(_MetallicGlossMap, IN.uv_MetallicGlossMap);
	fixed4 occlusion = tex2D(_OcclusionMap, IN.uv_MetallicGlossMap);

	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	fixed3 texMod = lerp(tex*_Color.rgb,tex.rgb, IN.color.g);

	o.Albedo = texMod.rgb * 1.0;
	o.Alpha = 0;
	o.Metallic = spec.r;
	o.Smoothness = spec.a;

	fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
	normal.z = normal.z * _NormalPower;
	o.Normal = normalize(normal);
	
	o.Albedo = o.Albedo * (1.0 - _LoadingColor.a);
	o.Emission.rgb = ((_LoadingColor.rgb * _LoadingColor.a) * 30);// +IN.color.rgb;
	o.Occlusion = lerp(1,occlusion.r,_OcclusionAmount);

}

ENDCG
}

FallBack "Sine Wave/Skin/Unified Clothing and Skin (Mid)"
}
