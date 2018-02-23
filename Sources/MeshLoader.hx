package;

import kha.math.FastVector2;
import haxebullet.Bullet;
import kha.graphics4.CullMode;
import OgexData.BoneNode;
import kha.Framebuffer;
import kha.Color;
import kha.graphics4.CompareMode;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.Assets;
import kha.Shaders;
import kha.input.KeyCode;
import kha.math.FastMatrix4;
import kha.math.FastVector3;
import kha.Scheduler;
import kha.System;
import kha.input.Keyboard;
import kha.input.Gamepad;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.MipMapFilter;
import kha.Image;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.TextureFormat;
import kha.graphics4.BlendingFactor;

class MeshLoader {
	private var pipelineBones: PipelineState;
	private var projectionLocationBones: ConstantLocation;
	private var viewLocationBones: ConstantLocation;
	private var modelLocationBones: ConstantLocation;
	private var bonesLoction: ConstantLocation;
	private var textureLocationBones:TextureUnit;

	private var pipelineDepth: PipelineState;
	private var projectionLocationDepth: ConstantLocation;
	private var viewLocationDepth: ConstantLocation;
	private var modelLocationDepth: ConstantLocation;
	private var bonesLoctionDepth: ConstantLocation;

	private var pipelineStatic: PipelineState;
	private var projectionLocationStatic: ConstantLocation;
	private var viewLocationStatic: ConstantLocation;
	private var modelLocationStatic: ConstantLocation;
	private var textureLocationStatic:TextureUnit;
	private var shadowMapLocation:TextureUnit;
	private var depthBiasLocation:ConstantLocation;

	private var pipelineWater: PipelineState;
	private var projectionLocationWater: ConstantLocation;
	private var modelLocationWater: ConstantLocation;
	private var	offsetLocationWater: ConstantLocation;
	private var scaleLocationWater: ConstantLocation;
	private var textureLocationWater:TextureUnit;
	private var modelViewWater:ConstantLocation;


	private var started: Bool = false;

	var cameraAngle:Float=0;
	
	var mesh:Object3d;

	var skeleton:SkeletonD;
	
	var modelMatrix:FastMatrix4;

	var obj3d:Array<Object3d>;
	var level:Array<Object3d>;
	var water:Array<Object3d>;

	var marioAngle:Float=0;
	var marioMatrixAngle:Float=-Math.PI/2;

	public function new() {
		Assets.loadEverything(start);
	}
	
	var shadowMap:Image;
	var depthMap:Image;
	var finalTarget:Image;
	var blur:Image;
	var dynamicsWorld:BtDiscreteDynamicsWorld;
	var fallRigidBody:BtRigidBody;

	static inline var scale=0.225;
	static inline var scaleCollisions=0.0225;

