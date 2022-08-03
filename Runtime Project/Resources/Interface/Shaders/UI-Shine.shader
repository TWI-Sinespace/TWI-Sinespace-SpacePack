Shader "Sine Wave/UI/Shine" {
	Properties {
		_MainTex ("Base (RGBA)", 2D) = "white" {}
		_ShineTex("Shine Gradient (RGB)", 2D) = "white" {}
		_ShineFac("Shine Fac 0..1", Float) = 0
		_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
	}
	SubShader {
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert alpha:blend keepalpha
		//alphatest:_Cutoff
		sampler2D _MainTex;
		sampler2D _ShineTex;
		half _ShineFac;

		struct Input {
			float2 uv_MainTex;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			half4 c = tex2D (_MainTex, IN.uv_MainTex);
			half4 c2 = tex2D (_ShineTex, IN.uv_MainTex + float2(((1-saturate(_ShineFac)) - 0.5)*2, 0));

			c.rgb = c.rgb + (c2.rgb*c.a);

			o.Albedo = float3(0,0,0);
			o.Emission = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
