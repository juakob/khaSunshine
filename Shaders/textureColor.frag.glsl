#version 450

precision mediump float;

uniform sampler2D tex;
in vec2 texCoord;
out vec4 color;


void kore() {
	vec4 texcolor = texture(tex, texCoord.xy);
	color = texcolor;
}
