#version 450

precision mediump float;

uniform sampler2D tex;
uniform sampler2D blur;
in vec2 texCoord;
in float focus;
out vec4 color;


void kore() {
	vec4 texcolor = texture(tex, texCoord.xy);
	vec4 blur=texture(blur, texCoord.xy);
	//vec4 resulColor
	color = texcolor;
}
