package awaybuilder
	
	import awaybuilder.abstracts.AbstractBuilder;
	import awaybuilder.abstracts.AbstractCameraController;
	import awaybuilder.abstracts.AbstractGeometryController;
	import awaybuilder.abstracts.AbstractParser;
	import awaybuilder.camera.AnimationControl;
	import awaybuilder.camera.CameraController;
	import awaybuilder.camera.CameraFocus;
	import awaybuilder.camera.CameraZoom;
	import awaybuilder.collada.ColladaParser;
	import awaybuilder.events.CameraEvent;
	import awaybuilder.events.GeometryEvent;
	import awaybuilder.events.SceneEvent;
	import awaybuilder.geometry.GeometryController;
	import awaybuilder.interfaces.IAssetContainer;
	import awaybuilder.interfaces.ICameraController;
	import awaybuilder.interfaces.ISceneContainer;
	import awaybuilder.parsers.SceneXMLParser;
	import awaybuilder.utils.CoordinateCopy;
	import awaybuilder.vo.SceneCameraVO;
	import awaybuilder.vo.SceneGeometryVO;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
		
		
		protected function setupCamera ( ) : void
		
		
		protected function createGeometryController ( ) : void