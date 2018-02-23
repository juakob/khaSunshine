let project = new Project('BulletTest');
project.addAssets('Assets/**');
project.addShaders('Shaders/**');
if (platform === 'html5' || platform === 'krom' || platform === 'node' || platform === 'debug-html5') {
	project.addAssets('Libraries/Bullet/js/ammo/ammo.js');
}
project.addSources('Sources');
project.addLibrary('Bullet');
resolve(project);
