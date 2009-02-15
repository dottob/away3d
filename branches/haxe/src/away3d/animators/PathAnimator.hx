package away3d.animators;

import flash.events.EventDispatcher;
import away3d.animators.data.Path;
import away3d.animators.data.CurveSegment;
import away3d.core.base.Object3D;
import away3d.core.math.Number3D;
import away3d.core.math.Matrix3D;
import away3d.core.utils.Init;
import away3d.cameras.Camera3D;
import away3d.events.PathEvent;
import flash.events.Event;
import away3d.animators.utils.PathUtils;


class PathAnimator extends EventDispatcher  {
	public var time(getTime, null) : Float;
	public var offsetTime(null, setOffsetTime) : Float;
	public var pathlength(getPathlength, null) : Float;
	public var position(getPosition, null) : Number3D;
	public var objectRotations(getObjectRotations, null) : Number3D;
	public var orientation(getOrientation, null) : Number3D;
	public var offset(getOffset, setOffset) : Number3D;
	public var offsetX(getOffsetX, setOffsetX) : Float;
	public var offsetY(getOffsetY, setOffsetY) : Float;
	public var offsetZ(getOffsetZ, setOffsetZ) : Float;
	public var object3d(getObject3d, setObject3d) : Dynamic;
	public var targetobject(getTargetobject, setTargetobject) : Dynamic;
	public var rotations(getRotations, setRotations) : Array<Dynamic>;
	public var easein(getEasein, setEasein) : Bool;
	public var easeout(getEaseout, setEaseout) : Bool;
	public var aligntopath(getAligntopath, setAligntopath) : Bool;
	public var path(getPath, setPath) : Path;
	public var fps(getFps, setFps) : Int;
	public var duration(getDuration, setDuration) : Int;
	public var index(getIndex, setIndex) : Int;
	
	private var _path:Path;
	private var _time:Float;
	private var _index:Float;
	private var _indextime:Float;
	private var _duration:Float;
	private var _aTime:Array<Dynamic>;
	private var _rotations:Array<Dynamic>;
	private var _lookAt:Bool;
	private var _alignToPath:Bool;
	private var _object3d:Dynamic;
	private var _targetobject:Dynamic;
	private var _easein:Bool;
	private var _easeout:Bool;
	private var _fps:Int;
	private var ini:Init;
	private var _offset:Number3D;
	private var _rotatedOffset:Number3D;
	private var _objectrotation:Number3D;
	private var _position:Number3D;
	//events
	private var _eCycle:PathEvent;
	private var _bCycle:Bool;
	private var _lasttime:Float;
	private var _from:Float;
	private var _to:Float;
	private var _bRange:Bool;
	private var _eRange:PathEvent;
	private var _bSegment:Bool;
	private var _eSeg:PathEvent;
	private var _lastSegment:Int;
	private var _nRot:Number3D;
	private var _worldAxis:Number3D;
	private var _basePosition:Number3D;
	

	private function updatePosition(st:Number3D, contr:Number3D, end:Number3D, t:Float):Void {
		
		var dt:Float = 2 * (1 - t);
		_basePosition.x = st.x + t * (dt * (contr.x - st.x) + t * (end.x - st.x));
		_basePosition.y = st.y + t * (dt * (contr.y - st.y) + t * (end.y - st.y));
		_basePosition.z = st.z + t * (dt * (contr.z - st.z) + t * (end.z - st.z));
		_position.x = _basePosition.x;
		_position.y = _basePosition.y;
		_position.z = _basePosition.z;
	}

	private function updateObjectPosition(?rotate:Bool=false):Void {
		
		if (rotate && _offset != null) {
			_rotatedOffset.x = _offset.x;
			_rotatedOffset.y = _offset.y;
			_rotatedOffset.z = _offset.z;
			_rotatedOffset = PathUtils.rotatePoint(_rotatedOffset, _nRot);
			_position.x += _rotatedOffset.x;
			_position.y += _rotatedOffset.y;
			_position.z += _rotatedOffset.z;
		} else if (_offset != null) {
			_position.x += _offset.x;
			_position.y += _offset.y;
			_position.z += _offset.z;
		}
		_object3d.position = _position;
	}

