#version 450

in vec3 pos;
in vec2 uv;


uniform mat4 mvp;

out vec2 texCoord;

void kore() {
    texCoord=uv;
	gl_Position = mvp * vec4(pos, 1.0);
	
}
