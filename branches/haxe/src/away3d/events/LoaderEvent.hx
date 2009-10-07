package away3d.events;

import away3d.loaders.Object3DLoader;
import flash.events.Event;


/**
 * Passed as a parameter when a 3d object loader event occurs
 */
class LoaderEvent extends Event  {
	
	/**
	 * Defines the value of the type property of a loadSuccess event object.
	 */
	public static inline var LOAD_SUCCESS:String = "loadSuccess";
	/**
	 * Defines the value of the type property of a loadError event object.
	 */
	public static inline var LOAD_ERROR:String = "loadError";
	/**
	 * A reference to the loader object that is relevant to the event.
	 */
	public var loader:Object3DLoader;
	

	/**
	 * Creates a new <code>LoaderEvent</code> object.
	 * 
	 * @param	type	The type of the event. Possible values are: <code>LoaderEvent.LOAD_SUCCESS</code> and <code>LoaderEvent.LOAD_ERROR</code>.
	 * @param	loader	A reference to the loader object that is relevant to the event.
	 */
	public function new(type:String, loader:Object3DLoader) {
		
		
		super(type);
		this.loader = loader;
	}

	/**
	 * Creates a copy of the LoaderEvent object and sets the value of each property to match that of the original.
	 */
	public override function clone():Event {
		
		return new LoaderEvent(type, loader);
	}

}
