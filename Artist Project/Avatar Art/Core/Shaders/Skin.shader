Shader "Sine Wave/Skin Bumped" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_SpecColor ("Specular Color", Color) = (0.5, 0.5, 0.5, 1)
	_Shininess ("Shininess", float) = 0.078125
	_MainTex ("Base (RGB) Gloss (A)", 2D) = "white" {}
	_BumpMap ("Normalmap", 2D) = "bump" {}
    _RimPower ("Rim Power", float) = 3.0
	_LoadingColor("Loading Color", Color) = (0.705,1.0,1.0,0.0)
}
SubShader { 
	Tags { "RenderType"="Opaque" }
	LOD 100
	
CGPROGRAM
#pragma surface surf BlinnPhong nolightmap

sampler2D _MainTex;
sampler2D _BumpMap;
fixed4 _Color;
fixed4 _LoadingColor;
half _Shininess;
float _RimPower;

struct Input {
	float2 uv_MainTex;
	float2 uv_BumpMap;
	float3 viewDir;
};

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 tex = tex2D(_MainTex, IN.uv_MainTex);
	o.Albedo = tex.rgb * _Color.rgb * (1.0 - _LoadingColor.a);
	o.Gloss = _Color.a;
	o.Alpha = 0;//tex.a * _Color.a;
	o.Specular = _Shininess;
	o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
	
	half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
    o.Emission.rgb = lerp(o.Albedo.rgb * _SpecColor.rgb * pow (rim, _RimPower), _LoadingColor.rgb, _LoadingColor.a);
	//o.Emission.rgb = o.Emission.rgb * (1.0 + (22026.0*_LoadingColor.a));
	_SpecColor.rgb = o.Albedo.rgb;
}
ENDCG
}

FallBack "Specular"
}