	function new(path:Path, object3d:Dynamic, ?init:Dynamic=null) {
		// autogenerated
		super();
		this._index = 0;
		this._indextime = 0;
		this._rotatedOffset = new Number3D();
		this._position = new Number3D();
		this._lastSegment = 0;
		this._worldAxis = new Number3D();
		this._basePosition = new Number3D();
		
		
		_path = path;
		_worldAxis = _path.worldAxis;
		_object3d = object3d;
		ini = Init.parse(init);
		_duration = ini.getNumber("duration", 1000, {min:0});
		_lookAt = ini.getBoolean("lookat", false);
		_alignToPath = ini.getBoolean("aligntopath", !_lookAt);
		_easein = ini.getBoolean("easein", false);
		_easeout = ini.getBoolean("easeout", false);
		_fps = ini.getInt("fps", 20, {min:0});
		_offset = ini.getNumber3D("offset");
		if (init.rotations != null && init.rotations.length > 0) {
			_rotations = ini.getArray("rotations");
			_nRot = new Number3D();
		}
		_targetobject = ini.getObject("targetobject", null);
		if (_lookAt && _targetobject == null) {
			_lookAt = false;
		}
		if (_lookAt && _alignToPath) {
			_alignToPath = false;
		}
		_index = 0;
		_indextime = 0;
		_time = 0;
		_lasttime = 0;
		_aTime = [];
		update(0);
	}

	/**
	 * Update automatically the tween. Note that if you want to use a more extended tween engine like Tweener. Use the "update" handler.
	 *
	 * @param startFrom 	A Number  from 0 to 1. Note: this will have fx on the next iteration on the Path, if you want it start at this point, use clearTime handler first.
	 */
	public function animateOnPath(?startFrom:Float=0):Void {
		
		if (_aTime.length == 0) {
			_lastSegment = 0;
			_indextime = 0;
			_aTime = AWTweener.calculate((startFrom == 0) ? _fps : _fps + (_fps * (1 * startFrom)), (startFrom == 0) ? 0 : 1 * startFrom, 1, _duration, _easein, _easeout);
		}
		update(_aTime[_indextime]);
		_indextime = _indextime + 1 > _aTime.length - 1 ? 0 : _indextime + 1;
	}

	/**
	 * Calculates the new position and set the object on the path accordingly
	 *
	 * @param t 	A Number  from 0 to 0.999999999  (less than one to allow alignToPath)
	 */
	public function update(t:Float):Void {
		
		if (t < 0) {
			t = 0;
			_lastSegment = 0;
		}
		if (t >= 0.999999999) {
			t = 0.999999999;
			_lastSegment = 0;
			if (_bCycle && t != _lasttime) {
				dispatchEvent(_eCycle);
			}
		}
		_lasttime = t;
		var curve:CurveSegment;
		var multi:Float = _path.array.length * t;
		_index = Math.floor(multi);
		curve = _path.array[_index];
		if (_offset != null) {
			_object3d.position = _basePosition;
		}
		var nT:Float = multi - _index;
		updatePosition(curve.v0, curve.vc, curve.v1, nT);
		var rotate:Bool;
		if (_lookAt && _targetobject != null && !_alignToPath) {
			_object3d.x += _offset.x;
			_object3d.y += _offset.y;
			_object3d.z += _offset.z;
			_object3d.lookAt(_targetobject.scenePosition);
		} else if (_alignToPath && !_lookAt) {
			if (_rotations != null) {
				if (_rotations[_index + 1] == null) {
					_nRot.x = _rotations[_rotations.length - 1].x * nT;
					_nRot.y = _rotations[_rotations.length - 1].y * nT;
					_nRot.z = _rotations[_rotations.length - 1].z * nT;
				} else {
					_nRot.x = _rotations[_index].x + ((_rotations[_index + 1].x - _rotations[_index].x) * nT);
					_nRot.y = _rotations[_index].y + ((_rotations[_index + 1].y - _rotations[_index].y) * nT);
					_nRot.z = _rotations[_index].z + ((_rotations[_index + 1].z - _rotations[_index].z) * nT);
				}
				_worldAxis.x = 0;
				_worldAxis.y = 1;
				_worldAxis.z = 0;
				_worldAxis = PathUtils.rotatePoint(_worldAxis, _nRot);
				_object3d.lookAt(_basePosition, _worldAxis);
				rotate = true;
			} else {
				_object3d.lookAt(_position);
			}
		}
		if (!_lookAt) {
			updateObjectPosition(rotate);
		}
		if (_bSegment && _index > 0 && _lastSegment < _index && t < 0.999999999) {
			_lastSegment = Std.int(_index);
			dispatchEvent(_eSeg);
		}
		if (_bRange && (t >= _from && t <= _to)) {
			dispatchEvent(_eRange);
		}
		_time = t;
	}

