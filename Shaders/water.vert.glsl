#version 450

in vec3 pos;
in vec3 normal;
in vec2 uv;


uniform mat4 mvp;
uniform mat4 mv;
uniform mat4 model;
uniform vec2 offset;
uniform vec2 scale;

out vec3 norm;
out vec2 texCoord;
out vec3 eyeVec;

void kore() {
	norm = (model * vec4(normal, 0.0)).xyz;
    texCoord=uv*scale+offset;
	gl_Position = mvp * vec4(pos, 1.0);
	eyeVec = vec3(mv *vec4(0.0,0.0,0.0,1.0) - model*vec4(pos, 1.0));
	
}
