Shader "Masked/Mask" {
	SubShader {
		// This sets the render queue index to 2000 plus one, which makes it render the shader before opaque geometry, but before transparent geometry.
		Tags {"Queue" = "Geometry+1" }
		// Don't draw in the RGBA channels; just the depth buffer
		ColorMask 0
		ZWrite On
		Pass {}
	}
}