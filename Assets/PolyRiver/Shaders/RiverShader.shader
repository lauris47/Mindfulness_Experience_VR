Shader "Custom/RiverShader"
{
	Properties
	{
	_MainColor("Main Color", Color) = (0.5,0.5,0.5,1.0) //Main color of the river
	_NormalMap("Normal Map one", 2D) = "white" {} //Normal map used for distortion
	_WaterSpeed("Water Speed", Range(0.01,0.5)) = 0.1 //Speed of the river water moving
	_WaterDirection("Water direction(x,y)", Vector) = (1.0,1.0,1.0,1.0) //Direction of the river movement
	_FoamColor("Foam Color", Color) = (1.0,1.0,1.0,1.0) //Color of the intersection foam
	_FoamAmount("Foam amount", Range(0.0,10.0)) = 1.0 //Amount of foam generated
	_FoamDistortionSpeed("Foam Speed", Range(0.002,0.04)) = 0.02 //Speed of the foam distortion
	_Noise("Noise texture", 2D) = "white" {} //Noise for controlling foam animation
	_ReflectionAmount("Reflection Amount", Range(0.0,1.0)) = 0.5 //Slider controlling how much of the reflection we see
	[HideInInspector]_ReflectionTex("Internal reflection", 2D) = "white" {} //Render texture from the reflection camera

	}
		SubShader
	{

		Pass
	{
		CGPROGRAM //Start the CG
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"

	struct v2f
	{
		float4 pos : SV_POSITION;
		float2 uv : TEXCOORD0;
		float4 screenPos : TEXCOORD1;
		float2 normal1 : TEXCOORD2;
		float2 noise : TEXCOORD7;
		float3 texCoord : TEXCOORD9;
		UNITY_FOG_COORDS(1)
	};

	float4 _NormalMap_ST, _Noise_ST;
	sampler2D _ReflectionTex;

	v2f vert(appdata_tan v)
	{
		v2f o;
		o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		o.screenPos = ComputeScreenPos(o.pos);
		o.texCoord = v.texcoord;
		o.normal1 = TRANSFORM_TEX(v.texcoord, _NormalMap);
		o.noise = TRANSFORM_TEX(v.texcoord, _Noise);

		return o;
	}


	//Initialize variables
	half4 _MainColor;
	half4 _FoamColor;
	half _FoamAmount;
	sampler2D _CameraDepthTexture;
	sampler2D _NormalMap;
	sampler2D _Noise;
	half _ReflectionAmount;
	half _FoamDistortionSpeed;
	half _WaterSpeed;
	half _EdgeBlend;
	half4 _WaterDirection;

	fixed4 frag(v2f i) : SV_Target
	{
	//Creating an offset for the foam based on a noise texture. The noise texture is moved by uing the _Time.y component,
	//which will create different animations of the foam based on which noise texture is used.
	float foamOffset = tex2D(_Noise, float2(i.noise + (_Time.y * _FoamDistortionSpeed))).r;

	//Initialize normal map which will be used for distortion effects.
	//Like the foam animation, this is moved by using the time component, and we multiply it with a 2D vector to control the direction of the river.
	fixed3 normal = UnpackNormal(tex2D(_NormalMap, i.normal1 + normalize(_WaterDirection.xy) * (_Time.y * _WaterSpeed * 0.5f)));
	fixed4 finalColor = 1.0; //Initialize the color of the fragment
	half4 screenWithOffset = i.screenPos + half4(normal,1.0); //Get the position with offset to create a distortion.
	half4 rtReflections = tex2Dproj(_ReflectionTex, UNITY_PROJ_COORD(screenWithOffset)); //Grab the reflection color from the reflection texture with the distortion offset.
	finalColor.rgb = lerp(_MainColor.rgb, rtReflections.rgb, _ReflectionAmount); //Lerp between the water color and the reflection color controlled by the variable "_ReflectionAmount".
	
	//Foam
	float depth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD(i.screenPos)).r); //Grab the depth from the camera depth texture.
	float diff = (abs(depth - i.screenPos.z)) / _FoamAmount; //Calculate the difference between the fragment of the plane and fragment behind it.

	if (diff <= 1.0f + foamOffset) { //If the different is smaller or equal to 1 and the foam animation value, we draw the foam.
		finalColor = _FoamColor; //Set color of fragment to be the foam color.
	}
	return finalColor; //Return the color of the fragment
	}
		ENDCG
	}
	}
}