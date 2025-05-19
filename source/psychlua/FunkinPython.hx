package psychlua;

import substates.GameOverSubstate;
import cpp.Float64;
import cpp.ConstCharStar;
import cpp.RawPointer;
import cpp.Function;
import hxpy.*;

using cpp.RawPointer;

class FunkinPython
{
	static function makePythonSprite(self:RawPointer<PyObject>, args:RawPointer<PyObject>):RawPointer<PyObject>
	{
		var tag:ConstCharStar = "";
		var image:ConstCharStar = "";
		var x:Float64 = 0;
		var y:Float64 = 0;
		if (!PyArg.parseTuple(args, "ssdd", tag.addressOf(), image.addressOf(), x.addressOf(), y.addressOf()))
		{
			return null;
		}

		var sprite:FlxSprite = new FlxSprite(x, y);
		sprite.loadGraphic(Paths.image(image));
		FlxG.state.add(sprite);


		return PyBool.fromBool(true);
	}

	static function addPythonSprite(self:RawPointer<PyObject>, args:RawPointer<PyObject>):RawPointer<PyObject>
	{
		var tag:ConstCharStar = "";
		if (!PyArg.parseTuple(args, "s", tag.addressOf()))
		{
			return null;
		}

		var mySprite:FlxSprite = MusicBeatState.getVariables().get(tag);
		if (mySprite == null)
			PyBool.fromBool(false);

		FlxG.state.add(mySprite);

		trace("added the sprite");

		return PyBool.fromBool(true);
	}

	static function _generatePythonFunction():RawPointer<PyObject>
	{
		untyped __cpp__('
			static PyMethodDef EmbMethods[] = {
            	{"make_python_sprite", {0} , METH_VARARGS,""},
				{"add_python_sprite", {1} , METH_VARARGS,""},
				{NULL, NULL, 0, NULL}
			};

			static PyModuleDef EmbModule = {
				PyModuleDef_HEAD_INIT, "psychengine", NULL, -1, EmbMethods,
				NULL, NULL, NULL, NULL
			};
		', Function.fromStaticFunction(makePythonSprite),
			Function.fromStaticFunction(addPythonSprite));
		return untyped __cpp__("PyModule_Create(&EmbModule)");
	}

	public function new()
	{
		untyped __cpp__('PyImport_AppendInittab("psychengine", &_generatePythonFunction)');
		Py.initialize();
		PyRun.simpleFile(PyHelper.toFile("script.py"), "script.py");
		Py.finalizeEx();
	}
}
