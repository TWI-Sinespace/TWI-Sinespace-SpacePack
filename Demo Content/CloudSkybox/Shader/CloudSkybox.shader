// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Originally based in Keijiro Takahashi's Volumetric Cloud Shader
// Available here: https://github.com/keijiro/CloudSkybox
// Modified by Adam Frisby of Sine Wave Entertainment to work in a non-volumetric manner.
// and tweaked for both dramatic effect, and compatibility with sinewave.space Day/Night components

Shader "Skybox/2D Cloud Skybox"
{
    Properties
    {
		[NoScaleOffset] _Tex("Stars Cubemap (HDR)", Cube) = "grey" {}

        [Space]
        _NoiseTex1("Noise Volume", 2D) = ""{}
        _NoiseTex2("Noise Volume", 2D) = ""{}
        _NoiseFreq1("Frequency 1", Float) = 3.1
        _NoiseFreq2("Frequency 2", Float) = 35.1
        _NoiseAmp1("Amplitude 1", Float) = 5
        _NoiseAmp2("Amplitude 2", Float) = 1
        _NoiseBias("Bias", Float) = -0.2

        [Space]
        _Scroll1("Scroll Speed 1", Vector) = (0.01, 0.08, 0.06, 0)
        _Scroll2("Scroll Speed 2", Vector) = (0.01, 0.05, 0.03, 0)

        [Space]
        _Altitude0("Altitude (bottom)", Float) = 1500
        _Altitude1("Altitude (top)", Float) = 3500
        _FarDist("Far Distance", Float) = 30000

        [Space]
        _Scatter("Scattering Coeff", Range(0, 0.1)) = 0.008
        _HGCoeff("Henyey-Greenstein", Range(0,1)) = 0.5
        _Extinct("Extinction Coeff", Float) = 0.01

        [Space]
        _SunSize ("Sun Size", Range(0,1)) = 0.04
        _AtmosphereThickness ("Atmoshpere Thickness", Range(0,5)) = 1.0
        _SkyTint ("Sky Tint", Color) = (.5, .5, .5, 1)
        _GroundColor ("Ground", Color) = (.369, .349, .341, 1)
        _Exposure("Exposure", Range(0, 8)) = 1.3
    }

    CGINCLUDE

    struct appdata_t
    {
        float4 vertex : POSITION;
    };

    struct v2f
    {
        float4 vertex : SV_POSITION;
        float2 uv : TEXCOORD0;
        float3 rayDir : TEXCOORD1;
        float3 groundColor : TEXCOORD2;
        float3 skyColor : TEXCOORD3;
        float3 sunColor : TEXCOORD4;
		float3 origVert : TEXCOORD5;
    };

#include "UnityCG.cginc"
#include "Lighting.cginc"

half _Exposure;
half3 _GroundColor;
half _SunSize;
half3 _SkyTint;
half _AtmosphereThickness;

#define GAMMA 2.2
#define COLOR_2_GAMMA(color) ((unity_ColorSpaceDouble.r>2.0) ? pow(color,1.0/GAMMA) : color)
#define COLOR_2_LINEAR(color) color
#define LINEAR_2_LINEAR(color) color

// RGB wavelengths
// .35 (.62=158), .43 (.68=174), .525 (.75=190)
static const float3 kDefaultScatteringWavelength = float3(.65, .57, .475);
static const float3 kVariableRangeForScatteringWavelength = float3(.15, .15, .15);

#define OUTER_RADIUS 1.025
static const float kOuterRadius = OUTER_RADIUS;
static const float kOuterRadius2 = OUTER_RADIUS*OUTER_RADIUS;
static const float kInnerRadius = 1.0;
static const float kInnerRadius2 = 1.0;

static const float kCameraHeight = 0.0001;

#define kRAYLEIGH (lerp(0, 0.0025, pow(_AtmosphereThickness,2.5)))		// Rayleigh constant
#define kMIE 0.0010      		// Mie constant
#define kSUN_BRIGHTNESS 20.0 	// Sun brightness

#define kMAX_SCATTER 50.0 // Maximum scattering value, to prevent math overflows on Adrenos

static const half kSunScale = 400.0 * kSUN_BRIGHTNESS;
static const float kKmESun = kMIE * kSUN_BRIGHTNESS;
static const float kKm4PI = kMIE * 4.0 * 3.14159265;
static const float kScale = 1.0 / (OUTER_RADIUS - 1.0);
static const float kScaleDepth = 0.25;
static const float kScaleOverScaleDepth = (1.0 / (OUTER_RADIUS - 1.0)) / 0.25;
static const float kSamples = 2.0; // THIS IS UNROLLED MANUALLY, DON'T TOUCH

#define MIE_G (-0.990)
#define MIE_G2 0.9801

#define SKY_GROUND_THRESHOLD 0.02

// Calculates the Rayleigh phase function
half getRayleighPhase(half eyeCos2)
{
    return 0.75 + 0.75*eyeCos2;
}
half getRayleighPhase(half3 light, half3 ray)
{
    half eyeCos	= dot(light, ray);
    return getRayleighPhase(eyeCos * eyeCos);
}

float scale(float inCos)
{
    float x = 1.0 - inCos;
    return 0.25 * exp(-0.00287 + x*(0.459 + x*(3.83 + x*(-6.80 + x*5.25))));
}

void vert_sky(float3 vertex, inout v2f OUT)
{
    float3 kSkyTintInGammaSpace = COLOR_2_GAMMA(_SkyTint); // convert tint from Linear back to Gamma
    float3 kScatteringWavelength = lerp (
        kDefaultScatteringWavelength-kVariableRangeForScatteringWavelength,
        kDefaultScatteringWavelength+kVariableRangeForScatteringWavelength,
        half3(1,1,1) - kSkyTintInGammaSpace); // using Tint in sRGB gamma allows for more visually linear interpolation and to keep (.5) at (128, gray in sRGB) point
    float3 kInvWavelength = 1.0 / pow(kScatteringWavelength, 4);

    float kKrESun = kRAYLEIGH * kSUN_BRIGHTNESS;
    float kKr4PI = kRAYLEIGH * 4.0 * 3.14159265;

    float3 cameraPos = float3(0,kInnerRadius + kCameraHeight,0); 	// The camera's current position

    // Get the ray from the camera to the vertex and its length (which is the far point of the ray passing through the atmosphere)
    float3 eyeRay = normalize(mul((float3x3)unity_ObjectToWorld, vertex));
					//normalize(mul((float3x3)_Object2World, IN.vertex));
    float far = 0.0;
    half3 cIn, cOut;

    if(eyeRay.y >= 0.0)
    {
        // Sky
        // Calculate the length of the "atmosphere"
        far = sqrt(kOuterRadius2 + kInnerRadius2 * eyeRay.y * eyeRay.y - kInnerRadius2) - kInnerRadius * eyeRay.y;

        float3 pos = cameraPos + far * eyeRay;

        // Calculate the ray's starting position, then calculate its scattering offset
        float height = kInnerRadius + kCameraHeight;
        float depth = exp(kScaleOverScaleDepth * (-kCameraHeight));
        float startAngle = dot(eyeRay, cameraPos) / height;
        float startOffset = depth*scale(startAngle);


        // Initialize the scattering loop variables
        float sampleLength = far / kSamples;
        float scaledLength = sampleLength * kScale;
        float3 sampleRay = eyeRay * sampleLength;
        float3 samplePoint = cameraPos + sampleRay * 0.5;

        // Now loop through the sample rays
        float3 frontColor = float3(0.0, 0.0, 0.0);
        // Weird workaround: WP8 and desktop FL_9_1 do not like the for loop here
        // (but an almost identical loop is perfectly fine in the ground calculations below)
        // Just unrolling this manually seems to make everything fine again.
//				for(int i=0; i<int(kSamples); i++)
        {
            float height = length(samplePoint);
            float depth = exp(kScaleOverScaleDepth * (kInnerRadius - height));
            float lightAngle = dot(_WorldSpaceLightPos0.xyz, samplePoint) / height;
            float cameraAngle = dot(eyeRay, samplePoint) / height;
            float scatter = (startOffset + depth*(scale(lightAngle) - scale(cameraAngle)));
            float3 attenuate = exp(-clamp(scatter, 0.0, kMAX_SCATTER) * (kInvWavelength * kKr4PI + kKm4PI));

            frontColor += attenuate * (depth * scaledLength);
            samplePoint += sampleRay;
        }
        {
            float height = length(samplePoint);
            float depth = exp(kScaleOverScaleDepth * (kInnerRadius - height));
            float lightAngle = dot(_WorldSpaceLightPos0.xyz, samplePoint) / height;
            float cameraAngle = dot(eyeRay, samplePoint) / height;
            float scatter = (startOffset + depth*(scale(lightAngle) - scale(cameraAngle)));
            float3 attenuate = exp(-clamp(scatter, 0.0, kMAX_SCATTER) * (kInvWavelength * kKr4PI + kKm4PI));

            frontColor += attenuate * (depth * scaledLength);
            samplePoint += sampleRay;
        }



        // Finally, scale the Mie and Rayleigh colors and set up the varying variables for the pixel shader
        cIn = frontColor * (kInvWavelength * kKrESun);
        cOut = frontColor * kKmESun;
    }
    else
    {
        // Ground
        far = (-kCameraHeight) / (min(-0.001, eyeRay.y));

        float3 pos = cameraPos + far * eyeRay;

        // Calculate the ray's starting position, then calculate its scattering offset
        float depth = exp((-kCameraHeight) * (1.0/kScaleDepth));
        float cameraAngle = dot(-eyeRay, pos);
        float lightAngle = dot(_WorldSpaceLightPos0.xyz, pos);
        float cameraScale = scale(cameraAngle);
        float lightScale = scale(lightAngle);
        float cameraOffset = depth*cameraScale;
        float temp = (lightScale + cameraScale);

        // Initialize the scattering loop variables
        float sampleLength = far / kSamples;
        float scaledLength = sampleLength * kScale;
        float3 sampleRay = eyeRay * sampleLength;
        float3 samplePoint = cameraPos + sampleRay * 0.5;

        // Now loop through the sample rays
        float3 frontColor = float3(0.0, 0.0, 0.0);
        float3 attenuate;
//				for(int i=0; i<int(kSamples); i++) // Loop removed because we kept hitting SM2.0 temp variable limits. Doesn't affect the image too much.
        {
            float height = length(samplePoint);
            float depth = exp(kScaleOverScaleDepth * (kInnerRadius - height));
            float scatter = depth*temp - cameraOffset;
            attenuate = exp(-clamp(scatter, 0.0, kMAX_SCATTER) * (kInvWavelength * kKr4PI + kKm4PI));
            frontColor += attenuate * (depth * scaledLength);
            samplePoint += sampleRay;
        }

        cIn = frontColor * (kInvWavelength * kKrESun + kKmESun);
        cOut = clamp(attenuate, 0.0, 1.0);
    }

    OUT.rayDir = half3(-eyeRay);
	
    // if we want to calculate color in vprog:
    // 1. in case of linear: multiply by _Exposure in here (even in case of lerp it will be common multiplier, so we can skip mul in fshader)
    // 2. in case of gamma and SKYBOX_COLOR_IN_TARGET_COLOR_SPACE: do sqrt right away instead of doing that in fshader

    OUT.groundColor	= _Exposure * (cIn + COLOR_2_LINEAR(_GroundColor) * cOut);
    OUT.skyColor	= _Exposure * (cIn * getRayleighPhase(_WorldSpaceLightPos0.xyz, -eyeRay));
    OUT.sunColor	= _Exposure * (cOut * _LightColor0.xyz);
}

		half calcSunSpot(half3 vec1, half3 vec2)
		{
			half3 delta = vec1 - vec2;
			half dist = length(delta);
			half spot = 1.0 - smoothstep(0.0, _SunSize, dist);
			return kSunScale * spot * spot;
		}

		// Calculates the Mie phase function
		half getMiePhase(half eyeCos, half eyeCos2)
		{
			half temp = 1.0 + MIE_G2 - 2.0 * MIE_G * eyeCos;
			temp = pow(temp, pow(_SunSize, 0.65) * 10);
			temp = max(temp, 1.0e-4); // prevent division by zero, esp. in half precision
			temp = 1.5 * ((1.0 - MIE_G2) / (2.0 + MIE_G2)) * (1.0 + eyeCos2) / temp;
#if defined(UNITY_COLORSPACE_GAMMA) && SKYBOX_COLOR_IN_TARGET_COLOR_SPACE
			temp = pow(temp, .454545);
#endif
			return temp;
		}


half4 frag_sky(v2f IN)
{
    half3 col = half3(0.0, 0.0, 0.0);

// if y > 1 [eyeRay.y < -SKY_GROUND_THRESHOLD] - ground
// if y >= 0 and < 1 [eyeRay.y <= 0 and > -SKY_GROUND_THRESHOLD] - horizon
// if y < 0 [eyeRay.y > 0] - sky
    //half3 ray = IN.rayDir.xyz;
    //half y = ray.y / SKY_GROUND_THRESHOLD;

	half3 ray = normalize(mul((float3x3)unity_ObjectToWorld, -IN.origVert.xyz));
	half y = ray.y / SKY_GROUND_THRESHOLD;

    // if we did precalculate color in vprog: just do lerp between them
    col = lerp(IN.skyColor, IN.groundColor, saturate(y));

	//half mie = 0;

	half eyeCos = dot(_WorldSpaceLightPos0.xyz, ray);
	half eyeCos2 = eyeCos * eyeCos;
	half mie = getMiePhase(eyeCos, eyeCos2);

    if(y < 0.0)
    {
		mie *= 1;
        //mie += calcSunSpot(_WorldSpaceLightPos0.xyz, -ray);

        col += (mie)* IN.sunColor * 1;
    }

	

    return half4(col,mie);
}


    v2f vert(appdata_t v)
    {
        float4 p = UnityObjectToClipPos(v.vertex);

        v2f o;

		o.origVert = v.vertex;
        o.vertex = p;
        o.uv = (p.xy / p.w + 1) * 0.5;

        vert_sky(v.vertex.xyz, o);

        return o;
    }

    float _SampleCount0;
    float _SampleCount1;
    int _SampleCountL;

	samplerCUBE _Tex;
	half4 _Tex_HDR;
	float _Rotation;

    sampler2D _NoiseTex1;
    sampler2D _NoiseTex2;
    float _NoiseFreq1;
    float _NoiseFreq2;
    float _NoiseAmp1;
    float _NoiseAmp2;
    float _NoiseBias;

    float3 _Scroll1;
    float3 _Scroll2;

    float _Altitude0;
    float _Altitude1;
    float _FarDist;

    float _Scatter;
    float _HGCoeff;
    float _Extinct;

    float UVRandom(float2 uv)
    {
        float f = dot(float2(12.9898, 78.233), uv);
        return frac(43758.5453 * sin(f));
    }

    float SampleNoise(float3 uvw)
    {
        const float baseFreq = 1e-5;

        float4 uvw1 = float4(uvw * _NoiseFreq1 * baseFreq, 0);
        float4 uvw2 = float4(uvw * _NoiseFreq2 * baseFreq, 0);

        uvw1.xyz += _Scroll1.xyz * _Time.x;
        uvw2.xyz += _Scroll2.xyz * _Time.x;

        float n1 = tex2D(_NoiseTex1, uvw1.xz).r;
        float n2 = tex2D(_NoiseTex2, uvw2.xz).r;
        float n = n1 * _NoiseAmp1 + n2 * _NoiseAmp2;

        n = saturate(n + _NoiseBias);

		return n;

        float y = uvw.y - _Altitude0;
        float h = _Altitude1 - _Altitude0;
        n *= smoothstep(0, h * 0.1, y);
        n *= smoothstep(0, h * 0.4, h - y);

        return n;
    }

    float HenyeyGreenstein(float cosine)
    {
        float g2 = _HGCoeff * _HGCoeff;
        return 0.5 * (1 - g2) / pow(1 + g2 - 2 * _HGCoeff * cosine, 1.5);
    }

    float Beer(float depth)
    {
        return exp(-_Extinct * depth);
    }

    float BeerPowder(float depth)
    {
        return exp(-_Extinct * depth) * (1 - exp(-_Extinct * 2 * depth));
    }

    float MarchLight(float3 pos, float rand)
    {
        float3 light = _WorldSpaceLightPos0.xyz;
        float stride = (_Altitude1 - pos.y) / (light.y * _SampleCountL);

        pos += light * stride * rand;

        float depth = 0;
        UNITY_LOOP for (int s = 0; s < _SampleCountL; s++)
        {
            //depth += SampleNoise(pos) * stride;
            pos += light * stride;
        }

        return BeerPowder(depth);
    }

    fixed4 frag(v2f i) : SV_Target
    {
        float4 sky = frag_sky(i);

        float3 ray = -i.rayDir;
        int samples = lerp(_SampleCount1, _SampleCount0, ray.y);

        float dist0 = _Altitude0 / ray.y;
        float dist1 = _Altitude1 / ray.y;
        float stride = (dist1 - dist0) / samples;

		half4 tex = texCUBE(_Tex, -i.rayDir);
		half3 c = DecodeHDR(tex, _Tex_HDR);
		float norm = saturate(dot(_WorldSpaceLightPos0.xyz, float3(0, 1, 0)) + 0.95);
		float norm2 = saturate(norm - 0.5);

		if (ray.y < 0.01 || dist0 >= _FarDist) {
			return max(fixed4(c.rgb,1)*(1-norm2),fixed4(sky.rgb, 1));
		}

        float3 light = _WorldSpaceLightPos0.xyz;
        float hg = HenyeyGreenstein(dot(ray, light));

        float2 uv = i.uv + _Time.x;

        float3 pos = _WorldSpaceCameraPos + ray * (dist0);
        float3 acc = 0;

        float depth = 0;
		
		float n = SampleNoise(pos);
		
		float density = n * 1;											// float3(0,1,0) was ray.xyz
		float scatter = density * _Scatter * hg * 3000;// *MarchLight(pos, 0);
		depth += density * 2;
		acc += _LightColor0 * scatter * max(BeerPowder(depth),0.005);
		
        acc += Beer(depth) * sky;

        acc = lerp(acc, sky, saturate(dist0 / _FarDist));

		acc = max(c.rgb*(1-norm2),acc);

        return half4(acc, 1);
    }

    ENDCG

    SubShader
    {
        Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
        Cull Off ZWrite Off
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            ENDCG
        }
    }
}
