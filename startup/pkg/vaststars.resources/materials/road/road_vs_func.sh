#include "common/transform.sh"
#include "common/common.sh"
#include "road.sh"

vec4 CUSTOM_VS_POSITION(VSInput vsinput, inout Varyings varyings, mat4 worldmat)
{
	return transform_road(vsinput, varyings);
}

void CUSTOM_VS(mat4 worldmat, in VSInput vsinput, inout Varyings varyings)
{
	uint color 			= floatBitsToUint(vsinput.data0.z);
	varyings.texcoord0  = vsinput.texcoord0;
	varyings.color0		= vec4(uvec4(color, color>>8, color>>16, color>>24)&0xff) / 255.0;
}