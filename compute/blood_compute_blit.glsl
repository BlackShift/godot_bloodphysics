#[compute]
#version 450


layout(local_size_x = 1, local_size_y = 1, local_size_y = 1) in;

layout(set = 0, binding = 0, r16) uniform restrict image2D blood_map;
layout(set = 1, binding = 0) uniform sampler2D blit_image;

layout(set = 2, binding = 0, std430) restrict buffer BlitSettings {
    ivec2 src_position;
    ivec2 dst_position;
};

void main() {
    //invocations should be in src_locations of each pixel to transfer
    //The dispatch command controls the size of the blit
    vec4 src_r8 = texture(blit_image,ivec2(gl_WorkGroupID.xy) + src_position);
    imageStore(blood_map,ivec2(gl_WorkGroupID.xy) + dst_position, src_r8);
}
