Shader "Sine Wave/Skin/Modern Skin" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecColor ("Specular Color", Color) = (1,1,1,1)
	_SpecBoost("Spec Boost", float) = 1.0
	_Shininess ("Shininess", float) = 0.078125
	_MainTex ("Base (RGB) Alpha Test (A)", 2D) = "white" {}
	_SpecTex ("Spec (RGB) Gloss (A)", 2D) = "white" {}
	_BumpMap ("Normal (RG)", 2D) = "bump" {}
	_NormalPower ("Normal Power", range(0,3)) = 1.0
	_EdgeLength ("Tessellation Edge Length", float) = 15
	_Phong ("Tessellation Phong Strength", float) = 0.5

	_Smoothness ("Smoothness", float) = 0.6892
	_CornerSmoothness ("Corner Smoothness", float) = 4

	_SmoothPower ("Edge Power", float) = 2
	_SmoothSubPower ("Edge Power Subtract", float) = 4
	
	_SSS ("Simulated Scattering", range(0,5)) = 0.5

	_LoadingColor("Loading Color", Color) = (0.705,1.0,1.0,0.0)

	_DetailTex("Details", 2D) = "white" {}
	_DetailNormal("Detail (Normal)", 2D) = "" {}
	_NormalPower2("Detail Normal", range(0,3)) = 1.0
	_DetailPower("Detail Occlusion", range(0,3)) = 1.0

	_PoresTex("Pores", 2D) = "white" {}
	_PoresNormal("Pores (Normal)", 2D) = "" {}
	_NormalPower3("Pores Normal", range(0,3)) = 1.0
	_PoresPower("Pores Occlusion", range(0,3)) = 1.0

}
SubShader { 
	Tags { "RenderType"="Opaque" }
	

	Pass{
		ColorMask 0
	}

CGPROGRAM

half _Smoothness;
half _CornerSmoothness;

half _SpecBoost;

half _SmoothPower;
half _SmoothSubPower;

sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _SpecTex;
sampler2D _DetailTex;
sampler2D _DetailNormal;
sampler2D _PoresTex;
sampler2D _PoresNormal;

half _PoresPower;
half _DetailPower;

half _NormalPower2;
half _NormalPower3;

half _SSS;

fixed4 _Color;
half _Shininess;
half _NormalPower;
half4 _LoadingColor;

#include "UnityPBSLighting.cginc"

inline half4 LightingStandardSpecular2 (SurfaceOutputStandardSpecular s, half3 viewDir, UnityGI gi)
{
	s.Normal = normalize(s.Normal);

	// energy conservation
	half oneMinusReflectivity;
	s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);

	// shader relies on pre-multiply alpha-blend (_SrcBlend = One, _DstBlend = OneMinusSrcAlpha)
	// this is necessary to handle transparency in physically correct way - only diffuse component gets affected by alpha
	half outputAlpha;
	s.Albedo = PreMultiplyAlpha (s.Albedo, s.Alpha, oneMinusReflectivity, /*out*/ outputAlpha);

	half4 c = UNITY_BRDF_PBS (s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
	c.rgb += UNITY_BRDF_GI (s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, s.Occlusion, gi);
	c.a = outputAlpha;
	return c;
}

inline half4 LightingStandardSpecular2_Deferred (SurfaceOutputStandardSpecular s, half3 viewDir, UnityGI gi, out half4 outGBuffer0, out half4 outGBuffer1, out half4 outGBuffer2)
{
	// energy conservation
	half oneMinusReflectivity;
	s.Albedo = EnergyConservationBetweenDiffuseAndSpecular (s.Albedo, s.Specular, /*out*/ oneMinusReflectivity);

	half4 smoothFactor =  saturate(pow(1.0 - abs(dot(s.Normal, viewDir)),_SmoothPower) - pow(1.0 - abs(dot(s.Normal, viewDir)),_SmoothSubPower));
	s.Smoothness = lerp(s.Smoothness,s.Smoothness*_CornerSmoothness, smoothFactor) * s.Occlusion;
	
	half4 c = UNITY_BRDF_PBS (s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, gi.light, gi.indirect);
	c.rgb += UNITY_BRDF_GI (s.Albedo, s.Specular, oneMinusReflectivity, s.Smoothness, s.Normal, viewDir, s.Occlusion, gi);

	// Begin Janky SSS Hack...
	half4 orig=c;
	
	UnityStandardData data;
	data.diffuseColor	= s.Albedo * ((_SpecBoost * smoothFactor) + 1);
	data.occlusion		= s.Occlusion;		
	data.specularColor	= s.Specular;
	data.smoothness		= s.Smoothness;	
	data.normalWorld	= s.Normal;

	UnityStandardDataToGbuffer(data, outGBuffer0, outGBuffer1, outGBuffer2);

	// Janky SSS Hack ------------------------------> !! Here !!
	half4 emission = half4(s.Emission + c.rgb + (orig.rgb*(s.Albedo*(_SSS))), 1);
	//emission.g = smoothFactor;//pow(1.0 - abs(dot(s.Normal, viewDir)),6);
	
	return emission;
}

inline void LightingStandardSpecular2_GI (
	SurfaceOutputStandardSpecular s,
	UnityGIInput data,
	inout UnityGI gi)
{
#if defined(UNITY_PASS_DEFERRED) && UNITY_ENABLE_REFLECTION_BUFFERS
	gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal);
#else
	Unity_GlossyEnvironmentData g = UnityGlossyEnvironmentSetup(s.Smoothness, data.worldViewDir, s.Normal, s.Specular);
	gi = UnityGlobalIllumination(data, s.Occlusion, s.Normal, g);
#endif
}

