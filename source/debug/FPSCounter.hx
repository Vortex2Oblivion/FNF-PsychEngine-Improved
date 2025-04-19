package debug;

import lime.system.System;
import flixel.FlxG;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.util.FlxStringUtil;
import external.memory.Memory;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	/**
		The current memory usage.
	**/
	public var memoryMegas(get, never):Float;

		/**
		The peak memory usage.
	**/
	public var maxMemoryMegas(get, never):Float;

	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		times = [];
	}

	private var _framesPassed:Int = 0;
    private var _previousTime:Float = 0;
    private var _updateClock:Float = 999999;

	// Event Handlers
	// I stole this shit from https://github.com/swordcube/friday-again-garfie-baby/blob/main/source/funkin/backend/StatsDisplay.hx lol
	private override function __enterFrame(deltaTime:Float):Void
	{
		_framesPassed++;
        final deltaTime:Float = System.getTimerPrecise() - _previousTime;
        _updateClock += deltaTime;
        
        if(_updateClock >= 1000) {
            currentFPS = _framesPassed;
            _framesPassed = 0;
            _updateClock = 0;
        }
        _previousTime = System.getTimerPrecise();
		updateText();
	}

	public dynamic function updateText():Void { // so people can override it in hscript
		text = 'FPS: ${currentFPS}'
		+ '\nMemory: ${FlxStringUtil.formatBytes(memoryMegas)} / ${FlxStringUtil.formatBytes(maxMemoryMegas)}';

		textColor = 0xFFFFFFFF;
		if (currentFPS < FlxG.drawFramerate * 0.5)
			textColor = 0xFFFF0000;
	}

	inline function get_memoryMegas():Float
		return Memory.getCurrentUsage();

	inline function get_maxMemoryMegas():Float
		return Memory.getPeakUsage();
}
