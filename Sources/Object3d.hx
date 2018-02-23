package;
import kha.Canvas;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.VertexBuffer;
import kha.Image;

/**
 * ...
 * @author Joaquin
 */
class Object3d
{
	public var vertexBuffer: VertexBuffer;
	public var indexBuffer: IndexBuffer;
	public var skin:Skinning;
	public var animated:Bool;
	public var texture:Image;
	public function new() 
	{
		
	}
	public function render(aCanvas:Canvas,aPipeline:PipelineState)
	{
		
	}
}