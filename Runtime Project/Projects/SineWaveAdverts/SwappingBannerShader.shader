Shader "Custom/SineWave Banner Boards/Banner Tile Scroll" {
	Properties {
		_Alpha ("Alpha (RGB)", 2D) = "white" {}
		_Beta ("Beta (RGB)", 2D) = "white" {}		
		_Wipe("Transition Progress", Range(0,1)) = 0
		_EmitAmount("Emission Amount", Range(0.5, 1)) = 0.5
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Lambert

		sampler2D _Alpha;
		sampler2D _Beta;
		sampler2D _SwapTile;
		float _Wipe;
		float _EmitAmount;


		struct Input {
			float2 uv_Alpha;
			float2 uv_Beta;
			float2 uv_SwapTile;
		};

		void surf (Input IN, inout SurfaceOutput o) {
			float yOff = _Wipe;
		
			half4 tx_a = tex2D (_Beta, IN.uv_Beta + float2(0,yOff));
			half4 tx_b = tex2D (_Alpha, IN.uv_Alpha + float2(0,yOff));
			

			half4 texA = IN.uv_Alpha.y > 1.0 - yOff ?
					tx_a : tx_b;
			
			o.Albedo = texA.rgb * (1.0 - _EmitAmount);
			o.Emission = texA.rgb * _EmitAmount;

			o.Alpha = texA.a;
		}
		ENDCG
	} 
	FallBack "Diffuse"
}
