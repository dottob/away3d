﻿package away3d.materials.utils{	import away3d.core.base.Vertex;	import away3d.core.base.UV;	import away3d.core.base.Mesh;	import away3d.core.base.Object3D;	import away3d.core.base.Face;	import away3d.containers.ObjectContainer3D;	import away3d.core.math.Number3D;	/**	* Class remaps the uvs of an Object3D for a given orientation:	* projection strings = "front", "back", "top", "bottom", "left","right", "spherical" or "spherical2"	*/		public class Projector	{		private static var _width:Number;		private static var _height:Number;		private static var _offsetW:Number;		private static var _offsetH:Number;		private static var _orientation:String;		private static var _selection:Array;						/**		*  Applies the mapping to the Object3D object according to string orientation		* @param	 orientation	String. Defines the way the map will be projected onto the Object3D. orientation value  can be: "front", "back", "top", "bottom", "left", "right", "spherical" or "spherical2"		* @param	 object3d		Object3d. The Object3D to remap.		* @param	 selection		Array. An array of booleans that defines if vertexes must be considered for the bounds. Applicable only if Object3D is type Mesh.		* @ For instance: projecting only 1 faces on a mesh composed of two faces [false, false, false, true, true, true]. In this case only uvs of face 2 would be altered, and projection would be based only on this vertexes bounds.		* vo0, vo1, v02 are considered for bounderies, and only if true the uv's will be altered. Allowing random selection for a custom editor UV editor.		*/		public static function project(orientation:String, object3d:Object3D, selection:Array = null):void		{			_orientation = orientation.toLowerCase();						var minX:Number = 0;			var minY:Number = 0;			var minZ:Number = 0;			var maxX:Number = 0;			var maxY:Number = 0;			var maxZ:Number = 0;						_selection = selection;						if(!object3d is Mesh || selection == null){								_selection = null;				minX = object3d.minX;				minY = object3d.minY;				minZ = object3d.minZ;				maxX = object3d.maxX;				maxY = object3d.maxY;				maxZ = object3d.maxZ;							} else{				var i:int;				var f:Face;				var index:int = 0;								var m:Mesh = object3d as Mesh; 								for(i = 0;i<m.faces.length;++i){					f = m.faces[i];					index = i*3;					if(_selection[index] != null){						if(_selection[index]){							minX = Math.min(f.v0.x, minX);							minY = Math.min(f.v0.y, minY);							minZ = Math.min(f.v0.z, minZ);							maxX = Math.max(f.v0.x, maxX);							maxY = Math.max(f.v0.y, maxY);							maxZ = Math.max(f.v0.z, maxZ);						}						index ++;						if(_selection[index]){							minX = Math.min(f.v1.x, minX);							minY = Math.min(f.v1.y, minY);							minZ = Math.min(f.v1.z, minZ);							maxX = Math.max(f.v1.x, maxX);							maxY = Math.max(f.v1.y, maxY);							maxZ = Math.max(f.v1.z, maxZ);						}						index ++;						if(_selection[index]){							minX = Math.min(f.v2.x, minX);							minY = Math.min(f.v2.y, minY);							minZ = Math.min(f.v2.z, minZ);							maxX = Math.max(f.v2.x, maxX);							maxY = Math.max(f.v2.y, maxY);							maxZ = Math.max(f.v2.z, maxZ);						}					} else {						break;					}									}											}						if(_orientation == "front" || _orientation == "back"){				_width = maxX - minX;				_height = maxY - minY;				_offsetW = (minX>0)? -minX : Math.abs(minX);				_offsetH= (minY>0)? -minY : Math.abs(minY);				}						if(_orientation == "left" || _orientation == "right"){				_width = maxZ - minZ;				_height = maxY - minY;				_offsetW = (minZ>0)? -minZ : Math.abs(minZ);				_offsetH= (minY>0)? -minY : Math.abs(minY);			}						if(_orientation == "top" || _orientation == "bottom"){				_width = maxX - minX;				_height = maxZ - minZ;				_offsetW = (minX>0)? -minX : Math.abs(minX);				_offsetH= (minZ>0)? -minZ : Math.abs(minZ);			}						parse(object3d);		}				private static function parse(object3d:Object3D):void		{			 			if(object3d is ObjectContainer3D){							var obj:ObjectContainer3D = (object3d as ObjectContainer3D);							for(var i:int =0;i<obj.children.length;++i){										if(obj.children[i] is ObjectContainer3D){						parse(obj.children[i]);					} else if(obj.children[i] is Mesh){						remapMesh( obj.children[i]);					}				}							} else if (object3d is Mesh){				remapMesh( object3d as Mesh);			}			 		}				private static function remapMesh(mesh:Mesh):void		{			if(_orientation.indexOf("spherical")!= -1)				remapSpherical(mesh);			else				remapLinear(mesh);		}				private static function averageNormals(v:Vertex, n:Number3D, fn:Number3D, mesh:Mesh):Number3D		{			n.x = 0;			n.y = 0;			n.z = 0;			var count:int = 0;			var f:Face;			var norm:Number3D;			 			for(var i:int = 0;i<mesh.faces.length;++i){				f = mesh.faces[i];				if((f.v0.x == v.x && f.v0.y == v.y && f.v0.z == v.z) || (f.v1.x == v.x && f.v1.y == v.y && f.v1.z == v.z )|| (f.v2.x == v.x && f.v2.y == v.y && f.v2.z == v.z)){					norm = f.normal;					n.x += norm.x;					n.y += norm.y;					n.z += norm.z;					count++;				}			}			 			n.x /= count;			n.y /= count;			n.z /= count;						n.normalize();			 			return n;		}		 				private static function remapSpherical(mesh:Mesh):void		{			var i:int;			var f:Face;			var fn:Number3D;			var nv:Number3D = new Number3D();			var spherical:Boolean = (_orientation == "spherical")? true : false;			if(_selection != null){								var index:int = 0;												for(i = 0;i<mesh.faces.length;++i){					f = mesh.faces[i];					index = i*3;					fn = f.normal;															if(_selection[index] != null && _selection[index]){						nv = averageNormals(f.v0, nv, fn, mesh);						if(spherical){							f.uv0.u = (nv.x+1)*.5;							f.uv0.v = 1-((nv.y+1)*.5);						} else{							f.uv0.u = (nv.x+1)/4;							if (nv.z < 0)								f.uv0.u = 1-f.uv0.u;														f.uv0.v = 1-((nv.y+1)/4);							if (nv.y < 0)								f.uv0.v = 1-(1-f.uv0.v);						}					}										index++;					if(_selection[index] != null && _selection[index]){						nv = averageNormals(f.v1, nv, fn, mesh);						if(spherical){							f.uv1.u = (nv.x+1)*.5;							f.uv1.v = 1-((nv.y+1)*.5);						} else{							f.uv1.u = (nv.x+1)/4;							if (nv.z < 0)								f.uv1.u = 1-f.uv1.u;														f.uv1.v = 1-((nv.y+1)/4);							if (nv.y < 0)								f.uv1.v = 1-(1-f.uv1.v);						}					}										index++;					if(_selection[index] != null && _selection[index]){						nv = averageNormals(f.v2, nv, fn, mesh);						if(spherical){							f.uv2.u = (nv.x+1)*.5;							f.uv2.v = 1-((nv.y+1)*.5);						} else{							f.uv2.u = (nv.x+1)/4;							if (nv.z < 0)								f.uv2.u = 1-f.uv2.u;														f.uv2.v = 1-((nv.y+1)/4);							if (nv.y < 0)								f.uv2.v = 1-(1-f.uv2.v);						}					}									}							} else{								for(i = 0;i<mesh.faces.length;++i){					f = mesh.faces[i];					fn = f.normal;					nv = averageNormals(f.v0, nv, fn, mesh);					if(spherical){						f.uv0.u = (nv.x+1)*.5;						f.uv0.v = 1-((nv.y+1)*.5);					} else{						f.uv0.u = (nv.x+1)/4;						if (nv.z < 0)							f.uv0.u = 1-f.uv0.u;												f.uv0.v = 1-((nv.y+1)/4);						if (nv.y < 0)							f.uv0.v = 1-(1-f.uv0.v);					}					 										nv = averageNormals(f.v1, nv, fn, mesh);					if(spherical){						f.uv1.u = (nv.x+1)*.5;						f.uv1.v = 1-((nv.y+1)*.5);					} else{						f.uv1.u = (nv.x+1)/4;						if (nv.z < 0)							f.uv1.u = 1-f.uv1.u;												f.uv1.v = 1-((nv.y+1)/4);						if (nv.y < 0)							f.uv1.v = 1-(1-f.uv1.v);					}															nv = averageNormals(f.v2, nv, fn, mesh);					if(spherical){						f.uv2.u = (nv.x+1)*.5;						f.uv2.v = 1-((nv.y+1)*.5);					} else{						f.uv2.u = (nv.x+1)/4;						if (nv.z < 0)							f.uv2.u = 1-f.uv2.u;												f.uv2.v = 1-((nv.y+1)/4);						if (nv.y < 0)							f.uv2.v = 1-(1-f.uv2.v);					}														}							}					}				private static function remapLinear(mesh:Mesh):void		{			var i:int;			var f:Face;			var index:int = 0;						if(_selection != null){				for(i = 0;i<mesh.faces.length;++i){					f = mesh.faces[i];					index = i*3;					switch(_orientation){						case "front":							if(_selection[index] != null && _selection[index]){								f.uv0.u = (f.v0.x+_offsetW+mesh.scenePosition.x)/_width;								f.uv0.v = 1- (f.v0.y+_offsetH+mesh.scenePosition.y)/_height;							}							index++;							if(_selection[index] != null && _selection[index]){								f.uv1.u = (f.v1.x+_offsetW+mesh.scenePosition.x)/_width;								f.uv1.v = 1-(f.v1.y+_offsetH+mesh.scenePosition.y)/_height;							}							index++;							if(_selection[index] != null && _selection[index]){								f.uv2.u = (f.v2.x+_offsetW+mesh.scenePosition.x)/_width;								f.uv2.v = 1-(f.v2.y+_offsetH+mesh.scenePosition.y)/_height;							}							break;													case "back":							if(_selection[index] != null && _selection[index]){								f.uv0.u = 1-(f.v0.x+_offsetW+mesh.scenePosition.x)/_width;								f.uv0.v = 1- (f.v0.y+_offsetH+mesh.scenePosition.y)/_height;							}							index++;							if(_selection[index] != null && _selection[index]){								f.uv1.u = 1-(f.v1.x+_offsetW+mesh.scenePosition.x)/_width;								f.uv1.v = 1-(f.v1.y+_offsetH+mesh.scenePosition.y)/_height;							}							index++;							if(_selection[index] != null && _selection[index]){								f.uv2.u = 1-(f.v2.x+_offsetW+mesh.scenePosition.x)/_width;								f.uv2.v = 1-(f.v2.y+_offsetH+mesh.scenePosition.y)/_height;							}							break;													case "right":							if(_selection[index] != null && _selection[index]){								f.uv0.u = (f.v0.z+_offsetW+mesh.scenePosition.z)/_width;								f.uv0.v = 1- (f.v0.y+_offsetH+mesh.scenePosition.y)/_height;							}							index++;							if(_selection[index] != null && _selection[index]){								f.uv1.u = (f.v1.z+_offsetW+mesh.scenePosition.z)/_width;								f.uv1.v = 1-(f.v1.y+_offsetH+mesh.scenePosition.y)/_height;							}							index++;							if(_selection[index] != null && _selection[index]){								f.uv2.u = (f.v2.z+_offsetW+mesh.scenePosition.z)/_width;								f.uv2.v = 1-(f.v2.y+_offsetH+mesh.scenePosition.y)/_height;							}							break;													case "left":							if(_selection[index] != null && _selection[index]){								f.uv0.u = 1-(f.v0.z+_offsetW+mesh.scenePosition.z)/_width;								f.uv0.v = 1- (f.v0.y+_offsetH+mesh.scenePosition.y)/_height;							}							index++;							if(_selection[index] != null && _selection[index]){								f.uv1.u = 1-(f.v1.z+_offsetW+mesh.scenePosition.z)/_width;								f.uv1.v = 1-(f.v1.y+_offsetH+mesh.scenePosition.y)/_height;							}							index++;							if(_selection[index] != null && _selection[index]){								f.uv2.u = 1-(f.v2.z+_offsetW+mesh.scenePosition.z)/_width;								f.uv2.v = 1-(f.v2.y+_offsetH+mesh.scenePosition.y)/_height;							}							break;													case "top":							if(_selection[index] != null && _selection[index]){								f.uv0.u = (f.v0.x+_offsetW+mesh.scenePosition.x)/_width;								f.uv0.v = 1- (f.v0.z+_offsetH+mesh.scenePosition.z)/_height;							}							index++;							if(_selection[index] != null && _selection[index]){								f.uv1.u = (f.v1.x+_offsetW+mesh.scenePosition.x)/_width;								f.uv1.v = 1-(f.v1.z+_offsetH+mesh.scenePosition.z)/_height;							}							index++;							if(_selection[index] != null && _selection[index]){								f.uv2.u = (f.v2.x+_offsetW+mesh.scenePosition.x)/_width;								f.uv2.v = 1-(f.v2.z+_offsetH+mesh.scenePosition.z)/_height;							}							break;													case "bottom":							if(_selection[index] != null && _selection[index]){								f.uv0.u = 1- (f.v0.x+_offsetW+mesh.scenePosition.x)/_width;								f.uv0.v = 1- (f.v0.z+_offsetH+mesh.scenePosition.z)/_height;							}							index++;							if(_selection[index] != null && _selection[index]){								f.uv1.u = 1- (f.v1.x+_offsetW+mesh.scenePosition.x)/_width;								f.uv1.v = 1-(f.v1.z+_offsetH+mesh.scenePosition.z)/_height;							}							index++;							if(_selection[index] != null && _selection[index]){								f.uv2.u = 1- (f.v2.x+_offsetW+mesh.scenePosition.x)/_width;								f.uv2.v = 1-(f.v2.z+_offsetH+mesh.scenePosition.z)/_height;							}							break;											}									}									 } else {			   			   			   				for(i = 0;i<mesh.faces.length;++i){					f = mesh.faces[i];					switch(_orientation){						case "front":							f.uv0.u = (f.v0.x+_offsetW+mesh.scenePosition.x)/_width;							f.uv0.v = 1- (f.v0.y+_offsetH+mesh.scenePosition.y)/_height;							f.uv1.u = (f.v1.x+_offsetW+mesh.scenePosition.x)/_width;							f.uv1.v = 1-(f.v1.y+_offsetH+mesh.scenePosition.y)/_height;							f.uv2.u = (f.v2.x+_offsetW+mesh.scenePosition.x)/_width;							f.uv2.v = 1-(f.v2.y+_offsetH+mesh.scenePosition.y)/_height;														break;													case "back":							f.uv0.u = 1-(f.v0.x+_offsetW+mesh.scenePosition.x)/_width;							f.uv0.v = 1- (f.v0.y+_offsetH+mesh.scenePosition.y)/_height;							f.uv1.u = 1-(f.v1.x+_offsetW+mesh.scenePosition.x)/_width;							f.uv1.v = 1-(f.v1.y+_offsetH+mesh.scenePosition.y)/_height;							f.uv2.u = 1-(f.v2.x+_offsetW+mesh.scenePosition.x)/_width;							f.uv2.v = 1-(f.v2.y+_offsetH+mesh.scenePosition.y)/_height;							break;												case "right":							f.uv0.u = (f.v0.z+_offsetW+mesh.scenePosition.z)/_width;							f.uv0.v = 1- (f.v0.y+_offsetH+mesh.scenePosition.y)/_height;							f.uv1.u = (f.v1.z+_offsetW+mesh.scenePosition.z)/_width;							f.uv1.v = 1-(f.v1.y+_offsetH+mesh.scenePosition.y)/_height;							f.uv2.u = (f.v2.z+_offsetW+mesh.scenePosition.z)/_width;							f.uv2.v = 1-(f.v2.y+_offsetH+mesh.scenePosition.y)/_height;							break;													case "left":							f.uv0.u = 1-(f.v0.z+_offsetW+mesh.scenePosition.z)/_width;							f.uv0.v = 1- (f.v0.y+_offsetH+mesh.scenePosition.y)/_height;							f.uv1.u = 1-(f.v1.z+_offsetW+mesh.scenePosition.z)/_width;							f.uv1.v = 1-(f.v1.y+_offsetH+mesh.scenePosition.y)/_height;							f.uv2.u = 1-(f.v2.z+_offsetW+mesh.scenePosition.z)/_width;							f.uv2.v = 1-(f.v2.y+_offsetH+mesh.scenePosition.y)/_height;							break;													case "top":							f.uv0.u = (f.v0.x+_offsetW+mesh.scenePosition.x)/_width;							f.uv0.v = 1- (f.v0.z+_offsetH+mesh.scenePosition.z)/_height;							f.uv1.u = (f.v1.x+_offsetW+mesh.scenePosition.x)/_width;							f.uv1.v = 1-(f.v1.z+_offsetH+mesh.scenePosition.z)/_height;							f.uv2.u = (f.v2.x+_offsetW+mesh.scenePosition.x)/_width;							f.uv2.v = 1-(f.v2.z+_offsetH+mesh.scenePosition.z)/_height;							break;													case "bottom":							f.uv0.u = 1- (f.v0.x+_offsetW+mesh.scenePosition.x)/_width;							f.uv0.v = 1- (f.v0.z+_offsetH+mesh.scenePosition.z)/_height;							f.uv1.u = 1- (f.v1.x+_offsetW+mesh.scenePosition.x)/_width;							f.uv1.v = 1-(f.v1.z+_offsetH+mesh.scenePosition.z)/_height;							f.uv2.u = 1- (f.v2.x+_offsetW+mesh.scenePosition.x)/_width;							f.uv2.v = 1-(f.v2.z+_offsetH+mesh.scenePosition.z)/_height;							break;											}									}							}					}					}}