// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Sine Wave/Internal/Composite Player Skin" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_ColorA ("R Color", Color) = (0,0,0,0)
		_ColorB ("G Color", Color) = (0,0,0,0)
		_ColorC ("B Color", Color) = (0,0,0,0)
		_Color ("Tint Color", Color) = (1,1,1,1)
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
			half4 _ColorA;
			half4 _ColorB;
			half4 _ColorC;
			half4 _Color;
			
			float TriLerp(float a, float b, float c, half3 f)
			{
				half total = f.x + f.y + f.z;
				return (a*(f.x/total)) + (b*(f.y/total)) + (c*(f.z/total));
			}
			
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
				half4 col = tex2D(_MainTex, i.texcoord.xy);
			
				half cl = saturate(col.r + col.g + col.b);
				half4 newcol = half4(
								TriLerp(_ColorA.r, _ColorB.r, _ColorC.r, col.rgb) * cl,
								TriLerp(_ColorA.g, _ColorB.g, _ColorC.g, col.rgb) * cl,
								TriLerp(_ColorA.b, _ColorB.b, _ColorC.b, col.rgb) * cl,
								1
								);
				
				//return float4(1,1,0,0);
				
				return lerp(col, newcol, col.a) * _Color * float4(1,1,1,0);
			}
			ENDCG
		}
	}
}