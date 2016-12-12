// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/WavyMaterial" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_DisplacementSpeed("Grass Wave speed", Range(0.0,10.0)) = 1.0
		_DisplacementAmount("Grass Wave amount", Range(0.0,0.5)) = 0.1
		_WaveThreshold("Wave Threshold", Range(-1.0,1.0)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow
		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		float _DisplacementSpeed;
		float _DisplacementAmount;
		float _WaveThreshold;
		fixed4 _Color;


		void vert(inout appdata_full v)
		{
			float4 worldDisplacePos = mul(unity_ObjectToWorld, v.vertex); //Need to be in world time before we modify the vertex values.
			worldDisplacePos.xy += sin(_Time.y * _DisplacementSpeed + worldDisplacePos.z) * _DisplacementAmount; //Displace by adding a sin- and position based value.
			v.vertex = mul(unity_WorldToObject, worldDisplacePos); //Go back to object space, so Unity can perform the rest of the built in vertex functions.
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
