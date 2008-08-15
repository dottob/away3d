package away3d.loaders.data
{
	import away3d.core.base.*;
	
	/**
	 * Data class for the geometry data used in a mesh object
	 */
	public class GeometryData
	{
		/**
		 * The name of the geometry used as a unique reference.
		 */
		public var name:String;
		
		/**
		 * Array of vertex objects.
		 *
		 * @see away3d.core.base.Vertex
		 */
		public var vertices:Array = [];
		
		/**
		 * Array of uv objects.
		 *
		 * see@ away3d.core.base.UV
		 */
		public var uvs:Array = [];
		
		/**
		 * Array of face data objects.
		 *
		 * @see away3d.loaders.data.FaceData
		 */
		public var faces:Array = [];
		
		/**
		 * Optional assigned materials to the geometry.
		 */
		public var materials:Array = [];
		
		/**
		 * Defines whether both sides of the geometry are visible
		 */
		public var bothsides:Boolean;
		
		/**
		 * Array of skin vertex objects used in bone animations
         * 
         * @see away3d.animators.skin.SkinVertex
         */
        public var skinVertices:Array = new Array();
        
        /**
         * Array of skin controller objects used in bone animations
         * 
         * @see away3d.animators.skin.SkinController
         */
        public var skinControllers:Array = new Array();
		
		/**
		 * Reference to the geometry object of the resulting geometry.
		 */
		public var geometry:Geometry;
	}
}