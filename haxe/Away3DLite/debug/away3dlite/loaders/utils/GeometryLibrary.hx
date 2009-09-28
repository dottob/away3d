﻿package away3dlite.loaders.utils;import away3dlite.core.utils.Debug;import flash.xml.XML;import away3dlite.loaders.data.GeometryData;/*** Store for all geometries associated with an externally loaded file.*/class GeometryLibrary /* extends Dictionary*/ extends Hash<GeometryData>{	private var _geometryArray:Array<GeometryData>;	private var _geometryArrayDirty:Bool;		private function updateGeometryArray():Void	{		_geometryArray = [];		for (_geodata in this) {			_geometryArray.push( _geodata );		}	}		public function new()	{		super();	}		/**	 * The name of the geometry used as a unique reference.	 */	public var name:String;		/**	 * Adds a geometry name reference to the library.	 */	public function addGeometry(name:String, ?geoXML:XML, ?ctrlXML:XML):GeometryData	{		//return if geometry already exists		if (untyped h.hasOwnProperty("$"+name))			return untyped h["$"+name];				_geometryArrayDirty = true;				var geometryData:GeometryData = new GeometryData();		geometryData.geoXML = geoXML;		geometryData.ctrlXML = ctrlXML;		untyped h["$" + (geometryData.name = name)] = geometryData;		return geometryData;	}		/**	 * Returns a geometry data object for the given name reference in the library.	 */	public function getGeometry(name:String):GeometryData	{		//return if geometry exists		if (untyped h.hasOwnProperty("$"+name))			return untyped h["$"+name];				Debug.warning("Geometry '" + name + "' does not exist");				return null;	}		/**	 * Returns an array of all geometries.	 */	public function getGeometryArray():Array<GeometryData>	{		if (_geometryArrayDirty)			updateGeometryArray();					return _geometryArray;	}}