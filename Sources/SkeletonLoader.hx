package;

import OgexData.BoneNode;
import OgexData.Node;
/**
 * ...
 * @author Joaquin
 */
class SkeletonLoader
{
	public static function getSkeleton(data:OgexData):Array<SkeletonD> {
		var skeletons:Array<SkeletonD> = new Array();
		for(child in data.children){
			findSkeleton(child, skeletons, null);
		}
		return skeletons;
	}
	static function findSkeleton(aNode:Node,skeletons:Array<SkeletonD>,current:Bone)
	{
		var skeleton:SkeletonD = null;
		for (node in aNode.children) 
		{
			if (Std.is(node, BoneNode))
			{
				var boneNode:BoneNode = cast node;
				if (skeleton == null && current == null) {
					skeleton = new SkeletonD();
					skeleton.ID = aNode.ref;
					skeletons.push(skeleton);
				}
				var bone = createBone(boneNode);
				if (current != null)
				{
					current.addChild(bone);
				}else {
					skeleton.bones.push(bone);
				}
				findSkeleton(boneNode, skeletons, bone);
			}
		}
	}
	
	static private function createBone(boneNode:BoneNode) :Bone
	{
		var bone:Bone = new Bone();
		bone.id = boneNode.ref;
		if(boneNode.animation!=null)
		{
			bone.animated=true;
			bone.animations = boneNode.animation.track.value.key.values;
		}else{
			bone.animated=false;
		//	bone.animations = boneNode.transform.values;

		}
		return bone;
	}
	
}