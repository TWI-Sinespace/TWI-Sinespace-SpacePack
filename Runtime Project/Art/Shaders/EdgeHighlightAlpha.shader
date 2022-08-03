// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/Edge Highlight Alpha" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_MaskTex("Mask (RGB)", 2D) = "white" {}
	_Threshold ("Treshold", Float) = 0.2
	_Color("Color", Color) = (1,1,1,1)
}

SubShader {
	Pass {
		ZTest Always Cull Off ZWrite Off
		Fog { Mode off }
		ColorMask RGBA

CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma fragmentoption ARB_precision_hint_fastest 
#include "UnityCG.cginc"

uniform sampler2D _MainTex;
uniform sampler2D _MaskTex;
uniform float4 _MainTex_TexelSize;
uniform float4 _MaskTex_TexelSize;
uniform float _Threshold;
uniform float3 _Color;

struct v2f {
	float4 pos : POSITION;
	float2 uv[3] : TEXCOORD0;
};

v2f vert( appdata_img v )
{
	v2f o;
	o.pos = UnityObjectToClipPos (v.vertex);
	float2 uv = MultiplyUV( UNITY_MATRIX_TEXTURE0, v.texcoord );
	o.uv[0] = uv;
	o.uv[1] = uv + float2(-_MainTex_TexelSize.x, -_MainTex_TexelSize.y);
	o.uv[2] = uv + float2(+_MainTex_TexelSize.x, -_MainTex_TexelSize.y);
	return o;
}


half4 frag (v2f i) : COLOR
{
	half4 original = tex2D(_MainTex, i.uv[0]);

	// a very simple cross gradient filter
	half3 p1 = tex2D( _MaskTex, i.uv[0] ).aaa;
	half3 p2 = tex2D( _MaskTex, i.uv[1] ).aaa;
	half3 p3 = tex2D( _MaskTex, i.uv[2] ).aaa;
	
	half3 diff = p1 * 2 - p2 - p3;
	half len = dot(diff,diff);


	if( len >= 0.01f )
		original.rgb = 40 * _Color;

	original.a = 0; // Clear alpha when we're done.
	
	//original.b = 1;
		
	return original;
}
ENDCG
	}
}

Fallback off

}