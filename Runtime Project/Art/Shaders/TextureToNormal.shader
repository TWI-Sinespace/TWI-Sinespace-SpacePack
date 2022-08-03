// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Sine Wave/Internal/TextureToNormal" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
	SubShader {
		Pass {
			Cull Off 
			Lighting Off 
			ZWrite On 
			Fog { Mode Off }
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

			#include "UnityCG.cginc"
			
			sampler2D _MainTex;
			
			struct vertexInput {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct fragmentInput{
				float4 position : SV_POSITION;
				float4 texcoord : TEXCOORD0;
			};

			fragmentInput vert(vertexInput i){
				fragmentInput o;
				o.position = UnityObjectToClipPos (i.vertex);
				o.texcoord = i.texcoord;
				return o;
			}
			float4 frag(fragmentInput i) : COLOR {
				float4 col = tex2D(_MainTex, i.texcoord.xy);
				return float4(1, col.g, 1, pow(col.r, 1.0/2.2));
			}
			
			ENDCG
		}
	}
}