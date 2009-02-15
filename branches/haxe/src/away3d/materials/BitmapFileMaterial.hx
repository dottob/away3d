package away3d.materials;

import flash.events.ProgressEvent;
import flash.display.BitmapData;
import flash.events.Event;
import away3d.events.MaterialEvent;
import flash.events.IOErrorEvent;
import flash.display.Bitmap;
import flash.display.Loader;
import flash.net.URLRequest;


/**
 * Dispatched when the material completes a file load successfully.
 * 
 * @eventType away3d.events.LoaderEvent
 */
// [Event(name="loadSuccess", type="away3d.events.LoaderEvent")]

/**
 * Dispatched when the material fails to load a file.
 * 
 * @eventType away3d.events.LoaderEvent
 */
// [Event(name="loadError", type="away3d.events.LoaderEvent")]

/**
 * Dispatched every frame the material is loading.
 * 
 * @eventType away3d.events.LoaderEvent
 */
// [Event(name="loadProgress", type="away3d.events.LoaderEvent")]

// use namespace arcane;

/**
 * Bitmap material that loads it's texture from an external bitmapasset file.
 */
class BitmapFileMaterial extends TransformBitmapMaterial, implements ITriangleMaterial, implements IUVMaterial {
	
	private var _loader:Loader;
	private var _materialloaderror:MaterialEvent;
	private var _materialloadprogress:MaterialEvent;
	private var _materialloadsuccess:MaterialEvent;
	

	private function onError(e:IOErrorEvent):Void {
		
		if (_materialloaderror == null) {
			_materialloaderror = new MaterialEvent();
		}
		dispatchEvent(_materialloaderror);
	}

	private function onProgress(e:ProgressEvent):Void {
		
		if (_materialloadprogress == null) {
			_materialloadprogress = new MaterialEvent();
		}
		dispatchEvent(_materialloadprogress);
	}

	private function onComplete(e:Event):Void {
		
		bitmap = Bitmap(_loader.content).bitmapData;
		if (_materialloadsuccess == null) {
			_materialloadsuccess = new MaterialEvent();
		}
		dispatchEvent(_materialloadsuccess);
	}

	/**
	 * Creates a new <code>BitmapFileMaterial</code> object.
	 *
	 * @param	url					The location of the bitmapasset to load.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?url:String="", ?init:Dynamic=null) {
		
		
		super(new BitmapData(), init);
		_loader = new Loader();
		_loader.addEventListener(IOErrorEvent.IO_ERROR, onError);
		_loader.addEventListener(ProgressEvent.PROGRESS, onProgress);
		_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
		_loader.load(new URLRequest());
	}

	/**
	 * Default method for adding a loadSuccess event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnLoadSuccess(listener:Dynamic):Void {
		
		addEventListener(MaterialEvent.LOAD_SUCCESS, listener, false, 0, true);
	}

	/**
	 * Default method for removing a loadSuccess event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnLoadSuccess(listener:Dynamic):Void {
		
		removeEventListener(MaterialEvent.LOAD_SUCCESS, listener, false);
	}

	/**
	 * Default method for adding a loadProgress event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnLoadProgress(listener:Dynamic):Void {
		
		addEventListener(MaterialEvent.LOAD_PROGRESS, listener, false, 0, true);
	}

	/**
	 * Default method for removing a loadProgress event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnLoadProgress(listener:Dynamic):Void {
		
		removeEventListener(MaterialEvent.LOAD_PROGRESS, listener, false);
	}

	/**
	 * Default method for adding a loadError event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnLoadError(listener:Dynamic):Void {
		
		addEventListener(MaterialEvent.LOAD_ERROR, listener, false, 0, true);
	}

	/**
	 * Default method for removing a loadError event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnLoadError(listener:Dynamic):Void {
		
		removeEventListener(MaterialEvent.LOAD_ERROR, listener, false);
	}

}