	/**
	 * Updates a position Number3D on the path at a given time. Do not use this handler to animate, it's in there to add dummy's or place camera before or after
	 * the animated object. Use the update() or the automatic tweened animateOnPath() handlers instead.
	 *
	 * @param p	Number3D. The Number3D to update according to the "t" time parameter.
	 * @param t	Number. A Number  from 0 to 1
	 * @see animateOnPath
	 * @see update
	 */
	public function getPositionOnPath(p:Number3D, t:Float):Void {
		
		t = (t < 0) ? 0 : (t > 1) ? 1 : t;
		var m:Float = _path.array.length * t;
		var i:Int = Math.floor(m);
		var curve:CurveSegment = _path.array[i];
		var nT:Float = m - i;
		var dt:Float = 2 * (1 - nT);
		p.x = curve.v0.x + nT * (dt * (curve.vc.x - curve.v0.x) + nT * (curve.v1.x - curve.v0.x));
		p.y = curve.v0.y + nT * (dt * (curve.vc.y - curve.v0.y) + nT * (curve.v1.y - curve.v0.y));
		p.z = curve.v0.z + nT * (dt * (curve.vc.z - curve.v0.z) + nT * (curve.v1.z - curve.v0.z));
	}

	/**
	 * returns the actual time on the path.a Number from 0 to 1
	 */
	public function getTime():Float {
		
		return _time;
	}

	/**
	 * clear the tween array in order to start from another time on the path, if the animateOnPath handler is being used
	 */
	public function clearTime():Void {
		
		_aTime = [];
		_lasttime = 0;
		_time = 0;
	}

	/**
	 * set the saved time back to a lower time to avoid mesh rotation Y of 180.
	 */
	public function setOffsetTime(t:Float):Float {
		
		_lasttime = (_lasttime - t > 0) ? _lasttime - t : 0;
		return t;
	}

	/**
	 * returns the segment count of the path
	 */
	public function getPathlength():Float {
		
		return _path.array.length;
	}

	/**
	 * returns the actual tweened pos on the path with no optional offset applyed
	 */
	public function getPosition():Number3D {
		
		return _position;
	}

	/**
	 * returns the actual rotations of the object3D;
	 */
	public function getObjectRotations():Number3D {
		
		if (_objectrotation == null) {
			_objectrotation = new Number3D();
		}
		_objectrotation.x = _object3d.rotationX;
		_objectrotation.y = _object3d.rotationY;
		_objectrotation.z = _object3d.rotationZ;
		return _objectrotation;
	}

	/**
	 * returns the actual interpolated rotation along the path;
	 */
	public function getOrientation():Number3D {
		
		return _nRot;
	}

	/**
	 * sets an optional offset to the pos on the path, ideal for cameras or resuse same Path object for other objects
	 */
	public function setOffset(val:Number3D):Number3D {
		
		_offset = val;
		return val;
	}

	public function getOffset():Number3D {
		
		return _offset;
	}

	/**
	 * To update an optional offset by the x, y and z properties
	 */
	public function setOffsetX(val:Float):Float {
		
		if (_offset == null) {
			_offset = new Number3D();
		}
		_offset.x = val;
		return val;
	}

	public function getOffsetX():Float {
		
		if (_offset == null) {
			_offset = new Number3D();
		}
		return _offset.x;
	}

	public function setOffsetY(val:Float):Float {
		
		if (_offset == null) {
			_offset = new Number3D();
		}
		_offset.y = val;
		return val;
	}

	public function getOffsetY():Float {
		
		if (_offset == null) {
			_offset = new Number3D();
		}
		return _offset.y;
	}

	public function setOffsetZ(val:Float):Float {
		
		if (_offset == null) {
			_offset = new Number3D();
		}
		_offset.z = val;
		return val;
	}

	public function getOffsetZ():Float {
		
		if (_offset == null) {
			_offset = new Number3D();
		}
		return _offset.z;
	}

	/**
	 * sets the object to be animated along the path. The object must have 3 public properties "x,y,z".
	 * Note: if an rotation array is passed, the object must have rotationX, Y and Z public properties.
	 */
	public function setObject3d(object3d:Dynamic):Dynamic {
		
		_object3d = object3d;
		return object3d;
	}

	public function getObject3d():Dynamic {
		
		return _object3d;
	}

	/**
	 * sets the target object that the object to be animated along the path will lookat
	 */
	public function setTargetobject(object3d:Dynamic):Dynamic {
		
		_lookAt = (object3d != null);
		aligntopath = !_lookAt;
		_targetobject = object3d;
		return object3d;
	}

	public function getTargetobject():Dynamic {
		
		return _targetobject;
	}

