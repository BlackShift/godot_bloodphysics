#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_y = 1) in;

layout(set = 0, binding = 0, r16) uniform image2D blood_map;


void main() {
    vec4 blood = imageLoad(blood_map,ivec2(gl_GlobalInvocationID.xy));
    //1% reduction
    blood = blood * 0.99;
    imageStore(blood_map,ivec2(gl_GlobalInvocationID.xy),blood);
}
