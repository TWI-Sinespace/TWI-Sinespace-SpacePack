Shader "Sine Wave/Skin/Bumped Spec" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_Shininess ("Shininess", float) = 0.078125
	_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
	_SpecTex ("Spec (RGB) Gloss (A)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
    _RimPower ("Rim Power", float) = 3.0
	_NormalPower ("Normal Power", float) = 1.0
}
SubShader { 
	Tags { "RenderType"="Opaque" }
	LOD 400
	
CGPROGRAM
#pragma surface surf BlinnPhong nolightmap

sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _SpecTex;
fixed4 _Color;
half _Shininess;
half _RimPower;
half _NormalPower;

struct Input {
	float2 uv_MainTex;
	float2 uv_SpecTex;
	float2 uv_BumpMap;
	float3 viewDir;
};

void surf (Input IN, inout SurfaceOutput o) {
	_SpecColor =  tex2D(_SpecTex, IN.uv_SpecTex);

	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	o.Albedo = tex.rgb * _Color.rgb;
	o.Gloss = _Color.a;
	o.Alpha = tex.a * _Color.a;
	o.Specular = _Shininess;

	fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
	normal.z = normal.z * _NormalPower;
	o.Normal = normalize(normal);

	half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
    o.Emission.rgb = o.Albedo.rgb * _SpecColor.rgb * pow (rim, _RimPower);
	
	//_SpecColor.rgb = o.Albedo.rgb;
}
ENDCG
}

FallBack "Specular"
}
