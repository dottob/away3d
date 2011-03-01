﻿package away3d.loading.parsers{	import away3d.arcane;	import away3d.core.base.Geometry;	import away3d.core.base.SubGeometry;	import away3d.loading.IResource;	import away3d.loading.ResourceDependency;	import away3d.entities.Mesh;    import away3d.containers.ObjectContainer3D;	import away3d.materials.BitmapMaterial;	import away3d.core.base.data.UV;	import away3d.core.base.data.Vertex;	import away3d.loading.BitmapDataResource;	    import flash.geom.Matrix3D;	import flash.geom.Vector3D;	import flash.display.BitmapData;		use namespace arcane;	/**	* AWD1Parser provides a parser for the AWD data type. The version 1.0 in ascii. Usually generated by Prefab3d 1.x and Away3D engine <4.0 exporters	* 	*/	public class AWD1Parser extends ParserBase	{		private var objs:Array = [];		private var geos:Array = [];		private var oList:Array =[];		private var aC:Array = [];		private var _container:ObjectContainer3D;		private var _meshList:Vector.<Mesh>;		private var _inited:Boolean;		private var containersList:Array = [];		private var uvs:Array;		private var _charIndex:uint;		private var _oldIndex:uint;		private var _stringLength:uint;		/**		 * Creates a new AWD1Parser object.		 * @param uri The url or id of the data or file to be parsed.		 */				public function AWD1Parser(uri : String = "")		{			super(uri, ParserDataFormat.PLAIN_TEXT);		}				/**		 * Indicates whether or not a given file extension is supported by the parser.		 * @param extension The file extension of a potential file to be parsed.		 * @return Whether or not the given file type is supported.		 */		public static function supportsType(extension : String) : Boolean		{			extension = extension.toLowerCase();			return extension == "awd";		}				/**		 * Tests whether a data block can be parsed by the parser.		 * @param data The data block to potentially be parsed.		 * @return Whether or not the given data is supported.		 */		public static function supportsData(data : *) : Boolean {return false;}		 		/**		 * @inheritDoc		 */		override arcane function resolveDependency(resourceDependency:ResourceDependency):void		{			var resource:BitmapDataResource = resourceDependency.resource as BitmapDataResource;						if (resource){				var m:Mesh = retreiveMeshFromID(resourceDependency.id);				if(m != null && resource.bitmapData != null)					BitmapMaterial(m.material).bitmapData = resource.bitmapData;							}		}				/**		 * @inheritDoc		 */		override arcane function resolveDependencyFailure(resourceDependency:ResourceDependency):void		{			 //missing load for resourceDependency.id;		}		 		/**		 * @inheritDoc		 */		override protected function initHandle() : IResource		{			_container = new ObjectContainer3D();			_container.name = "ac_"+containersList.length;			aC.push(_container);						return _container;		}		/**		 * @inheritDoc		 */		protected override function proceedParsing() : Boolean		{			var line:String;			var creturn:String = String.fromCharCode(10);						if(_textData.indexOf("#t:bsp") != -1)				throw new Error("AWD1 holding BSP information is not supported");							if(_textData.indexOf(creturn) == -1 || _textData.indexOf(creturn)> 200)				creturn = String.fromCharCode(13);						if(!_inited){				_inited = true;				_meshList = new Vector.<Mesh>();				_stringLength = _textData.length;				_charIndex = _textData.indexOf(creturn, 0);				_oldIndex = _charIndex;			}						var cont:ObjectContainer3D;			var state:String = "";			var isMesh:Boolean;			var isMaterial:Boolean;			var id:int = 0;			var buffer:uint=0;			var oData:Object;			var dline:Array;			var m:Matrix3D;			var i:uint;			var version:String = "";			 			while(_charIndex<_stringLength && hasTime()){				 				_charIndex = _textData.indexOf(creturn, _oldIndex);								if(_charIndex == -1)					_charIndex = _stringLength;									line = _textData.substring(_oldIndex, _charIndex);            				if(_charIndex != _stringLength)					_oldIndex = _charIndex+1;									if(line.substring(0,1) == "#" && state != line.substring(0,2)){					state = line.substring(0,2);					id = 0;					buffer = 0;					if(state == "#v")						version = line.substring(3,line.length-1);					if(state == "#f")						isMaterial = (parseInt(line.substring(3,4)) == 2) as Boolean;					if(state == "#t")						isMesh = (line.substring(3,7) == "mesh");										continue;				}				 				dline = line.split(",");				if(dline.length <= 1 && !(state == "#m" || state == "#d"))					continue;				if(state == "#o"){					if(buffer == 0){						id = dline[0];						m = new Matrix3D(Vector.<Number>([parseFloat(dline[1]), parseFloat(dline[5]), parseFloat(dline[9]), 0, parseFloat(dline[2]), parseFloat(dline[6]), parseFloat(dline[10]), 0, parseFloat(dline[3]), parseFloat(dline[7]), parseFloat(dline[11]), 0, parseFloat(dline[4]), parseFloat(dline[8]), parseFloat(dline[12]), 1]));						++buffer;					} else {						/*if(customPath != "")							var standardURL:Array = dline[12].split("/");*/												//legacy properties left here in case of debug needs						oData = {name:(dline[0] == "")? "m_"+id: dline[0] ,									transform:m,									//pivotPoint:new Vector3D(parseFloat(dline[1]), parseFloat(dline[2]), parseFloat(dline[3])),									container:parseInt(dline[4]),									//bothsides:(dline[5] == "true")? true : false,									//ownCanvas:(dline[6] == "true")? true : false,									//pushfront:(dline[7] == "true")? true : false,									//pushback:(dline[8] == "true")? true : false,									x:parseFloat(dline[9]),									y:parseFloat(dline[10]),									z:parseFloat(dline[11]),									//material:(isMaterial && dline[12] != null && dline[12] != "")? resolvedP+((customPath != "")? standardURL[standardURL.length-1] : dline[12]) : null};									material:(isMaterial && dline[12] != null && dline[12] != "")? dline[12] : null};						objs.push(oData);						buffer = 0;					}				}				if(state == "#d"){											switch(buffer){						case 0:							id = geos.length;							geos.push({});							++buffer;							geos[id].aVstr = line.substring(2,line.length);							break;													case 1:							geos[id].aUstr = line.substring(2,line.length);							geos[id].aV= read(geos[id].aVstr).split(",");							geos[id].aU= read(geos[id].aUstr).split(",");							++buffer;							break;													case 2:							geos[id].f= line.substring(2,line.length);							objs[id].geo = geos[id];							buffer = 0;					}									}				 				if(state == "#c" && !isMesh){					id = parseInt(dline[0]);					cont = new ObjectContainer3D();					m = new Matrix3D(Vector.<Number>([parseFloat(dline[1]), parseFloat(dline[5]), parseFloat(dline[9]), 0, parseFloat(dline[2]), parseFloat(dline[6]), parseFloat(dline[10]), 0, parseFloat(dline[3]), parseFloat(dline[7]), parseFloat(dline[11]), 0, parseFloat(dline[4]), parseFloat(dline[8]), parseFloat(dline[12]), 1]));					cont.transform = m;					cont.name = (dline[13] == "null" || dline[13] == undefined)? "cont_"+id: dline[13];					aC.push(cont);					aC[0].addChild(cont);				}            			}						var ref:Object;			var mesh:Mesh;			for(i = 0;i<objs.length;++i){				ref = objs[i];				if(ref){					mesh = new Mesh();					mesh.name = ref.name;					_meshList.push(mesh);					if(ref.container != -1 && !isMesh)						aC[ref.container].addChild(mesh);					mesh.transform = ref.transform;					mesh.material = new BitmapMaterial(defaultBitmapData);					mesh.material.name = ref.name;										_dependencies.push(new ResourceDependency(ref.name, baseUri+ref.material, null , this));					parseFacesToMesh(ref.geo, mesh);				}			}						if(_charIndex >= _stringLength){								containersList = [];				return PARSING_DONE;			} 			 			return MORE_TO_PARSE;        }				private function parseFacesToMesh(geo : Object, mesh : Mesh) : void		{			var j:int;			var av:Array;			var au:Array;			 			var aRef:Array;			var mRef:Array;			 			var vertices:Vector.<Number> = new Vector.<Number>();			var indices:Vector.<uint> = new Vector.<uint>();			var uvs:Vector.<Number> = new Vector.<Number>();			var index:uint;			var iindex:uint;			var uindex:uint;			aRef = geo.f.split(",");			if (geo.m)				mRef = geo.m.split(",");			for(j = 0;j<aRef.length;j+=6){				indices[iindex] = iindex;				iindex++;				indices[iindex] = iindex;				iindex++;				indices[iindex] = iindex;				iindex++;								//face is inverted compared to f10 awd generator				av = geo.aV[parseInt(aRef[j+1],16)].split("/");				vertices[index++] = parseFloat(av[0]);				vertices[index++] = parseFloat(av[1]);				vertices[index++] = parseFloat(av[2]);								av = geo.aV[parseInt(aRef[j], 16)].split("/");				vertices[index++] = parseFloat(av[0]);				vertices[index++] = parseFloat(av[1]);				vertices[index++] = parseFloat(av[2]);								av = geo.aV[parseInt(aRef[j+2],16)].split("/");				vertices[index++] = parseFloat(av[0]);				vertices[index++] = parseFloat(av[1]);				vertices[index++] = parseFloat(av[2]);								au = geo.aU[parseInt(aRef[j+4],16)].split("/");				uvs[uindex++] = parseFloat(au[0]);				uvs[uindex++] = 1-parseFloat(au[1]);								au = geo.aU[parseInt(aRef[j+3],16)].split("/");				uvs[uindex++] = parseFloat(au[0]);				uvs[uindex++] = 1-parseFloat(au[1]);								au = geo.aU[parseInt(aRef[j+5],16)].split("/");				uvs[uindex++] = parseFloat(au[0]);				uvs[uindex++] = 1-parseFloat(au[1]);			}						var sub_geom:SubGeometry;			var geom:Geometry = mesh.geometry;			 			sub_geom = new SubGeometry()			sub_geom.updateVertexData(vertices);			sub_geom.updateIndexData(indices);			sub_geom.updateUVData(uvs);			geom.addSubGeometry(sub_geom);		}		 		private function retreiveMeshFromID(id:String):Mesh		{			for(var i:int = 0;i<_meshList.length;++i)				if(Mesh(_meshList[i]).name == id)					return Mesh(_meshList[i]);						return null;		}		 		private function read(str:String):String		{			var start:int= 0;			var chunk:String;			var dec:String = "";			var charcount:int = str.length;			for(var i:int = 0;i<charcount;++i){				if (str.charCodeAt(i)>=44 && str.charCodeAt(i)<= 48 ){					dec+= str.substring(i, i+1);				}else{					start = i;					chunk = "";					while(str.charCodeAt(i)!=44 && str.charCodeAt(i)!= 45 && str.charCodeAt(i)!= 46 && str.charCodeAt(i)!= 47 && i<=charcount){						i++;					}					chunk = ""+parseInt("0x"+str.substring(start, i), 16 );					dec+= chunk;					i--;				}			}			return dec;		}		 	}}