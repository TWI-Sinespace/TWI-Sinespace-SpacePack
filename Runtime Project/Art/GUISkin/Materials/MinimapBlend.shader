// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Sine Wave/UI/MiniMap Cutaway" {
	Properties { 
		_MainTex ("Base", 2D) = "white" {}
		_MiniMap ("MiniMap", 2D) = "white" {}
	}

	SubShader {
		Tags { "ForceSupported" = "True" }

		Lighting Off 
		Blend SrcAlpha OneMinusSrcAlpha 
		Cull Off 
		ZWrite Off 
		Fog { Mode Off } 
		ZTest Always

		Pass {	
			CGPROGRAM
// Upgrade NOTE: excluded shader from DX11 and Xbox360; has structs without semantics (struct v2f members texcoordAlt)
//#pragma exclude_renderers d3d11 xbox360
// Upgrade NOTE: excluded shader from Xbox360; has structs without semantics (struct v2f members texcoordAlt)
//#pragma exclude_renderers xbox360
			#pragma target 2.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest

			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				float2 texcoordAlt : TEXCOORD1;
			};

			sampler2D _MainTex;
			sampler2D _MiniMap;

			uniform float4 _MainTex_ST;
			uniform float4 _MiniMap_ST;
			uniform fixed4 _Color;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.texcoordAlt = TRANSFORM_TEX(v.texcoord,_MiniMap);
				return o;
			}

			fixed4 frag (v2f i) : COLOR
			{
				fixed4 frame = tex2D(_MainTex, i.texcoord).ggga;
			
				fixed4 col = frame;// * i.color;
				
				fixed4 map = tex2D(_MiniMap, i.texcoordAlt);
				
				col.rgb = lerp(map.rgb, col.rgb, frame.r);
				
				return col;
			}
			ENDCG 
		}
	} 	
}
