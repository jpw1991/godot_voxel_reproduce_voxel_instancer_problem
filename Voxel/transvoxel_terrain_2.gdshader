shader_type spatial;

#include "res://addons/zylann.voxel/shaders/transvoxel.gdshaderinc"
#include "res://addons/zylann.voxel/shaders/virtual_texturing.gdshaderinc"
#include "res://addons/zylann.voxel/shaders/triplanar.gdshaderinc"
#include "res://addons/zylann.voxel/shaders/lod_fade.gdshaderinc"

uniform sampler2D u_texture_top : source_color;
uniform sampler2D u_texture_sides : source_color;
uniform sampler2D u_texture_bottom : source_color;

varying vec3 v_world_pos;
varying vec3 v_vertex_pos_model;


void vertex() {
    VERTEX = get_transvoxel_position(VERTEX, CUSTOM0);
    v_vertex_pos_model = VERTEX;

    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // float nm_factor = clamp(0.5 + 0.5 * (4.0 * sin(TIME * 2.0)), 0.0, 1.0);
    // NORMAL = mix(NORMAL, get_voxel_normal_view(NORMAL, VIEW_MATRIX * MODEL_MATRIX), nm_factor);
    NORMAL = get_voxel_normal_view(v_vertex_pos_model, NORMAL, VIEW_MATRIX * MODEL_MATRIX);

    vec3 normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
    vec3 wpos = v_world_pos * 0.2;

    float topness_midlevel = 0.5;
    float topness_smoothness = 0.04;
    float topness_min = topness_midlevel - topness_smoothness;
    float topness_max = topness_midlevel + topness_smoothness;
    float topness = smoothstep(topness_min, topness_max, normal.y);
	
	float bottomness_midlevel = 0.25; // Assuming your normals are normalized
	float bottomness_smoothness = 0.04; // Adjust as needed
	float bottomness_min = bottomness_midlevel - bottomness_smoothness;
	float bottomness_max = bottomness_midlevel + bottomness_smoothness;
	float bottomness = smoothstep(bottomness_min, bottomness_max, -normal.y); // Inverted normal.y

    float triplanar_sharpness = 20.0;
    vec3 blending = get_triplanar_blend(normal, triplanar_sharpness);
    vec3 top_col = texture_triplanar(u_texture_top, wpos, blending).rgb;
    vec3 side_col = texture_triplanar(u_texture_sides, wpos, blending).rgb;
	vec3 bottom_col = texture_triplanar(u_texture_bottom, wpos, blending).rgb;

	vec3 blended_top = mix(side_col, top_col, topness);
	vec3 blended_top_mid = mix(top_col, side_col, topness);
	vec3 blended_bottom = mix(side_col, bottom_col, bottomness);
	
	float middleness = 1.0 - max(topness, bottomness);
	vec3 blended_mid = mix(bottom_col, top_col, middleness);
	ALBEDO = mix(mix(blended_top, blended_top_mid, bottomness), blended_bottom, bottomness);

    // Discard has to be last to workaround https://github.com/godotengine/godot/issues/34966
    if (get_lod_fade_discard(SCREEN_UV)) {
        discard;
    }
}
