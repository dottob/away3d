package gs.plugins;

import gs.TweenLite;


class ShortRotationPlugin extends TweenPlugin  {
	
	public static inline var VERSION:Float = 1.0;
	//If the API/Framework for plugins changes in the future, this number helps determine compatibility
	public static inline var API:Float = 1.0;
	

	public function new() {
		
		OPPOSITE_OR[X | X] = N;
		OPPOSITE_OR[XY | X] = Y;
		OPPOSITE_OR[XZ | X] = Z;
		OPPOSITE_OR[XYZ | X] = YZ;
		OPPOSITE_OR[Y | Y] = N;
		OPPOSITE_OR[XY | Y] = X;
		OPPOSITE_OR[XYZ | Y] = XZ;
		OPPOSITE_OR[YZ | Y] = Z;
		OPPOSITE_OR[Z | Z] = N;
		OPPOSITE_OR[XZ | Z] = X;
		OPPOSITE_OR[XYZ | Z] = XY;
		OPPOSITE_OR[YZ | Z] = Y;
		SCALINGS[1] = [1, 1, 1];
		SCALINGS[2] = [-1, 1, 1];
		SCALINGS[4] = [-1, 1, -1];
		SCALINGS[8] = [1, 1, -1];
		SCALINGS[16] = [1, -1, 1];
		SCALINGS[32] = [-1, -1, 1];
		SCALINGS[64] = [-1, -1, -1];
		SCALINGS[128] = [1, -1, -1];
		
		super();
		this.propName = "shortRotation";
		this.overwriteProps = [];
	}

	override public function onInitTween($target:Dynamic, $value:Dynamic, $tween:TweenLite):Bool {
		
		if (typeof($value) == "number") {
			trace("WARNING: You appear to be using the old shortRotation syntax. Instead of passing a number, please pass an object with properties that correspond to the rotations values For example, TweenMax.to(mc, 2, {shortRotation:{rotationX:-170, rotationY:25}})");
			return false;
		}
		var p:String;
		for (p in $value) {
			initRotation($target, p, Reflect.field($target, p), Reflect.field($value, p));
			
		}

		return true;
	}

	public function initRotation($target:Dynamic, $propName:String, $start:Float, $end:Float):Void {
		
		var dif:Float = ($end - $start) % 360;
		if (dif != dif % 180) {
			dif = (dif < 0) ? dif + 360 : dif - 360;
		}
		addTween($target, $propName, $start, $start + dif, $propName);
		this.overwriteProps[this.overwriteProps.length] = $propName;
	}

}

