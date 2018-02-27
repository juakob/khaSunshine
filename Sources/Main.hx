package;

import kha.System;
import kha.input.Mouse;
import kha.SystemImpl;

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
				SystemImpl.notifyOfFullscreenChange(sizeChange,error);
				SystemImpl.requestFullscreen();
			}
			#end
			
	}
	var inFullScreen:Bool;
	static function sizeChange():Void
	{
		#if js
		var i = cast(js.Browser.document.getElementById('khanvas'), js.html.CanvasElement);
		
		if(SystemImpl.isFullscreen()){
		 	trace("fullscreen");
			 
		 	System.changeResolution(js.Browser.window.screen.availWidth,js.Browser.window.screen.availHeight);
			 game.resize(js.Browser.window.screen.availWidth,js.Browser.window.screen.availHeight);
		 }else{
			trace("not fullscreen");
			var i = cast(js.Browser.document.getElementById('khanvas'), js.html.CanvasElement);
			game.resize(960,540);
			System.changeResolution(960,540);
		}
	
		//trace(js.Browser.window.screen.availWidth+"x"+js.Browser.window.screen.availHeight);
	
		
		#end
	}
	static function error():Void{
		trace("cant go full screen");
	}
	static function startKha(){
		#if js
			//haxe.macro.Compiler.includeFile("../Libraries/Bullet/js/ammo/ammo.wasm.js");
			kha.LoaderImpl.loadBlobFromDescription({ files: ["ammo.js"] }, function(b: kha.Blob) {
				var print = function(s:String) { trace(s); };
				var loaded = function() { print("ammo ready"); };
				untyped __js__("(1, eval)({0})", b.toString());
				untyped __js__("Ammo({print:print}).then(loaded)");
				System.init({title: "MeshLoader", width: 960, height: 540}, init);
				
			});
			#else
				System.init({title: "MeshLoader", width: 960, height: 540}, init);
		
			#end
	}
	static var game:MeshLoader;
	static function init() {
		Mouse.get().notify(onMouseDown, onMouseDown, null, null);
		game = new MeshLoader();
		System.notifyOnRender(game.render);
	}
}
