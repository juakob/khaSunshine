#version 450

precision mediump float;

uniform sampler2D tex;
in vec3 norm;
in vec2 texCoord;
in vec3 eyeVec;

out vec4 color;


void kore() {
	vec4 texNormal = texture(tex, texCoord.xy);
	vec3 normal=norm+(texNormal.xyz*4.-vec3(0.5));
	normal=normalize(normal);
	vec3 lightDir = vec3(-0.2, 0.5,-0.3);
	
  	vec3 eyeVecNormal = normalize(eyeVec);
 
  	vec3 reflectVec = normalize(-reflect(lightDir, normal));
 
  	vec3 ambient = vec3(0.0,0.7,0.6);
 
  	vec3 diffuse = vec3(0.2,0.85,0.95)*vec3(dot(normal, lightDir)) * vec3(1.0, 1.0, 1.0) ;
 
 
	//vec3 specularReflection;
	
		//specularReflection = vec3(1.0) * pow(max(0.0, dot( reflectVec,eyeVecNormal)),500);
		//	specularReflection = vec3(1.0) * pow(max(dot(reflectVec, eyeVecNormal), 0.0), 1000);
     // specularReflection = vec3(0.5) * vec3(1.) * vec3(1.)* pow(max(0.0, dot(reflect(-lightDir, normal), eyeVecNormal)),5);
   
  	//vec4 specular = vec4(1.0) * pow(max(0.0, dot( reflectVec,eyeVecNormal)),1000);
 
  	 
	color = vec4(ambient + diffuse ,0.95);
 
 
	//color = vec4(0.4,0.5,0.8,0.5)*vec4(dot(normal, lightdir) * vec3(1.0, 1.0, 1.0),1.0);
}
