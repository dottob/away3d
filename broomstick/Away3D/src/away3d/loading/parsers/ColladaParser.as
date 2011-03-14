﻿package away3d.loading.parsers{	import away3d.arcane;	import away3d.core.base.Geometry;	import away3d.core.base.SubGeometry;	import away3d.entities.Mesh;	import away3d.loading.IResource;	import away3d.loading.ResourceDependency;    import away3d.containers.ObjectContainer3D;	import flash.display.Scene;	use namespace arcane;	/**	 * AWDParser provides a parser for the Collada (DAE) data type.	 */	public class ColladaParser extends ParserBase	{		private var _xml : XML;		private var _geometry_lib_xml : XMLList;		private var _visscene_lib_xml : XMLList;				private var _idx : int;		private var _state : int;				private var _geoms : Object;				private var _container:ObjectContainer3D;		/**		 * Creates a new ColladaParser object.		 * @param uri The url or id of the data or file to be parsed.		 */		public function ColladaParser(uri : String)		{			super(uri, ParserDataFormat.PLAIN_TEXT);						_state = 0;						_geoms = {};		}		 		/**		 * Indicates whether or not a given file extension is supported by the parser.		 * @param extension The file extension of a potential file to be parsed.		 * @return Whether or not the given file type is supported.		 */		public static function supportsType(extension : String) : Boolean		{			extension = extension.toLowerCase();			return extension == "dae";		}		/**		 * Tests whether a data block can be parsed by the parser.		 * @param data The data block to potentially be parsed.		 * @return Whether or not the given data is supported.		 */		public static function supportsData(data : *) : Boolean		{			// todo: implement			return false;		}				/**		 * @inheritDoc		 */		/*override arcane function resolveDependency(resourceDependency:ResourceDependency):void		{			var resource:BitmapDataResource = resourceDependency.resource as BitmapDataResource;			if (resource && resource.bitmapData && isBitmapDataValid(resource.bitmapData))				doSomething(resourceDependency.id, resource.bitmapData);		}*/				/**		 * @inheritDoc		 */		/*override arcane function resolveDependencyFailure(resourceDependency:ResourceDependency):void		{			// apply system default			//BitmapMaterial(mesh.material).bitmapData = defaultBitmapData;		}*/						/**		 * @inheritDoc		 */		/*override protected function initHandle() : IResource		{			_container = new ObjectContainer3D();			return _container;		}*/		/**		 * @inheritDoc		 */		/*protected override function proceedParsing() : Boolean		{			if (!_xml) {				// AbstractParser will have extracted text data				// from byte array if necessary.				_xml = new XML(_textData);								if (_xml.namespaceDeclarations().length) {					default xml namespace = _xml.namespaceDeclarations()[0];				}			}						while (hasTime()) {				switch (_state) {					case 0:						parseMaterials();						break;					case 1:						parseGeometries();						break;					case 2:						parseVisualScenes();						break;					default:						// Reached final state, done!						return PARSING_DONE;				}			}						return MORE_TO_PARSE;		}						private function parseMaterials() : void		{			// TODO: Actually parse something here			_state++;		}						private function parseGeometries() : void		{			if (!_geometry_lib_xml) {				_idx = 0;				_geometry_lib_xml = _xml.library_geometries.geometry;			}						while (hasTime()) {				var geom_xml : XML;				var poly_xml : XML;				var geom : Geometry;								geom_xml = _geometry_lib_xml[_idx];								geom = new Geometry;				_geoms[geom_xml.@id.toString()] = geom;								for each (poly_xml in geom_xml.mesh.polylist) {					var verts : Vector.<Number>;					var norms : Vector.<Number>;					var face_lengths : Vector.<uint>;					var indices_raw : Vector.<uint>;					var indices : Vector.<uint>;					var input_xml : XML;					var sub_geom : SubGeometry;										for each (input_xml in poly_xml.input) {						var source_xml : XML;						var i : uint;						var len : uint;						var idx : uint;						var face_start_idx : uint;												source_xml = resolve(input_xml.@source.toString(), geom_xml.mesh[0]);												switch (input_xml.@semantic.toString()) {							case 'VERTEX':								if (source_xml.localName().toString() == 'vertices')									source_xml = resolve(source_xml.input.@source.toString(), geom_xml.mesh[0]);								verts = parseVertexSourceVector(source_xml);								break;							case 'NORMAL':								norms = parseVertexSourceVector(source_xml);								break;						}					}										indices = new Vector.<uint>;					indices_raw = parseUIntList(poly_xml.p.toString());					face_lengths = parseUIntList(poly_xml.vcount.toString());										idx = 0;					face_start_idx = 0;					len = face_lengths.length;					for (i=0; i<len; i++) {						indices[idx++] = indices_raw[face_start_idx+0];						indices[idx++] = indices_raw[face_start_idx+2];						indices[idx++] = indices_raw[face_start_idx+4];												if (face_lengths[i] == 4) {							indices[idx++] = indices_raw[face_start_idx+0];							indices[idx++] = indices_raw[face_start_idx+4];							indices[idx++] = indices_raw[face_start_idx+6];						}												face_start_idx += face_lengths[i] * 2;					}										sub_geom = new SubGeometry();					sub_geom.updateVertexData(verts);					sub_geom.updateIndexData(indices);										geom.addSubGeometry(sub_geom);				}														_idx++;				if (_idx >= _geometry_lib_xml.length()) {					trace("done with geoms");					_state++;					return;				}			}		}								private function parseVisualScenes() : void		{			if (!_visscene_lib_xml) {				_idx = 0;				_visscene_lib_xml = _xml.library_visual_scenes.visual_scene;			}									while (hasTime()) {				var scene : Scene;				var scene_xml : XML;				var node_xml : XML;								scene_xml = _visscene_lib_xml[_idx];				scene = new Scene(scene_xml.@name, null, 1);								for each (node_xml in scene_xml.node) {					// TODO: Parse any node, not just meshes					if (node_xml.hasOwnProperty('instance_geometry')) {						var url : String;						var key : String;						var geom : Geometry;						var mesh : Mesh;												url = node_xml.instance_geometry.@url.toString();						key = url.substr(1);												geom = _geoms[key];						if (geom) {							mesh = new Mesh(null, geom);                            // todo: resolve properly//							addMesh(mesh);						}						else {							trace('COLLADA PARSING ERROR: Missing geometry', url);						}					}				}								_idx++;				if (_idx >= _visscene_lib_xml.length()) {					trace('done with scenes');					_state++;					return;				}			}		}										private function parseVertexSourceVector(xml : XML) : Vector.<Number>		{			var idx : uint;			var data : Array;			var nstr : String;			var floats : Vector.<Number>;						idx = 0;			floats = new Vector.<Number>;						data = xml.float_array[0].toString().split(' ');			for each (nstr in data) {				floats[idx++] = parseFloat(nstr);			}						return floats;		}				private function parseUIntList(str : String) : Vector.<uint>		{			var idx : uint;			var data : Array;			var n_str : String;			var list : Vector.<uint> = new Vector.<uint>;						idx = 0;			data = str.split(' ');			for each (n_str in data) {				list[idx++] = parseInt(n_str);			}						return list;		}						private function resolve(url : String, root : XML = null) : XML		{			var node_id : String;			var child : XML;						root ||= _xml;			node_id = url.substr(1);						var children : XMLList = root.children();			for each (child in root.children()) {				if (child.hasOwnProperty('@id') && child.@id.toString()==node_id)					return child;			}						return null;		}*/	}}