	private function start(): Void {
		var collisionConfiguration = BtDefaultCollisionConfiguration.create();
		var dispatcher = BtCollisionDispatcher.create(collisionConfiguration);
		var broadphase = BtDbvtBroadphase.create();
		var solver = BtSequentialImpulseConstraintSolver.create();
		dynamicsWorld = BtDiscreteDynamicsWorld.create(dispatcher, broadphase, solver, collisionConfiguration);
		dynamicsWorld.setGravity(BtVector3.create(0,-50,0));

		Keyboard.get().notify(onKeyDown, onKeyUp, onKeyPress);
		kha.input.Gamepad.get(0).notify(onAxis,onButton);
		Scheduler.addTimeTask(update, 0, 1 / 60);
		var data = new OgexData(Assets.blobs.mario_ogex.toString());
		
		var sk = SkeletonLoader.getSkeleton(data);
		obj3d = MeshExtractor.extract(data, sk);
		 data = new OgexData(Assets.blobs.untitled_ogex.toString());
		level=MeshExtractor.extract(data,null);

		var dataWater = new OgexData(Assets.blobs.water_ogex.toString());
		water=MeshExtractor.extract(dataWater,null);

		skeleton = sk[0];
		trace("loaded");

		
		shadowMap=Image.createRenderTarget(256,256,TextureFormat.DEPTH16);
		depthMap=Image.createRenderTarget(800,600,TextureFormat.DEPTH16);
		//depthMap.setDepthStencilFrom
		finalTarget=Image.createRenderTarget(800,600,TextureFormat.RGBA32,DepthStencilFormat.DepthOnly,2);
		//finalTarget.setDepthStencilFrom(depthMap);
		blur=Image.createRenderTarget(Std.int(800/4),Std.int(600/4),TextureFormat.RGBA32,DepthStencilFormat.DepthOnly,2);
		
		var collisionMesh:BtTriangleMesh=BtTriangleMesh.create(true,false);
		
		for(obj in data.geometryObjects){
			var totalTriangles=Std.int(obj.mesh.indexArray.values.length/3);
			var vertexes=obj.mesh.vertexArrays[0].values;
			var indexes=obj.mesh.indexArray.values;
			for(i in 0...totalTriangles)
			{
				var index1=indexes[i*3+0];
				var	index2=indexes[i*3+1];
				var index3=indexes[i*3+2];
				collisionMesh.addTriangle(	BtVector3.create(vertexes[index1*3+0]*scaleCollisions,vertexes[index1*3+1]*scaleCollisions,vertexes[index1*3+2]*scaleCollisions),
											BtVector3.create(vertexes[index2*3+0]*scaleCollisions,vertexes[index2*3+1]*scaleCollisions,vertexes[index2*3+2]*scaleCollisions),
											BtVector3.create(vertexes[index3*3+0]*scaleCollisions,vertexes[index3*3+1]*scaleCollisions,vertexes[index3*3+2]*scaleCollisions),
											true
										);
			}
		}
		
		var groundShape = BtBvhTriangleMeshShape.create(collisionMesh,true,true);
		var groundTransform = BtTransform.create();
		groundTransform.setIdentity();
		groundTransform.setOrigin(BtVector3.create(0, -1, 0));
		var centerOfMassOffsetTransform = BtTransform.create();
		centerOfMassOffsetTransform.setIdentity();
		var groundMotionState = BtDefaultMotionState.create(groundTransform, centerOfMassOffsetTransform);
		

		var groundRigidBodyCI = BtRigidBodyConstructionInfo.create(0, groundMotionState, groundShape, BtVector3.create(0, 0, 0));
		
		var groundRigidBody = BtRigidBody.create(groundRigidBodyCI);
		groundRigidBody.setCollisionFlags(BtCollisionObject.CF_STATIC_OBJECT);
		dynamicsWorld.addRigidBody(groundRigidBody);

		var fallShape = BtCapsuleShape.create(1,1);
		var fallTransform = BtTransform.create();
		fallTransform.setIdentity();
		fallTransform.setOrigin(BtVector3.create(0, 10, 120.0));
		var centerOfMassOffsetFallTransform = BtTransform.create();
		centerOfMassOffsetFallTransform.setIdentity();
		var fallMotionState = BtDefaultMotionState.create(fallTransform, centerOfMassOffsetFallTransform);

		var fallInertia = BtVector3.create(0, 0, 0);
		fallShape.calculateLocalInertia(1, fallInertia);
		var fallRigidBodyCI = BtRigidBodyConstructionInfo.create(1, fallMotionState, fallShape, fallInertia);
	
		fallRigidBody = BtRigidBody.create(fallRigidBodyCI);
		fallRigidBody.setAngularFactor(BtVector3.create(0,1,0));
		dynamicsWorld.addRigidBody(fallRigidBody);

		var structure = new VertexStructure();
		structure.add('pos', VertexData.Float3);
		structure.add('normal', VertexData.Float3);
		structure.add('uv',VertexData.Float2);
		structure.add('weights',VertexData.Float4);
		structure.add('boneIndex',VertexData.Float4);
		pipelineBones = new PipelineState();
		pipelineBones.cullMode=CullMode.Clockwise;
		pipelineBones.inputLayout = [structure];
		pipelineBones.vertexShader = Shaders.meshBones_vert;
		pipelineBones.fragmentShader = Shaders.mesh_frag;
		pipelineBones.depthWrite = true;
		pipelineBones.depthMode = CompareMode.Less;
	
		pipelineBones.compile();
		
		projectionLocationBones = pipelineBones.getConstantLocation("projection");
		viewLocationBones = pipelineBones.getConstantLocation("view");
		modelLocationBones = pipelineBones.getConstantLocation("model");
		bonesLoction=pipelineBones.getConstantLocation("bones");
		textureLocationBones=pipelineBones.getTextureUnit("tex");
		///shadow

		pipelineDepth = new PipelineState();
		pipelineDepth.cullMode=CullMode.Clockwise;
		pipelineDepth.inputLayout = [structure];
		pipelineDepth.vertexShader = Shaders.meshBones_vert;
		pipelineDepth.fragmentShader = Shaders.mesh_frag;
		pipelineDepth.depthWrite = true;
		pipelineDepth.depthMode = CompareMode.Less;

		pipelineDepth.compile();
		
		projectionLocationDepth = pipelineDepth.getConstantLocation("projection");
		viewLocationDepth = pipelineDepth.getConstantLocation("view");
		modelLocationDepth = pipelineDepth.getConstantLocation("model");
		bonesLoctionDepth=pipelineDepth.getConstantLocation("bones");
		
		///end shadow

		structure = new VertexStructure();
		structure.add('pos', VertexData.Float3);
		structure.add('normal', VertexData.Float3);
		structure.add('uv',VertexData.Float2);
		pipelineStatic = new PipelineState();
		pipelineStatic.cullMode=CullMode.Clockwise;
		pipelineStatic.inputLayout = [structure];
		pipelineStatic.vertexShader = Shaders.mesh_vert;
		pipelineStatic.fragmentShader = Shaders.meshShadowMap_frag;
		pipelineStatic.depthWrite = true;
		pipelineStatic.depthMode = CompareMode.Less;
		pipelineStatic.compile();
		
		projectionLocationStatic = pipelineStatic.getConstantLocation("mvp");
		modelLocationStatic = pipelineStatic.getConstantLocation("model");
		textureLocationStatic=pipelineStatic.getTextureUnit("tex");
		shadowMapLocation=pipelineStatic.getTextureUnit("shadowMap");
		depthBiasLocation=pipelineStatic.getConstantLocation("depthBias");


		structure = new VertexStructure();
		structure.add('pos', VertexData.Float3);
		structure.add('normal', VertexData.Float3);
		structure.add('uv',VertexData.Float2);
		pipelineWater = new PipelineState();
		pipelineWater.cullMode=CullMode.Clockwise;
		pipelineWater.inputLayout = [structure];
		pipelineWater.vertexShader = Shaders.water_vert;
		pipelineWater.fragmentShader = Shaders.water_frag;
		pipelineWater.depthWrite = true;
		pipelineWater.depthMode = CompareMode.Less;
		
		pipelineWater.blendSource = BlendingFactor.SourceAlpha;
		pipelineWater.blendDestination = BlendingFactor.InverseSourceAlpha;
		pipelineWater.alphaBlendSource = BlendingFactor.SourceAlpha;
		pipelineWater.alphaBlendDestination = BlendingFactor.InverseSourceAlpha;
	
		pipelineWater.compile();
		
		projectionLocationWater = pipelineWater.getConstantLocation("mvp");
		modelLocationWater = pipelineWater.getConstantLocation("model");
		textureLocationWater=pipelineWater.getTextureUnit("tex");
		offsetLocationWater=pipelineWater.getConstantLocation("offset");
		scaleLocationWater=pipelineWater.getConstantLocation("scale");
		modelViewWater=pipelineWater.getConstantLocation("mv");
		
		modelMatrix = (FastMatrix4.rotationX(-Math.PI / 2)).multmat(FastMatrix4.scale(scale, scale, scale));
		
		started = true;
	}

