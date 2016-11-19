// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Grass" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_DisplacementSpeed("Grass Wave speed", Range(0.0,10.0)) = 1.0
		_DisplacementAmount("Grass Wave amount", Range(0.0,0.5)) = 0.1
		_WaveThreshold("Wave Threshold", Range(0.0,1.0)) = 0.0
	}
		SubShader{
		Tags{ "RenderType" = "Opaque" }

		LOD 200
		Cull Off

		Pass
	{
		Tags{ "LightMode" = "ForwardBase" }
		CGPROGRAM
#pragma vertex VertexProgram addshadow
#pragma fragment FragmentProgram
#include "UnityCG.cginc"

		// shadow stuff:
#pragma multi_compile_fwdbase
#include "Lighting.cginc"
#include "AutoLight.cginc"


		struct v2f {
		float4 pos : SV_POSITION;
		LIGHTING_COORDS(1, 2)
			//SHADOW_COORDS(3)
			fixed3 diff : COLOR0;
		fixed3 ambient : COLOR1;

	};

	float _DisplacementSpeed;
	float _DisplacementAmount;
	float _WaveThreshold;

	v2f VertexProgram(appdata_full v)
	{
		v2f o;

		// find the world coords of the vertex
		float3 u = mul(unity_ObjectToWorld, v.vertex);

		// transformation
		//u.y = 0.5*u.y;
		float wave = max(0, sign(v.vertex.y - _WaveThreshold));
		u.xy += (sin(_Time.y * _DisplacementSpeed + u.z) * _DisplacementAmount) * wave;
		// convert to view coordinates, store the position
		v.vertex.xyz = u;
		o.pos = mul(UNITY_MATRIX_VP, v.vertex);

		// lighting:
		half3 worldNormal = UnityObjectToWorldNormal(v.normal);
		// take dot product between normal and light direction for standard 
		// diffuse (Lambert) lighting
		half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
		// factor in light color:
		o.diff = nl*_LightColor0.rgb;
		// add ambient lighting:
		o.ambient = ShadeSH9(half4(worldNormal, 1.0));

		TRANSFER_VERTEX_TO_FRAGMENT(o);


		return o;
	}

	fixed4 _Color;

	fixed4 FragmentProgram(v2f i) : SV_Target
	{

		float atten = LIGHT_ATTENUATION(i);

	// Return the relevant color and texture
	fixed4 u = _Color;

	// darken light's illumination with shadow, keep ambient intact
	fixed3 lighting = i.diff*atten + i.ambient;
	u.rgb *= lighting;
	return u;

	}
		ENDCG

	}

		// Shadowcaster pass modified to use same vertex transformation as original shader
		Pass
	{
		Tags{ "LightMode" = "ShadowCaster" }

		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#pragma multi_compile_shadowcaster
#include "UnityCG.cginc"

		struct v2f {
		V2F_SHADOW_CASTER;
	};

	float _DisplacementSpeed;
	float _DisplacementAmount;
	float _WaveThreshold;

	v2f vert(appdata_full v)
	{
		v2f o;
		TRANSFER_SHADOW_CASTER(o) // this has to be BEFORE the transformation!!!

								  //// find the world coords of the vertex
			float4 u = mul(unity_ObjectToWorld, v.vertex);

			////// transformation, use same as above
			float wave = max(0, sign(v.vertex.y - _WaveThreshold));
			u.xy += (sin(_Time.y * _DisplacementSpeed + u.z) * _DisplacementAmount) * wave;

			//// convert to view coordinates, store the position
			v.vertex.xyz = u;
			o.pos = mul(UNITY_MATRIX_VP, v.vertex);

			return o;
	}

	float4 frag(v2f i) : SV_Target
	{
		SHADOW_CASTER_FRAGMENT(i)
	}
		ENDCG
	}


	}
		//FallBack "Diffuse"
}