﻿package away3d.core.material{    import away3d.core.*;    import away3d.core.math.*;    import away3d.core.proto.*;    import away3d.core.draw.*;    import away3d.core.render.*;    import flash.display.*;    import flash.geom.*;	import away3d.core.material.*;	     public class TraceBitmapMaterial implements ITriangleMaterial, IUVMaterial    {        public var source_bmd:BitmapData;		public var dest_bmd:BitmapData;		private var cleaner:Object;		private var oLight:Object;		public var aFX:Array;		public var fxbitmap:BitmapData;                public function get width():Number        {            return this.source_bmd.width;        }        public function get height():Number        {            return this.source_bmd.height;        }				public function clear():void        {            this.cleaner.clear();        }                public function TraceBitmapMaterial(source_bmd:BitmapData, dest_bmd:BitmapData, init:Object = null, )        {            this.source_bmd = source_bmd;			this.dest_bmd = dest_bmd;			this.oLight = new Object();			this.oLight.light = (!init.light)? "" : init.light;			this.oLight.offsetX = (!init.offsetX)? 0 : init.offsetX;			this.oLight.offsetY = (!init.offsetY)? 0 : init.offsetY;			this.oLight.debug = init.debug;			this.oLight.lightcolor = 0xFFFFFFFF;			this.cleaner = new BitmapCleaner(this.dest_bmd, 0x00);			if(afx != null){				this.rect = new Rectangle(0,0,1,1);				this.aFX = new Array();				this.aFX = afx.concat();			}        }        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void        {			var smooth:Boolean;			if(!tri.texturemapping){  			  tri.transformUV(this);			}						/*			// until we do not have a change event we calculate each time the normal of the face			if(tri.normal == null){			 	tri.normal = AmbientLight.getNormal([tri.v0, tri.v1, tri.v2]);			}			*/						var ct:ColorTransform;						if(oLight.light != ""){				 				if(oLight.light == "flat"){					try{ 						oLight.lightcolor = AmbientLight.getPolygonColor([tri.v0, tri.v1, tri.v2], AmbientLight.lightcolor, tri.normal);						var ambient:Number = AmbientLight.ambientvalue; 						var r:Number = -255 + ((oLight.lightcolor >> 16 & 0xFF)*2)+ambient;						var g:Number = -255 + ((oLight.lightcolor >> 8 & 0xFF)*2)+ambient;						var b:Number = -255 + ((oLight.lightcolor & 0xFF)*2)+ambient;												ct = new ColorTransform(1,1,1,1,r,g,b,1);											} catch(er:Error){						trace("bitmap Flat color error: "+er.message);					}				}				//not implemented yet				// needed for gourauld and phong shading				/*				if(oLight.light == "smooth"){										try{						// first we need the average normal for this face, then loop over all faces sharing same points						// in order to calculate 3 colors per faces 												var xn:Number=(tri.v2.y-tri.v0.y)*(tri.v1.z-tri.v0.z)-(tri.v2.z-tri.v0.z)*(tri.v1.y-tri.v0.y);						var yn:Number=(tri.v2.z-tri.v0.z)*(tri.v1.x-tri.v0.x)-(tri.v2.x-tri.v0.x)*(tri.v1.z-tri.v0.z);						var zn:Number=(tri.v2.x-tri.v0.x)*(tri.v1.y-tri.v0.y)-(tri.v2.y-tri.v0.y)*(tri.v1.x-tri.v0.x);												var l:Number = 1.0/Math.sqrt(xn*xn+yn*yn+zn*zn);						xn *= l;						yn *= l;						zn *= l;																		 						var oAverages:Object = AmbientLight.averageNormal([tri.v0, tri.v1, tri.v2]);						//--> needs to be saved						 						smooth = true;											} catch(er:Error){						trace("bitmap smooth color error: "+er.message);					}				}				*/			} 			 			var x0 = tri.v0.x+this.oLight.offsetX;			var y0 = tri.v0.y+this.oLight.offsetY;			var x1 = tri.v1.x+this.oLight.offsetX;			var y1 = tri.v1.y+this.oLight.offsetY;			var x2 = tri.v2.x+this.oLight.offsetX;			var y2 = tri.v2.y+this.oLight.offsetY;						var a2:Number = x1 - x0;            var b2:Number = y1 - y0;            var c2:Number = x2 - x0;            var d2:Number = y2 - y0;           	var matrix:Matrix = new Matrix(tri.texturemapping.a*a2 + tri.texturemapping.b*c2,                                            tri.texturemapping.a*b2 + tri.texturemapping.b*d2,                                            tri.texturemapping.c*a2 + tri.texturemapping.d*c2,                                            tri.texturemapping.c*b2 + tri.texturemapping.d*d2,                                           tri.texturemapping.tx*a2 + tri.texturemapping.ty*c2 + x0 ,                                           tri.texturemapping.tx*b2 + tri.texturemapping.ty*d2 + y0 );						if(smooth){				// not builded in yet... far to heavy				//BitmapGraphics.renderBitmapTriangleSmooth(this.dest_bmd, this.source_bmd, x0, y0, x1, y1, x2, y2, matrix, oLight.aLightcolors[0], oLight.aLightcolors[1], oLight.aLightcolors[2], this.cleaner.update(x0, y0, x1, y1, x2, y2));			}else{				BitmapGraphics.renderBitmapTriangle(this.dest_bmd, this.source_bmd, x0, y0, x1, y1, x2, y2, matrix, ct, this.cleaner.update(x0, y0, x1, y1, x2, y2));			}						 if (this.oLight.debug){				 BitmapGraphics.drawLine(this.dest_bmd,x0, y0, x1, y1, 0xffff0000);				 BitmapGraphics.drawLine(this.dest_bmd, x1, y1, x2, y2, 0xff00ff00);				 BitmapGraphics.drawLine(this.dest_bmd, x2, y2, x0, y0, 0xff0000ff);							 }			        }        public function get visible():Boolean        {            return true;        }     }}