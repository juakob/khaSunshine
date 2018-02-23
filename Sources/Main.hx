package;

import kha.System;
import kha.input.Mouse;

class Main {
	public static function main() {
		startKha();
	}
//	var ignore:Bool=false;
	public static function onMouseDown(a:Int,b:Int,c:Int) 
	{
		
	//	Mouse.get().remove(onMouseDown, onMouseDown, null, null);
		#if js
			var i = cast(js.Browser.document.getElementById('khanvas'), js.html.CanvasElement);
			if (i != null)
			{
				if ((cast i).webkitRequestFullscreen!= null) {
					(cast i).webkitRequestFullscreen();
				} else if ((cast i).mozRequestFullScreen!= null) {
					(cast i).mozRequestFullScreen();
				} else if ((cast i).msRequestFullscreen!= null) {
					(cast i).msRequestFullscreen();
				}  else
				if (i.requestFullscreen!= null) {
					i.requestFullscreen();
				} 
				
				//startKha();
			}
			#end
			
	}
	static function startKha(){
		#if js
			//haxe.macro.Compiler.includeFile("../Libraries/Bullet/js/ammo/ammo.wasm.js");
			kha.LoaderImpl.loadBlobFromDescription({ files: ["ammo.js"] }, function(b: kha.Blob) {
				var print = function(s:String) { trace(s); };
				var loaded = function() { print("ammo ready"); };
				untyped __js__("(1, eval)({0})", b.toString());
				untyped __js__("Ammo({print:print}).then(loaded)");
				System.init({title: "MeshLoader", width: 800, height: 600}, init);
				
			});
			#else
				System.init({title: "MeshLoader", width: 800, height: 600}, init);
		
			#end
	}
	static function init() {
		Mouse.get().notify(onMouseDown, onMouseDown, null, null);
		var game = new MeshLoader();
		System.notifyOnRender(game.render);
	}
}
