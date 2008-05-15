﻿package away3d.primitives
{
    import away3d.core.base.*;
    
    /** Segment */ 
    public class LineSegment extends WireMesh
    {
        private var _segment:Segment;

        public function get start():Vertex
        {
            return _segment.v0;
        }

        public function set start(value:Vertex):void
        {
            _segment.v0 = value;
        }

        public function get end():Vertex
        {
            return _segment.v1;
        }

        public function set end(value:Vertex):void
        {
            _segment.v1 = value;
        }

        public function LineSegment(init:Object = null)
        {
            super(init);

            var edge:Number = ini.getNumber("edge", 100, {min:0}) / 2;
            _segment = new Segment(new Vertex(-edge, 0, 0), new Vertex(edge, 0, 0));
            addSegment(_segment);
			
			type = "LineSegment";
        	url = "primitive";
        }
    
    }
}