	/**
	 * sets an optional array of rotations, probably same as the PathExtrude or PathDuplicator rotation array in order to follow the twisted shape.
	 */
	public function setRotations(rot:Array<Dynamic>):Array<Dynamic> {
		
		_rotations = (rot != null && rot.length > 0) ? rot : null;
		if (_rotations != null && _nRot == null) {
			_nRot = new Number3D();
		}
		return rot;
	}

	public function getRotations():Array<Dynamic> {
		
		return _rotations;
	}

	/**
	 * defines if the motion must easein along the path
	 */
	public function setEasein(b:Bool):Bool {
		
		_easein = b;
		return b;
	}

	public function getEasein():Bool {
		
		return _easein;
	}

	/**
	 * defines if the motion must easeout along the path
	 */
	public function setEaseout(b:Bool):Bool {
		
		_easeout = b;
		return b;
	}

	public function getEaseout():Bool {
		
		return _easeout;
	}

	/**
	 * defines if the object animated along the path must be aligned to the path.
	 */
	public function setAligntopath(b:Bool):Bool {
		
		_alignToPath = b;
		return b;
	}

	public function getAligntopath():Bool {
		
		return _alignToPath;
	}

	/**
	 * defines the path to follow
	 * @see Path
	 */
	public function setPath(p:Path):Path {
		
		_path = p;
		_worldAxis = _path.worldAxis;
		return p;
	}

	public function getPath():Path {
		
		return _path;
	}

	/**
	 * defines the frame rate per second. This only affects the animateOnPath handler.
	 */
	public function setFps(val:Int):Int {
		
		_fps = val;
		return val;
	}

	public function getFps():Int {
		
		return _fps;
	}

	/**
	 * defines the duration in ticks (ms). This only affects the animateOnPath handler.
	 */
	public function setDuration(val:Int):Int {
		
		_duration = val;
		return val;
	}

	public function getDuration():Int {
		
		return _duration;
	}

	/**
	 * defines the frame rate per second. This only affects the animateOnPath handler.
	 */
	public function setIndex(val:Int):Int {
		
		_index = (val > _path.array.length - 1) ? _path.array.length - 1 : (val > 0) ? val : 0;
		_aTime = [];
		return val;
	}

	public function getIndex():Int {
		
		return _index;
	}

	/**
	 * Default method for adding a cycle event listener. Event fired when the time reaches  0.999999999 or higher.
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnCycle(listener:Dynamic):Void {
		
		_lasttime = 0;
		_bCycle = true;
		_eCycle = new PathEvent();
		this.addEventListener(PathEvent.CYCLE, listener, false, 0, false);
	}

	/**
	 * Default method for removing a cycle event listener
	 * 
	 * @param		listener		The listener function
	 */
	public function removeOnCycle(listener:Dynamic):Void {
		
		_bCycle = false;
		_eCycle = null;
		this.removeEventListener(PathEvent.CYCLE, listener, false);
	}

	/**
	 * Default method for adding a range event listener. Event fired when the time is >= from and <= to variables.
	 * 
	 * @param		listener		The listener function
	 */
	public function addOnRange(listener:Dynamic, ?from:Float=0, ?to:Float=0):Void {
		
		_from = from;
		_to = to;
		_bRange = true;
		_eRange = new PathEvent();
		this.addEventListener(PathEvent.RANGE, listener, false, 0, false);
	}

	/**
	 * Default method for removing a range event listener
	 * 
	 * @param		listener		The listener function
	 */
	public function removeOnRange(listener:Dynamic):Void {
		
		_from = 0;
		_to = 0;
		_bRange = false;
		_eRange = null;
		this.removeEventListener(PathEvent.RANGE, listener, false);
	}

	/**
	 * Default method for adding a segmentchange event listener. Event fired when the time pointer reads another CurveSegment. Note that it's not triggered if the value time is decreasing along the path.
	 * 
	 * @param		listener		The listener function
	 */
	public function addOnChangeSegment(listener:Dynamic, ?from:Float=0, ?to:Float=0):Void {
		
		_bSegment = true;
		_lastSegment = 0;
		_eSeg = new PathEvent();
		this.addEventListener(PathEvent.CHANGE_SEGMENT, listener, false, 0, false);
	}

	/**
	 * Default method for removing a range event listener
	 * 
	 * @param		listener		The listener function
	 */
	public function removeOnChangeSegment(listener:Dynamic):Void {
		
		_bSegment = false;
		_eSeg = null;
		_lastSegment = 0;
		this.removeEventListener(PathEvent.CHANGE_SEGMENT, listener, false);
	}

}

