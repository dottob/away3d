package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.mesh.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    
    import flash.display.BitmapData;
    import flash.display.Graphics;
    import flash.geom.Matrix;
    import flash.geom.Point;

    /** Scaled bitmap primitive */
    public class DrawScaledBitmap extends DrawPrimitive
    {
        public var bitmap:BitmapData;

        public var v:ScreenVertex;

        public var scale:Number;
        public var rotation:Number;
        public var topleft:ScreenVertex = new ScreenVertex();
        public var topright:ScreenVertex = new ScreenVertex();
        public var bottomleft:ScreenVertex = new ScreenVertex();
        public var bottomright:ScreenVertex = new ScreenVertex();
        public var left:ScreenVertex = new ScreenVertex();
        public var top:ScreenVertex = new ScreenVertex();
        public var width:Number;
        public var height:Number;

        public var smooth:Boolean;
        
        private var cos:Number;
        private var sin:Number;
        
        private var cosw:Number;
        private var cosh:Number;
		private var sinw:Number;
        private var sinh:Number;
        private var bounds:ScreenVertex;
        
        public function DrawScaledBitmap(object:Object3D, bitmap:BitmapData, v:ScreenVertex, scale:Number, rotation:Number, smooth:Boolean)
        {
            this.source = object;
            this.bitmap = bitmap;
            this.v = v;
            this.scale = scale;
            this.rotation = rotation;
            this.smooth = smooth;
            calc();
        }

        public function calc():void
        {
            screenZ = v.z;
            minZ = screenZ;
            maxZ = screenZ;
            width = bitmap.width*scale;
            height = bitmap.height*scale;
            
            cos = Math.cos(rotation*Math.PI/180);
            sin = Math.sin(rotation*Math.PI/180);
            
            cosw = cos*width/2;
            cosh = cos*height/2;
            sinw = sin*width/2;
            sinh = sin*height/2;
            
            topleft.x = v.x - cosw - sinh;
            topleft.y = v.y + sinw - cosh;
            topright.x = v.x + cosw - sinh;
            topright.y = v.y - sinw - cosh;
            bottomleft.x = v.x - cosw + sinh;
            bottomleft.y = v.y + sinw + cosh;
            bottomright.x = v.x + cosw + sinh;
            bottomright.y = v.y - sinw + cosh;
            
            if (rotation != 0) {
	            var boundsArray:Array = new Array();
	            boundsArray.push(topleft);
	            boundsArray.push(topright);
	            boundsArray.push(bottomleft);
	            boundsArray.push(bottomright);
	            minX = 100000;
	            minY = 100000;
	            maxX = -100000;
	            maxY = -100000;
	            
	            for each (bounds in boundsArray) {
	            	if (minX > bounds.x)
	            		minX = bounds.x;
	            	if (maxX < bounds.x)
	            		maxX = bounds.x;
	            	if (minY > bounds.y)
	            		minY = bounds.y;
	            	if (maxY < bounds.y)
	            		maxY = bounds.y;
	            }
            } else {
            	minX = topleft.x;
            	minY = topleft.y;
            	maxX = bottomright.x;
            	maxY = bottomright.y;
            }
        }

        public override function clear():void
        {
            bitmap = null;
        }
		
		private var mapping:Matrix;
		
        public override function render():void
        {
            mapping = new Matrix(scale*cos, -scale*sin, scale*sin, scale*cos, topleft.x, topleft.y);
            var graphics:Graphics = source.session.graphics;
            graphics.lineStyle();
            if (rotation != 0) {
	            graphics.beginBitmapFill(bitmap, mapping, false, smooth);
	            graphics.moveTo(topleft.x, topleft.y);
	            graphics.lineTo(topright.x, topright.y);
	            graphics.lineTo(bottomright.x, bottomright.y);
	            graphics.lineTo(bottomleft.x, bottomleft.y);
	            graphics.lineTo(topleft.x, topleft.y);
	            graphics.endFill();
            } else {
	            graphics.beginBitmapFill(bitmap, mapping, false, smooth);
	            graphics.drawRect(minX, minY, maxX-minX, maxY-minY);
            }
        }

        public override function contains(x:Number, y:Number):Boolean
        {
            if (rotation != 0) {
	            if (topleft.x*(y - topright.y) + topright.x*(topleft.y - y) + x*(topright.y - topleft.y) > 0.001)
	                return false;
	            
	            if (topright.x*(y - bottomright.y) + bottomright.x*(topright.y - y) + x*(bottomright.y - topright.y) > 0.001)
	                return false;
	            
	            if (bottomright.x*(y - bottomleft.y) + bottomleft.x*(bottomright.y - y) + x*(bottomleft.y - bottomright.y) > 0.001)
	                return false;
	            
	            if (bottomleft.x*(y - topleft.y) + topleft.x*(bottomleft.y - y) + x*(topleft.y - bottomleft.y) > 0.001)
	                return false;
            }
            
            if (!bitmap.transparent)
                return true;
            
            mapping = new Matrix(scale*cos, -scale*sin, scale*sin, scale*cos, topleft.x, topleft.y);
            mapping.invert();
            var p:Point = mapping.transformPoint(new Point(x, y));
            if (p.x < 0)
                p.x = 0;
            if (p.y < 0)
                p.y = 0;
            if (p.x >= bitmap.width)
                p.x = bitmap.width-1;
            if (p.y >= bitmap.height)
                p.y = bitmap.height-1;
			
            var pixelValue:uint = bitmap.getPixel32(int(p.x), int(p.y));
            return uint(pixelValue >> 24) > 0x80;
        }
    }
}
