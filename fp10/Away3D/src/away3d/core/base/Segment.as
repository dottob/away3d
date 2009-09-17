package away3d.core.base
{
    import away3d.arcane;
    import away3d.core.math.Number3D;
    import away3d.core.utils.*;
    import away3d.events.*;
    import away3d.materials.*;
    
    import flash.events.Event;

    use namespace arcane;
    
	 /**
	 * Dispatched when the material of the segment changes.
	 * 
	 * @eventType away3d.events.FaceEvent
	 */
	[Event(name="materialchanged",type="away3d.events.FaceEvent")]
	
    /**
    * A line element used in the wiremesh and mesh object
    * 
    * @see away3d.core.base.WireMesh
    * @see away3d.core.base.Mesh
    */
    public class Segment extends Element
    {
		/** @private */
        arcane var _v0:Vertex;
		/** @private */
        arcane var _v1:Vertex;
		/** @private */
        arcane var _material:ISegmentMaterial;
        
        private function onVertexValueChange(event:Event):void
        {
            notifyVertexValueChange();
        }
		
  		private function addVertexAt(index:uint, vertex:Vertex, command:String):void
  		{
  			if(_vertices[index] && _vertices[index] == vertex)
  				return;
  			
  			if (_vertices[index]) {
	  			_index = _vertices[index].parents.indexOf(this);
	  				if(_index != -1)
	  					_vertices[index].parents.splice(_index, 1);
	  		}
	  		
  			_commands[index] = segmentVO.commands[index] = command;
  			_vertices[index] = segmentVO.vertices[index] = vertex;
  			
  			if(index == 0)
  				_v0 = segmentVO.v0 = vertex;
  			else if(index == 1)
  				_v1 = segmentVO.v1 = vertex;
  			
  			vertex.parents.push(this);
  			
  			vertexDirty = true;
  		}
  		
  		public function moveTo(x:Number, y:Number, z:Number):void
  		{
  			var newVertex:Vertex = new Vertex(x, y, z);
  			addVertexAt(_vertices.length, newVertex, DrawingCommand.MOVE);
  			
  			_drawingCommands.push(new DrawingCommand(DrawingCommand.MOVE, _lastAddedVertex, null, newVertex));
  			_lastAddedVertex = newVertex;
  		}
  		
  		public function lineTo(x:Number, y:Number, z:Number):void
  		{
  			var newVertex:Vertex = new Vertex(x, y, z);
  			addVertexAt(_vertices.length, newVertex, DrawingCommand.LINE);
  			
  			_drawingCommands.push(new DrawingCommand(DrawingCommand.LINE, _lastAddedVertex, null, newVertex));
  			_lastAddedVertex = newVertex;
  		}
  		
  		public function curveTo(cx:Number, cy:Number, cz:Number, ex:Number, ey:Number, ez:Number):void
  		{
  			var newControlVertex:Vertex = new Vertex(cx, cy, cz);
  			var newEndVertex:Vertex = new Vertex(ex, ey, ez);
  			addVertexAt(_vertices.length, newControlVertex, DrawingCommand.CURVE);
  			addVertexAt(_vertices.length, newEndVertex, "P");
  			
  			_drawingCommands.push(new DrawingCommand(DrawingCommand.CURVE, _lastAddedVertex, newControlVertex, newEndVertex));
  			_lastAddedVertex = newEndVertex;
  		}
  		
  		public function continuousCurve(points:Array, closed:Boolean = false):void
  		{
  			// Find the mid points and inject them into the array.
  			var processedPoints:Array = [];
  			for(var i:uint; i<points.length-1; i++)
  			{
  				var currentPoint:Number3D = points[i];
  				var nextPoint:Number3D = points[i+1];
  				
  				var X:Number = (currentPoint.x + nextPoint.x)/2;
  				var Y:Number = (currentPoint.y + nextPoint.y)/2;
  				var Z:Number = (currentPoint.z + nextPoint.z)/2;
  				var midPoint:Number3D = new Number3D(X, Y, Z);
  				
  				processedPoints.push(currentPoint);
  				processedPoints.push(midPoint);
  			}
  			
  			if(closed)
  			{
	  			currentPoint = points[points.length-1];
	  			nextPoint = points[0];
	  			X = (currentPoint.x + nextPoint.x)/2;
  				Y = (currentPoint.y + nextPoint.y)/2;
  				Z = (currentPoint.z + nextPoint.z)/2;
  				midPoint = new Number3D(X, Y, Z);
  				processedPoints.push(midPoint);
	  		}
  			
  			// Join the points.
  			currentPoint = processedPoints[0];
  			moveTo(currentPoint.x, currentPoint.y, currentPoint.z);
  			for(i = 1; i<processedPoints.length-2; i += 2)
  			{
  				currentPoint = processedPoints[i];
  				var controlPoint:Number3D = processedPoints[i+1];
  				nextPoint = processedPoints[i+2];
  				curveTo(controlPoint.x, controlPoint.y, controlPoint.z, nextPoint.x, nextPoint.y, nextPoint.z);
  			}
  			
  			if(closed)
  			{
	  			var last:uint = processedPoints.length-1;
	  			curveTo(processedPoints[last].x, processedPoints[last].y, processedPoints[last].z,			
	  								processedPoints[1].x, processedPoints[1].y, processedPoints[1].z);
	  		}
  		}
  		
		public var segmentVO:SegmentVO = new SegmentVO();
		
		/**
		 * Returns an array of vertex objects that are used by the segment.
		 */
        public override function get vertices():Array
        {
            return _vertices;
        }
		        
		/**
		 * Returns an array of drawing command strings that are used by the segment.
		 */
        public override function get commands():Array
        {
            return _commands;
        }
        
        /**
		 * Returns an array of drawing command objects that are used by the face.
		 */
        public override function get drawingCommands():Array
        {
            return _drawingCommands;
        }
        
		/**
		 * Defines the v0 vertex of the segment.
		 */
        public function get v0():Vertex
        {
            return _v0;
        }

        public function set v0(value:Vertex):void
        {
            addVertexAt(0, value, "M");
        }
		
		/**
		 * Defines the v1 vertex of the segment.
		 */
        public function get v1():Vertex
        {
            return _v1;
        }

        public function set v1(value:Vertex):void
        {
            addVertexAt(1, value, "L");
        }
		
		/**
		 * Defines the material of the segment.
		 */
        public function get material():ISegmentMaterial
        {
            return _material;
        }

        public function set material(value:ISegmentMaterial):void
        {
            if (value == _material)
                return;
            
			if (_material != null && parent)
				parent.removeMaterial(this, _material);
			
            _material = segmentVO.material = value;
			
			if (_material != null && parent)
				parent.addMaterial(this, _material);
        }
		
		/**
		 * Returns the squared bounding radius of the segment.
		 */
        public override function get radius2():Number
        {
            var rv0:Number = _v0._x*_v0._x + _v0._y*_v0._y + _v0._z*_v0._z;
            var rv1:Number = _v1._x*_v1._x + _v1._y*_v1._y + _v1._z*_v1._z;

            if (rv0 > rv1)
                return rv0;
            else
                return rv1;
        }
        
    	/**
    	 * Returns the maximum x value of the segment
    	 * 
    	 * @see		away3d.core.base.Vertex#x
    	 */
        public override function get maxX():Number
        {
            if (_v0._x > _v1._x)
                return _v0._x;
            else
                return _v1._x;
        }
        
    	/**
    	 * Returns the minimum x value of the face
    	 * 
    	 * @see		away3d.core.base.Vertex#x
    	 */
        public override function get minX():Number
        {
            if (_v0._x < _v1._x)
                return _v0._x;
            else
                return _v1._x;
        }
        
    	/**
    	 * Returns the maximum y value of the segment
    	 * 
    	 * @see		away3d.core.base.Vertex#y
    	 */
        public override function get maxY():Number
        {
            if (_v0._y > _v1._y)
                return _v0._y;
            else
                return _v1._y;
        }
        
    	/**
    	 * Returns the minimum y value of the face
    	 * 
    	 * @see		away3d.core.base.Vertex#y
    	 */
        public override function get minY():Number
        {
            if (_v0._y < _v1._y)
                return _v0._y;
            else
                return _v1._y;
        }
        
    	/**
    	 * Returns the maximum z value of the segment
    	 * 
    	 * @see		away3d.core.base.Vertex#z
    	 */
        public override function get maxZ():Number
        {
            if (_v0._z > _v1._z)
                return _v0._z;
            else
                return _v1._z;
        }
        
    	/**
    	 * Returns the minimum y value of the face
    	 * 
    	 * @see		away3d.core.base.Vertex#y
    	 */
        public override function get minZ():Number
        {
            if (_v0._z < _v1._z)
                return _v0._z;
            else
                return _v1._z;
        }
    	
		/**
		 * Creates a new <code>Segment</code> object.
		 *
		 * @param	v0						The first vertex object of the segment
		 * @param	v1						The second vertex object of the segment
		 * @param	material	[optional]	The material used by the segment to render
		 */
        public function Segment(v0:Vertex = null, v1:Vertex = null, material:ISegmentMaterial = null)
        {
        	if(v0)
            	this.v0 = v0;
            if(v1)
            	this.v1 = v1;
            
            this.material = material;
            
            //segmentVO.segment = this;
            
            vertexDirty = true;
        }
    }
}