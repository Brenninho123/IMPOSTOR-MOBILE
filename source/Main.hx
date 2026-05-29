package;

import cpp.vm.Gc;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 1280;
	var gameHeight:Int = 720;
	var initialState:Class<FlxState> = TitleState;
	var zoom:Float = -1;
	var framerate:Int = 60;
	var skipSplash:Bool = true;
	var startFullscreen:Bool = false;

	public static var fpsCounter:FPS;
	public static var fpsVar:FPS;

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if (stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
		initialState = TitleState;
		#end

		ClientPrefs.startControls();

		#if cpp
		Gc.enable(true);
		#end

		addChild(new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, startFullscreen));
		FlxGraphic.defaultPersist = false;

		FlxG.signals.gameResized.add(onResizeGame);

		#if desktop
		fpsCounter = new FPS(10, 5, 0xFFFFFF);
		addChild(fpsCounter);

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		if (fpsCounter != null)
			fpsCounter.visible = ClientPrefs.showFPS;
		#end

		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#end

		#if mobile
		FlxG.autoPause = false;
		#end
	}

	function onResizeGame(w:Int, h:Int)
	{
		if (FlxG.cameras == null)
			return;

		for (cam in FlxG.cameras.list)
		{
			@:privateAccess
			if (cam != null && cam.filters != null && cam.filters.length > 0)
				fixShaderSize(cam);
		}
	}

	function fixShaderSize(camera:FlxCamera)
	{
		@:privateAccess
		{
			var sprite:Sprite = camera.flashSprite;

			if (sprite != null)
			{
				sprite.__cacheBitmap = null;
				sprite.__cacheBitmapData = null;
				sprite.__cacheBitmapData2 = null;
				sprite.__cacheBitmapData3 = null;
				sprite.__cacheBitmapColorTransform = null;
			}
		}
	}

	public function toggleFPS(fpsEnabled:Bool):Void
	{
		#if desktop
		if (fpsCounter != null)
			fpsCounter.visible = fpsEnabled;
		#end
	}

	public function setFPSCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		#if desktop
		if (fpsCounter != null)
			return fpsCounter.currentFPS;
		#end
		return 0;
	}

	public static function gc()
	{
		#if cpp
		Gc.run(true);
		#else
		openfl.system.System.gc();
		#end
	}
}