package away3d.core.block;

import flash.display.Graphics;
import flash.events.EventDispatcher;
import away3d.core.draw.ScreenVertex;
import fl.motion.Color;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;
import away3d.core.geom.Line2D;


/**
 * Convex hull primitive that blocks all primitives behind and contained completely inside.
 */
class ConvexBlocker extends Blocker  {
	
	private var _boundlines:Array<Dynamic>;
	/**
	 * Defines the vertices used to calulate the convex hull.
	 */
	public var vertices:Array<Dynamic>;
	

	/**
	 * @inheritDoc
	 */
	public override function calc():Void {
		
		_boundlines = [];
		screenZ = 0;
		maxX = -Math.POSITIVE_INFINITY;
		maxY = -Math.POSITIVE_INFINITY;
		minX = Math.POSITIVE_INFINITY;
		minY = Math.POSITIVE_INFINITY;
		var i:Int = 0;
		while (i < vertices.length) {
			var v:ScreenVertex = vertices[i];
			_boundlines.push(Line2D.from2points(v, vertices[(i + 1) % vertices.length]));
			if (screenZ < v.z) {
				screenZ = v.z;
			}
			if (minX > v.x) {
				minX = v.x;
			}
			if (maxX < v.x) {
				maxX = v.x;
			}
			if (minY > v.y) {
				minY = v.y;
			}
			if (maxY < v.y) {
				maxY = v.y;
			}
			
			// update loop variables
			i++;
		}

		maxZ = screenZ;
		minZ = screenZ;
	}

	/**
	 * @inheritDoc
	 */
	public override function contains(x:Float, y:Float):Bool {
		
		for (__i in 0..._boundlines.length) {
			var boundline:Line2D = _boundlines[__i];

			if (boundline.side(x, y) < 0) {
				return false;
			}
		}

		return true;
	}

	/**
	 * @inheritDoc
	 */
	public override function block(pri:DrawPrimitive):Bool {
		
		if (Std.is(pri, DrawTriangle)) {
			var tri:DrawTriangle = cast(pri, DrawTriangle);
			return contains(tri.v0.x, tri.v0.y) && contains(tri.v1.x, tri.v1.y) && contains(tri.v2.x, tri.v2.y);
		}
		return contains(pri.minX, pri.minY) && contains(pri.minX, pri.maxY) && contains(pri.maxX, pri.maxY) && contains(pri.maxX, pri.minY);
	}

	/**
	 * @inheritDoc
	 */
	public override function render():Void {
		
		var graphics:Graphics = source.session.graphics;
		graphics.lineStyle(2, Color.fromHSV(0, 0, (Math.sin(flash.Lib.getTimer() / 1000) + 1) / 2));
		var i:Int = 0;
		while (i < _boundlines.length) {
			var line:Line2D = _boundlines[i];
			var prev:Line2D = _boundlines[(i - 1 + _boundlines.length) % _boundlines.length];
			var next:Line2D = _boundlines[(i + 1 + _boundlines.length) % _boundlines.length];
			var a:ScreenVertex = Line2D.cross(prev, line);
			var b:ScreenVertex = Line2D.cross(line, next);
			graphics.moveTo(a.x, a.y);
			graphics.lineTo(b.x, b.y);
			graphics.moveTo(a.x, a.y);
			
			// update loop variables
			i++;
		}

		var count:Int = Std.int((maxX - minX) * (maxY - minY) / 2000);
		if (count > 50) {
			count = 50;
		}
		var k:Int = 0;
		while (k < count) {
			var x:Float = minX + (maxX - minX) * Math.random();
			var y:Float = minY + (maxY - minY) * Math.random();
			if (contains(x, y)) {
				graphics.lineStyle(1, Color.fromHSV(0, 0, Math.random()));
				graphics.drawCircle(x, y, 3);
			}
			
			// update loop variables
			k++;
		}

	}

	// autogenerated
	public function new () {
		super();
		
	}

	

}

