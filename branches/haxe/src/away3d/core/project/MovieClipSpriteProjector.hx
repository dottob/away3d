package away3d.core.project;

import flash.events.EventDispatcher;
import away3d.sprites.MovieClipSprite;
import away3d.containers.View3D;
import flash.utils.Dictionary;
import away3d.core.utils.DrawPrimitiveStore;
import away3d.core.draw.IPrimitiveConsumer;
import away3d.core.draw.ScreenVertex;
import away3d.core.base.Object3D;
import away3d.core.draw.IPrimitiveProvider;
import flash.display.DisplayObject;
import flash.display.Sprite;
import away3d.core.math.Matrix3D;


class MovieClipSpriteProjector implements IPrimitiveProvider {
	public var view(getView, setView) : View3D;
	
	private var _view:View3D;
	private var _vertexDictionary:Dictionary;
	private var _drawPrimitiveStore:DrawPrimitiveStore;
	private var _movieClipSprite:MovieClipSprite;
	private var _movieclip:DisplayObject;
	private var _screenVertex:ScreenVertex;
	private var _persp:Float;
	

	public function getView():View3D {
		
		return _view;
	}

	public function setView(val:View3D):View3D {
		
		_view = val;
		_drawPrimitiveStore = view.drawPrimitiveStore;
		return val;
	}

	public function primitives(source:Object3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):Void {
		
		_vertexDictionary = _drawPrimitiveStore.createVertexDictionary(source);
		_movieClipSprite = cast(source, MovieClipSprite);
		_movieclip = _movieClipSprite.movieclip;
		_screenVertex = _view.camera.lens.project(viewTransform, _movieClipSprite.center);
		_persp = view.camera.zoom / (1 + _screenVertex.z / view.camera.focus);
		_screenVertex.z += _movieClipSprite.deltaZ;
		_screenVertex.x -= _movieclip.width / 2;
		_screenVertex.y -= _movieclip.height / 2;
		if (_movieClipSprite.rescale) {
			_movieclip.scaleX = _movieclip.scaleY = _persp * _movieClipSprite.scaling;
		}
		consumer.primitive(_drawPrimitiveStore.createDrawDisplayObject(source, _screenVertex, _movieClipSprite.session, _movieclip));
	}

	// autogenerated
	public function new () {
		
	}

	

}

