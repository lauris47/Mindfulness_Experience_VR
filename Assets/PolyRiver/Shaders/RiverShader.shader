// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/RiverShader"
{
	Properties
	{
		_MainColor("Main Color", Color) = (0.5,0.5,0.5,1.0)
		_FresnelColor("Fresnel color", Color) = (1.0,1.0,1.0,1.0)
		_Normal1("Normal Map one", 2D) = "white" {}
		_Normal2("Normal Map two", 2D) = "white" {}
		_DistortionDampener("Water Speed Dampener", Range(0.01,1000.0)) = 800
		//_EdgeBlend("Edge Blend", Range(0.0,1.0)) = 0.1
		_FoamColor("Foam Color", Color) = (1.0,1.0,1.0,1.0)
		_FoamAmount("Foam amount", Range(0.0,10.0)) = 1.0
		_FoamDistortionAmount("Foam Distortion", Range(0.0,5.0)) = 1.0
		_FoamDistortionSpeed("Foam Speed", Range(0.002,0.04)) = 0.02
		_Noise("Noise texture", 2D) = "white" {}
		_ReflectionAmount("Reflection Amount", Range(0.0,1.0)) = 0.5
		[HideInInspector]_ReflectionTex("Internal reflection", 2D) = "white" {}
	}
		SubShader
	{
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent" }
		LOD 100

		Pass
	{
		Blend SrcAlpha OneMinusSrcAlpha

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
		// make fog work
#pragma multi_compile_fog

#include "UnityCG.cginc"



	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float4 screenPos : TEXCOORD1;
		float2 normal1 : TEXCOORD2;
		float2 normal2 : TEXCOORD3;
		float3	TtoW0 	 : TEXCOORD4;
		float3	TtoW1	 : TEXCOORD5;
		float3	TtoW2	 : TEXCOORD6;
		float2 noisy : TEXCOORD7;
		float3 worldPos : TEXCOORD8;
		float3 texCoord : TEXCOORD9;
		float3 viewDir  : TEXCOORD10;
		float3 R : TEXCOORD11;
		UNITY_FOG_COORDS(1)
	};

	sampler2D _MainTex;
	float4 _MainTex_ST, _Normal1_ST, _Normal2_ST, _Noise_ST;
	sampler2D _ReflectionTex;

	v2f vert(appdata_tan v)
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
		o.screenPos = ComputeScreenPos(o.pos);
		o.viewDir.xzy = WorldSpaceViewDir(v.vertex);
		o.worldPos = v.vertex;
		o.texCoord = v.texcoord;
		o.normal1 = TRANSFORM_TEX(v.texcoord, _Normal1);
		o.normal2 = TRANSFORM_TEX(v.texcoord, _Normal2);
		o.noisy = TRANSFORM_TEX(v.texcoord, _Noise);

		//UNITY_TRANSFER_FOG(o,o.vertex);
		return o;
	}

	half4 _MainColor;
	half4 _FresnelColor;
	half4 _FoamColor;
	float _FoamAmount;
	sampler2D _CameraDepthTexture;
	sampler2D _Normal1;
	sampler2D _Normal2;
	sampler2D _Noise;
	float _ReflectionAmount;
	float _FoamDistortionAmount;
	float _FoamDistortionSpeed;
	float _DistortionDampener;
	float _DistortionAmount;
	float _EdgeBlend;

	fixed4 frag(v2f i) : SV_Target
	{

	float offset = tex2D(_Noise, float2(i.noisy * _FoamDistortionAmount + (_Time.y * _FoamDistortionSpeed))).r;

	//Distortion
	float phase = _Time[1] / _DistortionDampener * 2;
	float f = frac(phase);
	fixed3 normal = UnpackNormal(tex2D(_Normal1, i.normal1 * frac(phase + 0.5)));
	fixed3 normal2 = UnpackNormal(tex2D(_Normal2, i.normal2 * f));
	fixed3 normalCombine = (normal + normal2) * 0.5;
	if (f > 0.5f)
		f = 2.0f * (1.0f - f);
	else
		f = 2.0f * f;

	fixed4 finalColor = 1.0;
	half4 screenWithOffset = i.screenPos + lerp(float4(normal,0.0), float4(normal2,0.0), f);
	half4 rtReflections = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(screenWithOffset));
	finalColor.rgb = lerp(_MainColor.rgb, rtReflections.rgb, _ReflectionAmount);
	//Foam
	float depth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(i.screenPos)).r);
	float diff = (abs(depth - i.screenPos.z)) / _FoamAmount;
	//float edgeBlendFactor = saturate(_EdgeBlend*(depth - i.screenPos.z));
	//finalColor.a = edgeBlendFactor;

	if (diff <= 1.0f + offset) {
		finalColor = _FoamColor;
	}
	UNITY_APPLY_FOG(i.fogCoord, col);
	return finalColor;
	}
		ENDCG
	}
	}
}
