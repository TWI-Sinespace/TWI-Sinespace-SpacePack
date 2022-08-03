// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/GammaToLinear"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_gamma("Gamma",float) = 1.66
		_sub("Subtract",float) = 0.23
		_desat("Desaturate",float) = 0.1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float _gamma;
			float _sub;
			float _desat;

			float Luminance2( float3 c )
			{
				return dot( c, float3(0.22, 0.707, 0.071) );
			}

			float3 istep(float3 input) {
				return input * (2*(input*input) - 3*input + float3(2,2,2));
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				col = pow(col,1/_gamma) - _sub;

				col = lerp(Luminance2(col.rgb).rrrr,col,_desat);

				//col.rgb = (istep(col.rgb)) * lerp(float3(1,1,1),col.rgb,0.25);

				return col;
			}
			ENDCG
		}
	}
}