	private function onAxis(aId:Int,aValue:Float):Void{
			if(aId==0){
				right=false;
				left=false;
				rotateCameraLeft=false;
				rotateCameraRight=false;
				if(aValue>0.5){
					right=true;
					rotateCameraLeft=true;
				}else
				if(aValue<-0.5){
					left=true;
					rotateCameraRight=true;
				}
				
			}
			if(aId==1){
				forward=false;
				backward=false;
				if(aValue>0.5){
					forward=true;
				}else
				if(aValue<-0.5){
					backward=true;
				}
			}
			if(aId==2){
				rotateJustCameraLeft=false;
				rotateJustCameraRight=false;
				if(aValue>0.5){
					rotateJustCameraLeft=true;
				}else
				if(aValue<-0.5){
					rotateJustCameraRight=true;
				}
			}
	}
	private function onButton(aId:Int,aValue:Float):Void{
		jump=(aId==0&&aValue>0);
		
	}

	function update() 
	{
		dynamicsWorld.stepSimulation(1 / 60);
		var trans = BtTransform.create();
		var m = fallRigidBody.getMotionState();
		m.getWorldTransform(trans);
		var pos=trans.getOrigin();
		modelMatrix._30=cast pos.x()*10;
		modelMatrix._31=cast pos.y()*10;
		modelMatrix._32=cast pos.z()*10;
		

		if(rotateCameraLeft||rotateJustCameraLeft)
		{
			cameraAngle-=0.02;
		}
		if(rotateCameraRight||rotateJustCameraRight)
		{
			cameraAngle+=0.02;
		}
		var vel=fallRigidBody.getLinearVelocity();
		var dir=new FastVector2();
		if (left){
			dir.y+=1;
		}
		if (right){
			dir.y-=1;
		}
		if (forward){
			dir.x-=1;
		}
		if (backward){
			dir.x+=1;
		}
		if(jump &&vel.y()<=0)
		{
			
			fallRigidBody.setLinearVelocity(BtVector3.create(vel.x(),30,vel.z()));
		}
		dir.normalize();
		dir=dir.mult(10);
		var controlerAngle:Float=0;
		 if(backward)
		 {
			 controlerAngle=cameraAngle;
		 }else{
			 controlerAngle=marioAngle;
		 }
		 
		var cs=Math.cos(-cameraAngle+Math.PI/2);
		var sn=Math.sin(-cameraAngle+Math.PI/2);
		var px=dir.x*cs-dir.y*sn;
		var py=dir.x*sn+dir.y*cs;
		dir.x=px+vel.x()*0.9;
		dir.y=py+vel.z()*0.9;
		if(dir.length>20)
		{
			dir.normalize();
			dir=dir.mult(20);
		}
		velocityZ=vel.y();
		fallRigidBody.activate(true);

		fallRigidBody.setLinearVelocity(BtVector3.create(dir.x,vel.y(),dir.y));
		
		

			if(left||right||forward||backward){
				var angle=Math.atan2(dir.y,dir.x);
				modelMatrix=modelMatrix.multmat(FastMatrix4.rotationZ(marioAngle-angle));
				marioMatrixAngle+=marioAngle-angle;
				marioAngle=angle;
			}
			
			// if(!left&&!right&&!forward&&!backward)
			// {
			// 	cameraAngle+=(marioMatrixAngle-cameraAngle)/100;
			// }
			
			
		//cameraAngle+=(marioAngle-cameraAngle)/2;
		
		
	}
	var lastAngle:Float=0;
	function onKeyPress(aText:String) 
	{
		
	}
	
