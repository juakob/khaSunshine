let fs = require('fs');
let path = require('path');
let project = new Project('BulletTest', __dirname);
project.targetOptions = {"html5":{},"flash":{},"android":{},"ios":{}};
project.setDebugDir('build/windows');
Promise.all([Project.createProject('build/windows-build', __dirname), Project.createProject('D:/kha/MeshLoader/kha', __dirname), Project.createProject('D:/kha/MeshLoader/kha/Kore', __dirname)]).then((projects) => {
	for (let p of projects) project.addSubProject(p);
	let libs = [];
	if (fs.existsSync(path.join('Libraries/Bullet', 'korefile.js'))) {
		libs.push(Project.createProject('Libraries/Bullet', __dirname));
	}
	Promise.all(libs).then((libprojects) => {
		for (let p of libprojects) project.addSubProject(p);
		resolve(project);
	});
});
