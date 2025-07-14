package objects;

import backend.ManiaData;
import backend.animation.PsychAnimationController;

import shaders.RGBPalette;
import shaders.RGBPalette.RGBShaderReference;

class StrumNote extends FlxSprite
{
	public var rgbShader:RGBShaderReference;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;
	public var downScroll:Bool = false;
	public var sustainReduce:Bool = true;
	private var player:Int;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public var useRGBShader:Bool = true;
	public function new(x:Float, y:Float, leData:Int, player:Int) {
		animation = new PsychAnimationController(this);

		rgbShader = new RGBShaderReference(this, Note.initializeGlobalRGBShader(leData % 4));
		rgbShader.enabled = false;
		if(PlayState.SONG != null && PlayState.SONG.disableNoteRGB) useRGBShader = false;
		
		var arr:Array<FlxColor> = ClientPrefs.data.arrowRGB[leData % 4];
		if(PlayState.isPixelStage) arr = ClientPrefs.data.arrowRGBPixel[leData % 4];
		
		if(leData <= arr.length)
		{
			@:bypassAccessor
			{
				rgbShader.r = arr[0];
				rgbShader.g = arr[1];
				rgbShader.b = arr[2];
			}
		}

		noteData = leData;
		this.player = player;
		this.noteData = leData;
		this.ID = noteData;
		super(x, y);

		var skin:String = null;
		if(PlayState.SONG != null && PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 1) skin = PlayState.SONG.arrowSkin;
		else skin = Note.defaultNoteSkin;

		var customSkin:String = skin + Note.getNoteSkinPostfix();
		if(Paths.fileExists('images/$customSkin.png', IMAGE)) skin = customSkin;

		texture = skin; //Load texture and anims
		scrollFactor.set();
		playAnim('static');
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if (animation.curAnim != null)
			lastAnim = animation.curAnim.name;

		if (PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + texture));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + texture), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purple', [4]);
			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], 12, false);
					animation.add('confirm', [12, 16], 24, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], 12, false);
					animation.add('confirm', [13, 17], 24, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], 12, false);
					animation.add('confirm', [14, 18], 12, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], 12, false);
					animation.add('confirm', [15, 19], 24, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture);
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red', 'arrowRIGHT');

			antialiasing = ClientPrefs.data.antialiasing;
			scale.set(ManiaData.noteSizes[PlayState.SONG.mania], ManiaData.noteSizes[PlayState.SONG.mania]);

			this.animation.addByPrefix('static', "arrow" + ManiaData.staticAnimations[PlayState.SONG.mania][noteData].toUpperCase(), 24, false);
			this.animation.addByPrefix('pressed', ManiaData.noteAnimations[PlayState.SONG.mania][noteData] + ' press', 24, false);
			this.animation.addByPrefix('confirm', ManiaData.noteAnimations[PlayState.SONG.mania][noteData] + ' confirm', 24, false);
		}
		updateHitbox();

		if (lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function playerPosition()
	{
		switch (PlayState.SONG.mania)
		{
			case 0 | 1 | 2:
				x += width * noteData;
			case 3:
				x += (Note.swagWidth * noteData);
			default:
				x += ((width - ManiaData.strumOffsets[PlayState.SONG.mania]) * noteData);
		}

		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
		x -= ManiaData.noteOffsetsX[PlayState.SONG.mania];
		y += ManiaData.noteOffsetsY[PlayState.SONG.mania];
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		if(animation.curAnim != null)
		{
			centerOffsets();
			centerOrigin();
		}
		if(useRGBShader) rgbShader.enabled = (animation.curAnim != null && animation.curAnim.name != 'static');
	}
}