	function onKeyUp(aCode:KeyCode) 
	{
		if (aCode == KeyCode.Left)
		{
			left = false;
			rotateCameraRight=false;
		}
		if (aCode == KeyCode.Right)
		{
			right = false;
			rotateCameraLeft=false;
		}
		if (aCode == KeyCode.Up)
		{
			forward = false;
		}
		if (aCode == KeyCode.Down)
		{
			backward = false;
		}
		if(aCode==KeyCode.Space)
		{
			jump=false;
		}
		if(aCode==KeyCode.A)
		{
			rotateJustCameraLeft=false;
		}
		if(aCode==KeyCode.S)
		{
			rotateJustCameraRight=false;
		}
	}
	var left:Bool;
	var right:Bool;
	var forward:Bool;
	var backward:Bool;
	var jump:Bool;
	var rotateCameraLeft:Bool;
	var rotateCameraRight:Bool;
	var rotateJustCameraLeft:Bool;
	var rotateJustCameraRight:Bool;
	
	function onKeyDown(aCode:KeyCode) 
	{
		if (aCode == KeyCode.Left)
		{
			left = true;
			rotateCameraRight=true;
		}
		if (aCode == KeyCode.Right)
		{
			right = true;
			rotateCameraLeft=true;
		}
		if (aCode == KeyCode.Up)
		{
			forward = true;
		}
		if (aCode == KeyCode.Down)
		{
			backward = true;
		}
		if (aCode == KeyCode.Space)
		{
			jump=true;
		}
		if(aCode == KeyCode.A)
		{
			rotateJustCameraLeft=true;
		}
		if(aCode==KeyCode.S)
		{
			rotateJustCameraRight=true;
		}

	}
	var bonesTransformations:haxe.ds.Vector<Float>=new haxe.ds.Vector(32);
	var currentFrame:Int=1;
	var timeElapsed:Float=0;
	var lastTime:Float=0;
	var velocityZ:Float=0;
	public function render(frame: Framebuffer): Void {
		
		
		if (started) {
			var time=Scheduler.realTime();
			timeElapsed+=time-lastTime;
			lastTime=time;
			if(timeElapsed>1/30){
				timeElapsed=0;
				skeleton.setFrame(18+ ++currentFrame%15);
			}

			if(!left&&!right&&!forward&&!backward)
			{
				skeleton.setFrame(43);
			}
			
			
			
			///render shadow
			var cameraMatrix=FastMatrix4.lookAt(new FastVector3(modelMatrix._30-200, modelMatrix._31+400, modelMatrix._32), new FastVector3(modelMatrix._30,modelMatrix._31+25 ,modelMatrix._32 ), new FastVector3(0, 1, 0));
			var projection=FastMatrix4.orthogonalProjection(-30,25,-30,25,-1500,1000);
			var g=shadowMap.g4;
			var clear:Bool=true;
			for(mesh in obj3d){
				g.begin();
				if(clear){
					g.clear(null, Math.POSITIVE_INFINITY);
					clear=false;
				}
				g.setPipeline(pipelineDepth);
				g.setMatrix(projectionLocationDepth, projection);
				g.setMatrix(viewLocationDepth, cameraMatrix);
				g.setMatrix(modelLocationDepth,modelMatrix.multmat(FastMatrix4.rotationZ(cameraAngle+Math.PI/2)).multmat(FastMatrix4.translation(0,0,-25)));
				g.setFloats(bonesLoctionDepth,mesh.skin.getBonesTransformations());
			
				g.setIndexBuffer(mesh.indexBuffer);
				g.setVertexBuffer(mesh.vertexBuffer);
				g.drawIndexedVertices();
			g.end();
			}
			var biasMatrix=FastMatrix4.translation(0.5,0.5,0.5).multmat(FastMatrix4.scale(0.5,0.5,0.5));
			biasMatrix= biasMatrix.multmat(projection).multmat(cameraMatrix);		
			///
			g = finalTarget.g4;
			clear =true;

			var cameraMatrix=FastMatrix4.lookAt(new FastVector3(modelMatrix._30+Math.sin(cameraAngle)*200, modelMatrix._31+100, modelMatrix._32+Math.cos(cameraAngle)*200), new FastVector3(modelMatrix._30,modelMatrix._31+25 ,modelMatrix._32 ), new FastVector3(0, 1, 0));
			var projection=FastMatrix4.perspectiveProjection(45, System.windowWidth(0) / System.windowHeight(0), 0.1, 5000);//FastMatrix4.orthogonalProjection(-25,25,-25,25,-1500,1000);
			
			for(mesh in level){
				g.begin();
				if(clear){
					g.clear(Color.Blue, Math.POSITIVE_INFINITY);
					clear=false;
				}
				g.setPipeline(pipelineStatic);
				g.setMatrix(projectionLocationStatic,projection.multmat(cameraMatrix).multmat(FastMatrix4.scale(scale,scale,scale)));
				g.setMatrix(modelLocationStatic,FastMatrix4.scale(scale,scale,scale));
				g.setTexture(textureLocationStatic,mesh.texture);
				g.setTextureParameters(textureLocationStatic,TextureAddressing.Repeat,TextureAddressing.Repeat,TextureFilter.LinearFilter,TextureFilter.LinearFilter,MipMapFilter.LinearMipFilter);
				
				
				g.setMatrix(depthBiasLocation,biasMatrix.multmat(FastMatrix4.scale(scale,scale,scale)));
				g.setTexture(shadowMapLocation,shadowMap);
				g.setTextureParameters(shadowMapLocation,TextureAddressing.Clamp,TextureAddressing.Clamp,TextureFilter.PointFilter,TextureFilter.PointFilter,MipMapFilter.NoMipFilter);
				
				

		
				g.setIndexBuffer(mesh.indexBuffer);
				g.setVertexBuffer(mesh.vertexBuffer);
				g.drawIndexedVertices();
				g.end();
				
			}
			
			for(mesh in obj3d){
				g.begin();
				
				g.setPipeline(pipelineBones);
				g.setMatrix(projectionLocationBones, projection);
				g.setMatrix(viewLocationBones, cameraMatrix);
				g.setMatrix(modelLocationBones,modelMatrix.multmat(FastMatrix4.translation(0,0,-25)));
				g.setTexture(textureLocationBones,mesh.texture);
				g.setFloats(bonesLoction,mesh.skin.getBonesTransformations());
			
				g.setIndexBuffer(mesh.indexBuffer);
				g.setVertexBuffer(mesh.vertexBuffer);
				g.drawIndexedVertices();
			g.end();
			}
			
			for(mesh in water){
				g.begin();
				
				g.setPipeline(pipelineWater);
				g.setMatrix(projectionLocationWater,projection.multmat(cameraMatrix).multmat(FastMatrix4.translation(0.0,-40,0)).multmat(FastMatrix4.scale(8,8,8).multmat(FastMatrix4.rotationX(-Math.PI/2))));
				g.setMatrix(modelLocationWater,FastMatrix4.translation(0.0,0,0-40.0).multmat(FastMatrix4.scale(8,8,8).multmat(FastMatrix4.rotationY(-Math.PI/2))));
				g.setMatrix(modelViewWater,cameraMatrix.inverse());
				g.setTexture(textureLocationWater,Assets.images.waterNormal);
				g.setTextureParameters(textureLocationWater,TextureAddressing.Repeat,TextureAddressing.Repeat,TextureFilter.LinearFilter,TextureFilter.LinearFilter,MipMapFilter.NoMipFilter);
				
				g.setFloat2(offsetLocationWater,Scheduler.time()/60,Scheduler.time()/60);
				g.setFloat2(scaleLocationWater,15,15);
				

		
				g.setIndexBuffer(mesh.indexBuffer);
				g.setVertexBuffer(mesh.vertexBuffer);
				g.drawIndexedVertices();
				g.end();
				
			}
			//RenderTexture.renderTo(blur,finalTarget,0,0,1,RenderTexture.Chanel.Color,true);

			RenderTexture.renderTo(frame,finalTarget,0,0,1,RenderTexture.Chanel.Color,true);

		}
		
	}

	
	
}
