Shader "Custom/VertexColorHDR" {
	Properties {

	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Cull Off
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows
			
		// Use shader model 3.0 target, to get nicer looking lighting

		struct Input {
			float4 color : COLOR;
		};

		void surf (Input IN, inout SurfaceOutputStandard o) {
			o.Albedo = float3(0,0,0);
			// Metallic and smoothness come from slider variables
			o.Metallic = 0;
			o.Smoothness = 0;
			o.Alpha = 1;
			o.Emission = IN.color;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
