﻿package away3d.tools{	import away3d.core.base.*;	import away3d.containers.*;	import away3d.materials.*;		import flash.display.*;	import flash.geom.*;		/**	 * Class Mirror an Object3D geometry and its uv's.<code>Mirror</code>	 * 	 */	public class Mirror{				private static var _axes:Array = ["x-", "x+", "x", "y-", "y+", "y", "z-", "z+", "z"];		private static var _mapDir:String;				private static function offsetUVsFace(face:Face):void		{			var uv:UV;			if(_mapDir == "v"){				face.uv0 = new UV(face.uv0.u, face.uv0.v *.5);				face.uv1 = new UV(face.uv1.u, face.uv1.v *.5);				face.uv2 = new UV(face.uv2.u, face.uv2.v *.5);			} else {				face.uv0 = new UV(face.uv0.u *.5, face.uv0.v);				face.uv1 = new UV(face.uv1.u *.5, face.uv1.v);				face.uv2 = new UV(face.uv2.u *.5, face.uv2.v);			}		}				private static function resizeMap( map:BitmapData):BitmapData		{			var bmd:BitmapData;			var destpoint:Point = new Point(0,0);			if(map.width> map.height){				_mapDir = "v";				bmd = new BitmapData(map.width, map.height*2, map.transparent, (map.transparent)?0x00FFFFFF: 0);				bmd.copyPixels(map, map.rect, destpoint);				destpoint.y = map.height;				trace("doing y now");				bmd.copyPixels(map, map.rect, destpoint);			} else {				_mapDir = "u";				bmd = new BitmapData(map.width*2, map.height, map.transparent, (map.transparent)?0x00FFFFFF: 0);				bmd.copyPixels(map, map.rect, destpoint);				destpoint.x = map.width;				bmd.copyPixels(map, map.rect, destpoint);			}			destpoint = null;						return bmd;		}			private static function validate( axe:String):Boolean		{			for(var i:int =0;i<Mirror._axes.length;++i)				if(axe == Mirror._axes[i]) return true;							return false;		}				private static function checkInvalid( v:Vertex):Vertex		{			v = (v == null)? new Vertex(0,0,0) : v;						v.x = (isNaN(v.x))? 0 : v.x;			v.y = (isNaN(v.y))? 0 : v.y;			v.z = (isNaN(v.z))? 0 : v.z;										return v;		}		private static function build(object3d:Object3D, axe:String, recenter:Boolean, duplicate:Boolean = true, keepUniqueMapping = false, doubleMap:Boolean = false):void		{				var obj:Mesh = (object3d as Mesh);				var aFaces:Array = obj.faces;				var face:Face;				var i:int;				var va: Vertex;				var vb: Vertex;				var vc :Vertex;				var mat:Material;				var v0: Vertex;				var v1: Vertex;				var v2 :Vertex;				var posi:Vector3D = object3d.position;				var facecount:int = aFaces.length;				var offset:Number;								switch(axe){											case "x":							offset = posi.x;						break;						case "x-":							offset = Math.abs(object3d.minX)+object3d.maxX;						break;						case "x+":							offset = Math.abs(object3d.minX)+object3d.maxX;						break;												case "y":							offset = posi.y;						break;						case "y-":							offset = Math.abs(object3d.minY)+object3d.maxY;						break;						case "y+":							offset = Math.abs(object3d.minY)+object3d.maxY;						break;												case "z":							offset = posi.z;						break;						case "z-":							offset = Math.abs(object3d.minZ)+object3d.maxZ;						break;						case "z+":							offset = Math.abs(object3d.minZ)+object3d.maxZ;											}								if(isNaN(offset)){					trace("--> invalid object bounderies");					return;				}								var doMapping:Boolean;				if(keepUniqueMapping && duplicate){					if(doubleMap && obj.material != null && (obj.material as BitmapMaterial).bitmap != null){						(obj.material as BitmapMaterial).bitmap = resizeMap((obj.material as BitmapMaterial).bitmap);					}					var nuv0:UV;					var nuv1:UV;					var nuv2:UV;					doMapping = true;				}				for(i=0;i<facecount;++i){					 					if(doMapping)						Mirror.offsetUVsFace(aFaces[i]);										face = aFaces[i];					mat = face.material;												va = Mirror.checkInvalid(face.v0);					vb = Mirror.checkInvalid(face.v1);					vc = Mirror.checkInvalid(face.v2);					 					if(duplicate){						 						switch(axe){														case "x":								v0 = new Vertex( -va.x -(offset*2), va.y, va.z);								v1 = new Vertex( -vb.x -(offset*2), vb.y, vb.z);								v2 = new Vertex( -vc.x -(offset*2), vc.y, vc.z);								break;														case "x-":								v0 = new Vertex(-va.x - offset, va.y, va.z);								v1 = new Vertex(-vb.x - offset, vb.y, vb.z);								v2 = new Vertex(-vc.x - offset, vc.y, vc.z); 								break;														case "x+":								v0 = new Vertex(-va.x + offset, va.y, va.z);								v1 = new Vertex(-vb.x + offset, vb.y, vb.z);								v2 = new Vertex(-vc.x + offset, vc.y, vc.z);								break;							//							case "y":								v0 = new Vertex(va.x , -va.y -(offset*2), va.z);								v1 = new Vertex(vb.x , -vb.y -(offset*2), vb.z);								v2 = new Vertex(vc.x , -vc.y -(offset*2), vc.z);								break;														case "y-":								v0 = new Vertex(va.x , -va.y - offset, va.z);								v1 = new Vertex(vb.x, -vb.y - offset, vb.z);								v2 = new Vertex(vc.x, -vc.y - offset, vc.z); 								break;														case "y+":								v0 = new Vertex(va.x, -va.y+ offset, va.z);								v1 = new Vertex(vb.x, -vb.y+ offset, vb.z);								v2 = new Vertex(vc.x, -vc.y+ offset, vc.z);								break;							//							case "z":								v0 = new Vertex(va.x , va.y, -va.z -(offset*2));								v1 = new Vertex(vb.x , vb.y, -vb.z -(offset*2));								v2 = new Vertex(vc.x , vc.y, -vc.z -(offset*2));								break;														case "z-":								v0 = new Vertex(va.x, va.y, -va.z - offset);								v1 = new Vertex(vb.x, vb.y, -vb.z - offset);								v2 = new Vertex(vc.x, vc.y, -vc.z - offset); 								break;														case "z+":								v0 = new Vertex(va.x, va.y, -va.z+ offset);								v1 = new Vertex(vb.x, vb.y, -vb.z+ offset);								v2 = new Vertex(vc.x, vc.y, -vc.z + offset);							}					  							if(doMapping){							if(_mapDir == "v"){								nuv0 = new UV(face.uv0.u, face.uv0.v+.5);								nuv1 = new UV(face.uv1.u, face.uv1.v+.5);								nuv2 = new UV(face.uv2.u, face.uv2.v+.5);							} else{								nuv0 = new UV(face.uv0.u+.5, face.uv0.v);								nuv1 = new UV(face.uv1.u+.5, face.uv1.v);								nuv2 = new UV(face.uv2.u+.5, face.uv2.v);							}														obj.addFace(new Face(v1, v0, v2, mat, nuv1, nuv0, nuv2 ) );						} else{							obj.addFace(new Face(v1, v0, v2, mat, face.uv1, face.uv0, face.uv2 ) );						}										} else {												switch(axe){															case "x":								obj.updateVertex(face.v0, -va.x -(offset*2), va.y, va.z, true);								obj.updateVertex(face.v1, -vb.x -(offset*2), vb.y, vb.z, true);								obj.updateVertex(face.v2, -vc.x -(offset*2), vc.y, vc.z, true); 								break;														case "x-":								obj.updateVertex(face.v0, -va.x - offset, va.y, va.z, true);								obj.updateVertex(face.v1, -vb.x - offset, vb.y, vb.z, true);								obj.updateVertex(face.v2, -vc.x - offset, vc.y, vc.z, true); 								break;														case "x+":								obj.updateVertex(face.v0,-va.x + offset, va.y, va.z, true);								obj.updateVertex(face.v1, -vb.x + offset, vb.y, vb.z, true);								obj.updateVertex(face.v2, -vc.x + offset, vc.y, vc.z, true);								break;							//							case "y":								obj.updateVertex(face.v0, va.x , -va.y -(offset*2), va.z, true);								obj.updateVertex(face.v1, vb.x , -vb.y -(offset*2), vb.z, true);								obj.updateVertex(face.v2, vc.x , -vc.y -(offset*2), vc.z, true);								break;														case "y-":								obj.updateVertex(face.v0, va.x , -va.y - offset, va.z, true);								obj.updateVertex(face.v1, vb.x, -vb.y - offset, vb.z, true);								obj.updateVertex(face.v2, vc.x, -vc.y - offset, vc.z, true);								break;														case "y+":								obj.updateVertex(face.v0, va.x, -va.y+ offset, va.z, true);								obj.updateVertex(face.v1, vb.x, -vb.y+ offset, vb.z, true);								obj.updateVertex(face.v2, vc.x, -vc.y+ offset, vc.z, true);								break;							//							case "z":								obj.updateVertex(face.v0, va.x , va.y, -va.z -(offset*2), true);								obj.updateVertex(face.v1, vb.x , vb.y, -vb.z -(offset*2), true);								obj.updateVertex(face.v2, vc.x , vc.y, -vc.z -(offset*2), true);								break;														case "z-":								obj.updateVertex(face.v0, va.x, va.y, -va.z - offset, true);								obj.updateVertex(face.v1, vb.x, vb.y, -vb.z - offset, true);								obj.updateVertex(face.v2, vc.x, vc.y, -vc.z - offset, true);								break;														case "z+":								obj.updateVertex(face.v0, va.x, va.y, -va.z+ offset, true);								obj.updateVertex(face.v1, vb.x, vb.y, -vb.z+ offset, true);								obj.updateVertex(face.v2, vc.x, vc.y, -vc.z + offset, true);						}					}				}								if(recenter){					obj.updateBounds();					obj.applyPosition((obj.minX+obj.maxX)*.5, (obj.minY+obj.maxY)*.5, (obj.minZ+obj.maxZ)*.5);				}		}		 		/**		* Mirrors an Object3D Mesh object geometry and uv's		* 		* @param	 object3d		The Object3D, ObjectContainer3D are parsed recurvely as well.		* @param	 axe		A string "x-", "x+", "x", "y-", "y+", "y", "z-", "z+", "z". "x", "y","z" mirrors on world position 0,0,0, the + mirrors geometry in positive direction, the - mirrors geometry in positive direction.		* @param	 recenter	[optional]	Recenter the Object3D pivot. This doesn't affect ObjectContainers3D's. Default is true.		* @param	 duplicate	[optional]	Duplicate model geometry along the axe or set to false mirror but do not duplicate. Default is true.		* Note that if duplicate is set to false, the mesh vertices must be unique. See tools.Explode class. If not Mirroring can be applied multiple times to same Vertex object.		* @param	 keepUniqueMapping	[optional]	If duplicate is true, ensure that that new geoemtry gets unique uv's. original and duplicate geometry will take respectively .5 of the map. Default = false.		* @param	 doubleMap  If both duplicate and keepUniqueMapping are true and the mesh passed has a material of type BitmapMaterial. map ios doubled in size to keep ratio 1/1 for the resulting mesh. Default = false.		* When doubleMap is applied, original map is not disposed, but the new map is applied to mesh material. Access bitmapMaterial.bitmap after to mirroring to retreive the new map. 		*/		public static function apply(object3d:Object3D, axe:String, recenter:Boolean = true, duplicate:Boolean = true, keepUniqueMapping:Boolean = false, doubleMap:Boolean = false):void		{			axe = axe.toLowerCase();			 			if(Mirror.validate(axe)){								if(object3d is ObjectContainer3D){										var obj:ObjectContainer3D = (object3d as ObjectContainer3D);										for(var i:int =0;i<obj.children.length;++i){						 						if(obj.children[i] is ObjectContainer3D){							Mirror.apply(obj.children[i], axe, recenter, duplicate, keepUniqueMapping, doubleMap);						} else{							Mirror.build( obj.children[i], axe, recenter, duplicate, keepUniqueMapping, doubleMap);						}					}									}else{					Mirror.build( object3d, axe, recenter, duplicate, keepUniqueMapping, doubleMap);				}			 			} else{				trace("Mirror error: unvalid axe string:"+Mirror._axes.toString());			}		}			}}