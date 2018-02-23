package;
import kha.math.FastMatrix4;

/**
 * ...
 * @author Joaquin
 */
class SkeletonD
{
	public var transformation:FastMatrix4;
	public var bones:Array<Bone>;
	public var ID:String;
	public function new() 
	{
		transformation = FastMatrix4.identity();
		bones = new Array();
		
	}
	public function setFrame(aFrame:Int)
	{
		for (child in bones) 
		{
			child.setFrame(aFrame, transformation);
		}
	}
	public function getBone(aId:String):Bone
	{
		for (child in bones) 
		{
			if (child.id == aId) return child;
			var result = child.getBone(aId);
			if (result != null) return result;
		}
		return null;
	}
	
	
}