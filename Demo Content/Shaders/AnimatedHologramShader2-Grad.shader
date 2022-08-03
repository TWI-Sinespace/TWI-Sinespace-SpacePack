Shader "Sine Wave/Geometry/Animated Hologram Shader V2 - No Trans Gradient" {
	Properties {
		_MainTex("Main Texture", 2D) = "white" {}
		_ShardCol1("Color #1", Color) = (1,0,0,0)
		_ShardCol2("Color #2", Color) = (0,1,0,0)
		_Color2("Rim Color", Color) = (1,1,1,0.5)
		_Beams("Beams (A)", 2D) = "white" {}
		_Color ("Main Color", Color) = (1,1,1,0.5)
		_Specularity("Rim",float) = 1
		_LineSpeed("Line Speed",float) = 1
		_UVs("Effect UVs",Vector) = (1,1,1,1)
	}
	SubShader {
		Tags { 
			"RenderType"="Transparent"
			"Queue"="Transparent"
			"IgnoreProjector" = "true"
		}
		LOD 200
		/*
		Pass {
			Fog {
				Mode Off
			}
			Cull off
			ZWrite On
			ColorMask 0
		}
		*/
		Cull back
		Fog {
			Mode Off
		}
		
		CGPROGRAM
		#pragma surface surf Lambert nolightmap
		// TODO: Make a shadermodel 2 version of this.
		#pragma target 2.0

		sampler2D _MainTex;
		sampler2D _Beams;
		float4 _Color;
		float4 _Color2;
		float4 _ShardCol1;
		float4 _ShardCol2;
		float _Specularity;
		float _LineSpeed;
		float4 _UVs;
		
		//sampler2D _GrabTexture;
		//float4 _GrabTexture_TexelSize;

		struct Input {
			float2 uv_MainTex;
			float3 viewDir;
			float4 screenPos;
			float3 worldPos;
			float4 proj : TEXCOORD;
		}; 
		
		// Wrapped lambert with specular component and rim lighting.
		half4 LightingWrapLambert (SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
		  half NdotL = dot (s.Normal, lightDir);
		  half rim = 1.0 - saturate(dot (normalize(viewDir), s.Normal)); 
		
		  half3 h = normalize (lightDir + viewDir);
		  float nh = max (0, dot (s.Normal, h));
  		  float spec = pow (nh, 32.0);
  		  half3 specCol = spec * s.Specular;
		  
		  rim = pow(rim, _Specularity); 
		  
		  half diff = (NdotL * 0.5) + 0.5;
		  half4 c;
		  c.rgb = (s.Albedo * _LightColor0.rgb * (diff * atten * 2)) + (_LightColor0.rgb * specCol) +
		  		(_LightColor0.rgb * (diff * atten * 5) * rim * _Color.rgb * diff * s.Albedo.rgb * _Color.a);
				// * (_Color.aaa + (rim * _Color.rgb));
		  c.a = s.Alpha;
		  return c;
		}

		void surf (Input IN, inout SurfaceOutput o) {
			float3 c = _Color2.rgb;
			
			float2 screenUV = IN.screenPos.xy / IN.screenPos.w;
			float2 screenUVH = screenUV * float2(_UVs.x,_UVs.y);
			screenUVH += float2(0, _Time.y) * _LineSpeed;
			
			float holoLines = tex2D(_Beams, screenUVH).a;
			
			o.Albedo = tex2D(_MainTex, IN.uv_MainTex);

			//float4 shard = tex2D(_Shard,screenUV * float2(_UVs.z, _UVs.w));
			float4 shard = lerp(_ShardCol1, _ShardCol2, sin(IN.worldPos.y));
			
			//float3 warpPos = IN.screenPos.xyz;// + (float3(holoLines - 0.5, holoLines - 0.5, holoLines - 0.5) * 0.02);   // + (UNITY_PROJ_COORD(IN.proj));
			
			//half4 background = tex2Dproj( _GrabTexture, IN.screenPos);
			
			
			half rim = 1.0 - saturate(dot (normalize(IN.viewDir), o.Normal));
			float3 outcolor = ((c.rgb * pow (rim, _Specularity) + (_Color.rgb * _Color.a * holoLines)) * shard) + (_Color.rgb * _Color.a * 0.15);
			
          	o.Emission = outcolor.rgb;
			o.Alpha = 1.0;// * background.a;
		}
		ENDCG
	} 


	FallBack "Diffuse"
}