#pragma target 3.0
#pragma surface surf StandardSpecular2 nolightmap keepalpha vertex:dispNone tessellate:tessEdge tessphong:_Phong


//Add to surf line: vertex:dispNone tessellate:tessEdge tessphong:_Phong nolightmap

#include "Tessellation.cginc"

float _EdgeLength;
float _Phong;

struct appdata {
				float4 tangent : TANGENT;
                float4 vertex : POSITION;
				float4 color : COLOR;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
            };

void dispNone (inout appdata v) { 
	v.vertex.xyz -= v.normal * (1.0 - _Phong) * 0.004 * 0;

}

float4 tessEdge (appdata v0, appdata v1, appdata v2)
{
    return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
}
//*/

struct Input {
	float2 uv_MainTex;
	float2 uv_SpecTex;
	float2 uv_BumpMap;
	float2 uv2_DetailNormal;
	float2 uv2_PoresNormal;
	float3 viewDir;
	float4 color: Color;
};

inline fixed3 combineNormalMaps(fixed3 base, fixed3 detail) {
	base += fixed3(0, 0, 1);
	detail *= fixed3(-1, -1, 1);
	return base * dot(base, detail) / base.z - detail;
}

void surf (Input IN, inout SurfaceOutputStandardSpecular o) {
	fixed4 spec =  tex2D(_SpecTex, IN.uv_SpecTex) * _SpecColor;

	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	fixed4 tex2 = tex2D(_DetailTex, IN.uv2_DetailNormal);
	fixed4 tex3 = tex2D(_PoresTex, IN.uv2_PoresNormal);
	fixed3 texMod = lerp(tex*_Color.rgb * 0.847,tex.rgb, IN.color.g);

	o.Albedo = texMod.rgb * 1.0;// *lerp(tex3.rgb, float3(1, 1, 1), saturate(1 - _PoresPower));
	o.Alpha = 0;
	o.Specular = spec.rgb + (tex2.r * (1.0 - IN.color.g) * tex.rgb) * _Shininess * _SpecColor * lerp(tex3.rrr,1,0.9) * tex2.rrr;// 0.95 * texMod.rgb * spec.a * _Shininess;// _SpecColor;//spec.rgb * 8.1;

	fixed3 normal = (UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap)));
	//normal.z = normal.z * _NormalPower;
	normal = lerp(float3(0,0,1), normal, _NormalPower);
	
	fixed3 normal2 = UnpackNormal(tex2D(_DetailNormal , IN.uv2_DetailNormal));
	normal2 = (lerp(float3(0,0,1), normal2, _NormalPower2 * saturate(spec.r * 15)));
	//normal2.z = normal2.z * _NormalPower2;

	fixed3 normal3 = UnpackNormal(tex2D(_PoresNormal, IN.uv2_PoresNormal));
	normal3 = (lerp(float3(0,0,1), normal3, _NormalPower3 * saturate(spec.r * 15)));
	//normal3.z = normal3.z * _NormalPower3;

	o.Normal = lerp(combineNormalMaps(normalize(normal3),combineNormalMaps(normalize(normal), normalize(normal2))), float3(0, 0, 1), IN.color.g);
	
	o.Albedo = o.Albedo * (1.0 - _LoadingColor.a);
	o.Emission.rgb = (_LoadingColor.rgb * _LoadingColor.a) * 30;

	//#if SHADER_TARGET < 30 || SHADER_API_GLCORE || SHADER_API_OPENGL || SHADER_API_METAL || SHADER_API_GLES || SHADER_API_GLES3
	//o.Smoothness = _Smoothness * tex2.r;//0.6892;
	//o.Occlusion = lerp(tex2.r, 1.0, 0.75);//.5;//2.5; //148 / 0.892;
	//#else 
	o.Smoothness = (spec.a * tex2.r * tex3.r);// lerp(_Smoothness * lerp(1.0, tex2.r, _DetailPower), 0.6, IN.color.g) * saturate(spec.a * 8);// *tex2.r * tex3.r;//0.6892;
	_CornerSmoothness = lerp(_CornerSmoothness, 1.0, IN.color.g);
	o.Occlusion = lerp(tex2.r,1.0, _DetailPower) * lerp(tex3.r,1.0,_PoresPower);//lerp(tex2.r * tex3.r, 1.0, ) ;//.5;//2.5; //148 / 0.892;
	//#endif

	o.Alpha = 1.0;

	
	
	//_SpecColor.rgb = o.Albedo.rgb;
}

ENDCG
}

FallBack "Sine Wave/Skin/Modern Skin Fallback"
}
