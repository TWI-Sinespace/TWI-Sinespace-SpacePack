Shader "Sine Wave/Skin/Unified Clothing and Skin" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecColor ("Specular Color", Color) = (1,1,1,1)
	_Shininess ("Shininess", float) = 0.078125
	_MainTex ("Base (RGB) Alpha Test (A)", 2D) = "white" {}
	_SpecTex ("Spec (RGB) Gloss (A)", 2D) = "white" {}
	_BumpMap ("Normal (RG)", 2D) = "bump" {}
    _RimPower ("Rim Power", float) = 3.0
	_RimHDR ("Rim HDR", float) = 1.0
	_NormalPower ("Normal Power", float) = 1.0
	_EdgeLength ("Tessellation Edge Length", float) = 15
	_Phong ("Tessellation Phong Strength", float) = 0.5

	_SpecAmount ("Specular Amount",float) = 1.0
	_GlossAmount("Gloss Amount",float) = 1.0

	_Smoothness ("Smoothness", float) = 0.6892
	_Occlusion ("Occlusion", float) = 2.5


	_LoadingColor("Loading Color", Color) = (0.705,1.0,1.0,0.0)

}
SubShader { 
	Tags { "RenderType"="Opaque" }
	LOD 500
	
CGPROGRAM
#pragma surface surf StandardSpecular nolightmap keepalpha

#pragma target 3.0

/*
//Add to surf line: vertex:dispNone tessellate:tessEdge tessphong:_Phong

#include "Tessellation.cginc"

float _EdgeLength;
float _Phong;

struct appdata {
				float4 tangent : TANGENT;
                float4 vertex : POSITION;
				float4 color : COLOR;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

void dispNone (inout appdata v) { }

float4 tessEdge (appdata v0, appdata v1, appdata v2)
{
    return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
}
*/

half _SpecAmount;
half _GlossAmount;
half _Smoothness;
half _Occlusion;



sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _SpecTex;
fixed4 _Color;
half _Shininess;
half _RimPower;
half _RimHDR;
half _NormalPower;
half4 _LoadingColor;

struct Input {
	float2 uv_MainTex;
	float2 uv_SpecTex;
	float2 uv_BumpMap;
	float3 viewDir;
	float4 color: Color;
};

void surf (Input IN, inout SurfaceOutputStandardSpecular o) {
	fixed4 spec =  tex2D(_SpecTex, IN.uv_SpecTex) * _SpecColor;

	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	fixed3 texMod = lerp(tex*_Color.rgb,tex.rgb, IN.color.g);

	o.Albedo = texMod.rgb * 1.0;
	o.Alpha = 0;
	o.Specular = 0.95 * texMod.rgb * spec.a * _Shininess;// _SpecColor;//spec.rgb * 8.1;

	fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
	normal.z = normal.z * _NormalPower;
	o.Normal = normalize(normal);
	
	o.Albedo = o.Albedo * (1.0 - _LoadingColor.a);
	o.Emission.rgb = (_LoadingColor.rgb * _LoadingColor.a) * 30;

	#if SHADER_TARGET < 30 || SHADER_API_GLCORE || SHADER_API_OPENGL || SHADER_API_METAL || SHADER_API_GLES || SHADER_API_GLES3
	o.Smoothness = _Smoothness;//0.6892;
	o.Occlusion = 0.892;//.5;//2.5; //148 / 0.892;
	#else 
	o.Smoothness = _Smoothness;//0.6892;
	o.Occlusion = _Occlusion;//.5;//2.5; //148 / 0.892;
	#endif

	//_SpecColor.rgb = o.Albedo.rgb;
}

ENDCG
}

FallBack "Specular"
}
