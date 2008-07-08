﻿package away3d.extrusions{   	import flash.display.BitmapData;	public class ElevationReader {				private var channel:String;		private var levelBmd:BitmapData;		private var elevate:Number;		private var scalingX:Number;		private var scalingY:Number;		private var buffer:Array;		private var level:Number;		private var offsetX:Number = 0;		private var offsetY:Number = 0;		private var smoothness:int;		/**		* Class generates a traced representation of the elevation geometry, allowing surface tracking to place or move objects on the elevation geometry.  <ElevationReader ></code>		* 		*/		public function ElevationReader(smoothness:int = 0)        {			buildBuffer(smoothness);		}		private function buildBuffer(smoothness:int = 0):void		{			this.smoothness = smoothness;			buffer = [];			for(var i:int = 0;i<smoothness;i++){				buffer.push(0);			}			level = 0;		}				private function setSource(sourceBmd:BitmapData, channelsource:String = "r", factorX:Number = 1, factorY:Number = 1, factorZ:Number = .5):void        {			levelBmd = sourceBmd.clone();			channel = channelsource;			scalingX = factorX;			scalingY = factorY;			elevate = factorZ;		}		/**		 * returns the generated bitmapdata, a smooth representation of the geometry.		 */		public function get source():BitmapData        {			return levelBmd;		}		/**		 * returns the generated bitmapdata, a smooth representation of the geometry.		 * 		 * @param	x				The x coordinate on the generated bitmapdata.		 * @param	y				The y coordinate on the generated bitmapdata.		 * @param	offset			[optional]	the offset that will be added to the elevation value at the x and y coordinates plus the offset. Default = 0. 		 *		 * @return 	A Number, the elevation value at the x and y coordinates plus the offset.		 */				public function getLevel(x:Number, y:Number, offset:Number = 0):Number        {			var col:Number = x/scalingX;			var row:Number = y/scalingY; 			col += (levelBmd.width*.5)+offsetX;			row += (levelBmd.height*.5)+offsetY;			var color:Number = levelBmd.getPixel(col, row);						var r:Number = color >> 16 & 0xFF;						if(smoothness == 0) return (r*elevate)+offset;						buffer.push((r*elevate)+offset);			buffer.shift();						level = 0;			for(var i:int = 0;i<buffer.length;i++){				level += buffer[i];			}						return level/buffer.length;		}				/**		 * generates the smooth representation of the geometry. uses same parameters as the Elevation class.		 * 		* @param	sourceBmd				Bitmapdata. The bitmapData to read from.		* @param	channel					[optional] String. The channel information to read. supported "a", alpha, "r", red, "g", green, "b", blue and "av" (averages and luminance). Default is red channel "r".		* @param	subdivisionX			[optional] int. The subdivision to read the pixels along the x axis. Default is 10.		* @param	subdivisionY			[optional] int. The subdivision to read the pixels along the y axis. Default is 10.		* @param	scalingX					[optional] Number. The scale multiplier along the x axis. Default is 1.		* @param	scalingY					[optional] Number. The scale multiplier along the y axis. Default is 1.		* @param	elevate					[optional] Number. The scale multiplier along the z axis. Default is .5.		* 		* @see away3d.extrusions.Elevation		*/				public function traceLevels(sourceBmd:BitmapData, channel:String = "r", subdivisionX:int = 10, subdivisionY:int = 10, factorX:Number = 1, factorY:Number = 1, elevate:Number = .5):void		{			setSource(sourceBmd, channel, factorX, factorY, elevate);			 			var w:Number = sourceBmd.width;			var h:Number = sourceBmd.height;			var i:int = 0;			var j:int = 0;			var k:int = 0;			var l:int = 0;						var px1:Number; 			var px2:Number;			var px3:Number;			var px4:Number;						var lockx:int;			var locky:int;			levelBmd.lock();						var incXL:Number;			var incXR:Number;			var incYL:Number;			var incYR:Number;			var pxx:Number;			var pxy:Number;						for(i = 0; i < w+1; i+=subdivisionX)			{								if(i+subdivisionX > w)				{					offsetX = (w-i)*.5;					lockx = w;				} else {					lockx = i+subdivisionX;				}				for(j = 0; j < h+1; j+=subdivisionY)				{					if(j+subdivisionY > h)					{						offsetY = (h-j)*.5;						locky = h;					} else {						locky = j+subdivisionY;					}					 					if(j == 0){						switch(channel){							case "a":								px1 = sourceBmd.getPixel32(i, j) >> 24 & 0xFF;								px2 = sourceBmd.getPixel32(lockx, j) >> 24 & 0xFF;								px3 = sourceBmd.getPixel32(lockx, locky) >> 24 & 0xFF;								px4 = sourceBmd.getPixel32(i, locky) >> 24 & 0xFF;								break;							case "r":								px1 = sourceBmd.getPixel(i, j) >> 16 & 0xFF;								px2 = sourceBmd.getPixel(lockx, j) >> 16 & 0xFF;								px3 = sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF;								px4 = sourceBmd.getPixel(i, locky) >> 16 & 0xFF;								break;							case "g":								px1 = sourceBmd.getPixel(i, j) >> 8 & 0xFF;								px2 = sourceBmd.getPixel(lockx, j) >> 8 & 0xFF;								px3 = sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF;								px4 = sourceBmd.getPixel(i, locky) >> 8 & 0xFF;								break;							case "b":								px1 = sourceBmd.getPixel(i, j) & 0xFF;								px2 = sourceBmd.getPixel(lockx, j) & 0xFF;								px3 = sourceBmd.getPixel(lockx, locky) & 0xFF;								px4 = sourceBmd.getPixel(i, locky) & 0xFF;								break;							case "av":								px1 = ((sourceBmd.getPixel(i, j) >> 16 & 0xFF)*0.212671) + ((sourceBmd.getPixel(i, j) >> 8 & 0xFF)*0.715160) + ((sourceBmd.getPixel(i, j) & 0xFF)*0.072169);								px2 = ((sourceBmd.getPixel(lockx, j) >> 16 & 0xFF)*0.212671) + ((sourceBmd.getPixel(lockx, j) >> 8 & 0xFF)*0.715160) + ((sourceBmd.getPixel(lockx, j) & 0xFF)*0.072169);								px3 = ((sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF)*0.212671) + ((sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF)*0.715160) + ((sourceBmd.getPixel(lockx, locky) & 0xFF)*0.072169);								px4 = ((sourceBmd.getPixel(i, locky) >> 16 & 0xFF)*0.212671) + ((sourceBmd.getPixel(i, locky) >> 8 & 0xFF)*0.715160) + ((sourceBmd.getPixel(i, locky) & 0xFF)*0.072169);						}						 					} else {												px1 = px4;						px2 = px3;						switch(channel){							case "a":								px3 = sourceBmd.getPixel32(lockx, locky) >> 24 & 0xFF;								px4 = sourceBmd.getPixel32(i, locky) >> 24 & 0xFF;								break;							case "r":								px3 = sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF;								px4 = sourceBmd.getPixel(i, locky) >> 16 & 0xFF;								break;							case "g":								px3 = sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF;								px4 = sourceBmd.getPixel(i, locky) >> 8 & 0xFF;								break;							case "b":								px3 = sourceBmd.getPixel(lockx, locky) & 0xFF;								px4 = sourceBmd.getPixel(i, locky) & 0xFF;								break;							case "av":								px3 = ((sourceBmd.getPixel(lockx, locky) >> 16 & 0xFF)*0.212671) + ((sourceBmd.getPixel(lockx, locky) >> 8 & 0xFF)*0.715160) + ((sourceBmd.getPixel(lockx, locky) & 0xFF)*0.072169);								px4 = ((sourceBmd.getPixel(i, locky) >> 16 & 0xFF)*0.212671) + ((sourceBmd.getPixel(i, locky) >> 8 & 0xFF)*0.715160) + ((sourceBmd.getPixel(i, locky) & 0xFF)*0.072169);						}											}										for(k = 0; k < subdivisionX; k++)					{						incXL = 1/subdivisionX * k;						incXR = 1-incXL;												for(l = 0; l < subdivisionY; l++)						{							incYL = 1/subdivisionY * l;							incYR = 1-incYL;							pxx = ((px1*incXR) + (px2*incXL))*incYR;							pxy = ((px4*incXR) + (px3*incXL))*incYL;							 							levelBmd.setPixel(k+i, l+j, pxy+pxx << 16 );						 }						 					}				}				 			}						levelBmd.unlock();		}			}}