package;
import kha.math.FastMatrix4;

class Bone{
	public var bindTransform:FastMatrix4;
	public var finalTransform:FastMatrix4;
	public var children:Array<Bone>;
	public var animations:Array<Float>;
	public var id:String;
	public var animated:Bool;
	public function new() 
	{
		children = new Array();
		finalTransform=FastMatrix4.identity();
	}
	public function addChild(aBone:Bone)
	{
		children.push(aBone);
	}
	public function setFrame(aFrame:Int,transform:FastMatrix4) {
		if(!animated){
			finalTransform=bindTransform;
			
		}else{
			matrixFromArray(animations, aFrame * 16, finalTransform);
		}
		var toPass:FastMatrix4=transform.multmat(finalTransform);
		finalTransform = toPass.multmat(bindTransform.inverse());
		
		for (child in children) 
		{
			child.setFrame(aFrame,toPass );
		}
		
	}
	
	public function getBone(aId:String):Bone
	{
		for (child in children) 
		{
			if (child.id == aId) return child;
			var result = child.getBone(aId);
			if (result != null) return result;
		}
		return null;
	}
	
	public static function matrixFromArray(values:Array<Float>,offset:Int,matrix:FastMatrix4):Void
	{
		matrix._00=values[offset+0];
		matrix._01=values[offset+1];
		matrix._02=values[offset+2];
		matrix._03=values[offset+3];

		matrix._10=values[offset+4];
		matrix._11=values[offset+5];
		matrix._12=values[offset+6];
		matrix._13=values[offset+7];

		matrix._20=values[offset+8];
		matrix._21=values[offset+9];
		matrix._22=values[offset+10];
		matrix._23=values[offset+11];

		matrix._30=values[offset+12];
		matrix._31=values[offset+13];
		matrix._32=values[offset+14];
		matrix._33=values[offset+15];
	}
	
	
	
}