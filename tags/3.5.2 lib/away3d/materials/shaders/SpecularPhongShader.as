﻿package away3d.materials.shaders{	import away3d.containers.*;	import away3d.arcane;	import away3d.core.base.*;	import away3d.core.math.*;	import away3d.core.render.*;	import away3d.core.utils.*;	import away3d.lights.*;		import flash.display.*;	import flash.geom.*;	import flash.utils.*;			use namespace arcane;		/**	 * Specular shader class for directional lighting.	 * 	 * @see away3d.lights.DirectionalLight3D	 */    public class SpecularPhongShader extends AbstractShader    {    	/** @private */		arcane override function updateMaterial(source:Object3D, view:View3D):void        {        	var _source_scene_directionalLights:Array = source.scene.directionalLights;			var directional:DirectionalLight3D;        	for each (directional in _source_scene_directionalLights) {        		if (!directional.specularTransform[source] || !directional.specularTransform[source][view] || view._updatedObjects[source] || view.updated) {        			directional.setSpecularTransform(source, view);        			updateFaces(source, view);        		}        	}        }		/** @private */		arcane override function renderLayer(priIndex:uint, viewSourceObject:ViewSourceObject, renderer:Renderer, layer:Sprite, level:int):int        {        	super.renderLayer(priIndex, viewSourceObject, renderer, layer, level);        	        	var _source_scene_directionalLights:Array = _source.scene.directionalLights;			var directional:DirectionalLight3D;        	for each (directional in _source_scene_directionalLights) {				_specularTransform = directional.specularTransform[_source][_view];        		        		_n0 = _source.geometry.getVertexNormal(_face.v0);				_n1 = _source.geometry.getVertexNormal(_face.v1);				_n2 = _source.geometry.getVertexNormal(_face.v2);								_nFace = _face.normal;								_szx = _specularTransform.szx;				_szy = _specularTransform.szy;				_szz = _specularTransform.szz;								specVal1 = Math.pow(_n0.x * _szx + _n0.y * _szy + _n0.z * _szz, _shininess/20);				specVal2 = Math.pow(_n1.x * _szx + _n1.y * _szy + _n1.z * _szz, _shininess/20);				specVal3 = Math.pow(_n2.x * _szx + _n2.y * _szy + _n2.z * _szz, _shininess/20);				specValFace = Math.pow(_nFaceTransZ = _nFace.x * _szx + _nFace.y * _szy + _nFace.z * _szz, _shininess/20);				        		_shape = _session.getLightShape(this, level++, layer, directional);	        		        	_shape.blendMode = blendMode;	        	_shape.transform.colorTransform = _specColor;	        	_graphics = _shape.graphics;	        					if (_nFaceTransZ > 0 && (specValFace > _specMin || specVal1 > _specMin || specVal2 > _specMin || specVal3 > _specMin || _nFace.dot(_n0) < 0.8 || _nFace.dot(_n1) < 0.8 || _nFace.dot(_n2) < 0.8)) {					_source.session.renderTriangleBitmap(directional.specularBitmap, getUVData(priIndex), _screenVertices, _screenIndices, _startIndex, _endIndex, smooth, false, _graphics);				} else {					_source.session.renderTriangleColor(0x000000, 1, _screenVertices, renderer.primitiveCommands[priIndex], _screenIndices, _startIndex, _endIndex, _graphics);				}        	}						if (debug)                _source.session.renderTriangleLine(0, 0x0000FF, 1, _screenVertices, renderer.primitiveCommands[priIndex], _screenIndices, _startIndex, _endIndex);                        return level;        }        		private var _shininess:Number;		private var _specular:uint;		private var _specMin:Number;		private var _specColor:ColorTransform;		private var _specularTransform:MatrixAway3D;		private var _nFace:Number3D;		private var _nFaceTransZ:Number;		private var specVal1:Number;		private var specVal2:Number;		private var specVal3:Number;		private var specValFace:Number;		private var coeff1:Number;		private var coeff2:Number;		private var coeff3:Number;		private var _sxx:Number;		private var _sxy:Number;		private var _sxz:Number;        private var _syx:Number;        private var _syy:Number;        private var _syz:Number;        private var _szx:Number;        private var _szy:Number;        private var _szz:Number;                private function calcNormals(source:Mesh, face:Face):void        {        	source; face;						_sxx = _specularTransform.sxx;			_sxy = _specularTransform.sxy;			_sxz = _specularTransform.sxz;						_syx = _specularTransform.syx;			_syy = _specularTransform.syy;			_syz = _specularTransform.syz;			        	eTri0x = _n0.x * _sxx + _n0.y * _sxy + _n0.z * _sxz;			eTri0y = _n0.x * _syx + _n0.y * _syy + _n0.z * _syz;			eTri1x = _n1.x * _sxx + _n1.y * _sxy + _n1.z * _sxz;			eTri1y = _n1.x * _syx + _n1.y * _syy + _n1.z * _syz;			eTri2x = _n2.x * _sxx + _n2.y * _sxy + _n2.z * _sxz;			eTri2y = _n2.x * _syx + _n2.y * _syy + _n2.z * _syz;						coeff1 = Math.acos(specVal1)/Math.sqrt(eTri0x*eTri0x + eTri0y*eTri0y);			coeff2 = Math.acos(specVal2)/Math.sqrt(eTri1x*eTri1x + eTri1y*eTri1y);			coeff3 = Math.acos(specVal3)/Math.sqrt(eTri2x*eTri2x + eTri2y*eTri2y);						eTri0x *= coeff1;			eTri0y *= coeff1;			eTri1x *= coeff2;			eTri1y *= coeff2;			eTri2x *= coeff3;			eTri2y *= coeff3;        }        		/**		 * @inheritDoc		 */        protected function updateFaces(source:Object3D, view:View3D):void        {        	notifyMaterialUpdate();        	        	for each (var faceMaterialVO:FaceMaterialVO in _faceDictionary)        		if (source == faceMaterialVO.source && view == faceMaterialVO.view) {	        		if (!faceMaterialVO.cleared)	        			faceMaterialVO.clear();	        		faceMaterialVO.invalidated = true;        		}        }        		protected override function calcUVT(priIndex:uint, uvt:Vector.<Number>):Vector.<Number>		{			priIndex;						calcNormals(_source as Mesh, _faceVO.face);						uvt[0] = (1 + eTri0x)/2;    		uvt[1] = (1 - eTri0y)/2;    		uvt[3] = (1 + eTri1x)/2;    		uvt[4] = (1 - eTri1y)/2;    		uvt[6] = (1 + eTri2x)/2;    		uvt[7] = (1 - eTri2y)/2;    		    		return uvt;		}				protected override function calcMapping(priIndex:uint, map:Matrix):Matrix		{			priIndex;						calcNormals(_source as Mesh, _faceVO.face);						//catch mapping where points are the same (flat surface)			if (eTri1x == eTri0x && eTri1y == eTri0y) {				eTri1x += 0.1;				eTri1y += 0.1;			}			if (eTri2x == eTri1x && eTri2y == eTri1y) {				eTri2x += 0.1;				eTri2y += 0.1;			}			if (eTri0x == eTri2x && eTri0y == eTri2y) {				eTri0x += 0.1;				eTri0y += 0.1;			}			//calulate mapping			map.a = 255*(eTri1x - eTri0x);			map.b = 255*(eTri1y - eTri0y);			map.c = 255*(eTri2x - eTri0x);			map.d = 255*(eTri2y - eTri0y);			map.tx = 255*(eTri0x + 1);			map.ty = 255*(eTri0y + 1);            map.invert();                        return map;		}				/**		 * @inheritDoc		 */        protected override function renderShader(priIndex:uint):void        {    		_n0 = _source.geometry.getVertexNormal(_face.v0);			_n1 = _source.geometry.getVertexNormal(_face.v1);			_n2 = _source.geometry.getVertexNormal(_face.v2);						var _source_scene_directionalLights:Array = _source.scene.directionalLights;			var directional:DirectionalLight3D;			for each (directional in _source_scene_directionalLights) {        		_specularTransform = directional.specularTransform[_source][_view];								_nFace = _face.normal;								_szx = _specularTransform.szx;				_szy = _specularTransform.szy;				_szz = _specularTransform.szz;								specVal1 = Math.pow(_n0.x * _szx + _n0.y * _szy + _n0.z * _szz, _shininess/20);				specVal2 = Math.pow(_n1.x * _szx + _n1.y * _szy + _n1.z * _szz, _shininess/20);				specVal3 = Math.pow(_n2.x * _szx + _n2.y * _szy + _n2.z * _szz, _shininess/20);				specValFace = Math.pow(_nFaceTransZ = _nFace.x * _szx + _nFace.y * _szy + _nFace.z * _szz, _shininess/20);								if (_nFaceTransZ > 0 && (specValFace > _specMin || specVal1 > _specMin || specVal2 > _specMin || specVal3 > _specMin || _nFace.dot(_n0) < 0.8 || _nFace.dot(_n1) < 0.8 || _nFace.dot(_n2) < 0.8)) {										//store a clone					if (_faceMaterialVO.cleared && !_parentFaceMaterialVO.updated) {						_faceMaterialVO.bitmap = _parentFaceMaterialVO.bitmap.clone();						_faceMaterialVO.bitmap.lock();					}										_faceMaterialVO.cleared = false;					_faceMaterialVO.updated = true;										_mapping = getMapping(priIndex);		            _mapping.concat(_faceMaterialVO.invtexturemapping);		            					//draw into faceBitmap					_graphics = _s.graphics;					_graphics.clear();					_graphics.beginBitmapFill(directional.specularBitmap, _mapping, false, smooth);					_graphics.drawRect(0, 0, _bitmapRect.width, _bitmapRect.height);		            _graphics.endFill();					_faceMaterialVO.bitmap.draw(_s, null, _specColor, blendMode);					//_faceMaterialVO.bitmap.draw(directional.specularBitmap, _mapping, _specColor, blendMode, _faceMaterialVO.bitmap.rect, smooth);				}        	}        }        		/**		 * The exponential dropoff value used for specular highlights.		 */        public function get shininess():Number        {        	return _shininess;        }		        public function set shininess(val:Number):void        {        	_shininess = val;        	_specMin = Math.pow(0.8, _shininess/20);        }				/**		 * Color value for specular light.		 */		public function get specular():uint		{			return _specular;		}				public function set specular(val:uint):void		{			_specular = val;            _specColor = new ColorTransform(((_specular & 0xFF0000) >> 16)/255, ((_specular & 0xFF00) >> 8)/255, (_specular & 0xFF)/255, 1, 0, 0, 0, 0);		}				/**		 * Creates a new <code>SpecularPhongShader</code> object.		 * 		 * @param	init	[optional]	An initialisation object for specifying default instance properties.		 */        public function SpecularPhongShader(init:Object = null)        {        	super(init);        	            shininess = ini.getNumber("shininess", 20);            specular = ini.getColor("specular", 0xFFFFFF);        }    }}