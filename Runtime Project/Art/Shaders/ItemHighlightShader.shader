// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/ItemHighlightShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color",Color) = (1,1,1,1)
		_HDR("HDR",Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass {
		    ZTest Always 
			Cull Off 
			ZWrite Off
			ColorMask A
			SetTexture [_Dummy] {
				constantColor(0,0,0,0) combine constant 
			}
		}

		Pass
		{
			ZTest Always 
			Cull Off 
			ZWrite Off
			ColorMask RGB
			Blend One One

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 uv : TEXCOORD0;
			};

			float4 _Color;
			float _HDR;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv =  ComputeScreenPos(o.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				half aspect = _ScreenParams.y / _ScreenParams.x;

				fixed4 col = tex2D(_MainTex, (i.uv.xy / i.uv.w) * float2(1,aspect) * (_ScreenParams.x / 256)) * _Color * _HDR;
				col.a = 0;

				return col;
			}
			ENDCG
		}
	}
}
