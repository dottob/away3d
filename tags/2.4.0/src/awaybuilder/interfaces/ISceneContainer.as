package awaybuilder.interfaces
{
	import awaybuilder.vo.SceneGeometryVO;
	import awaybuilder.vo.SceneSectionVO;
	
	
	
	{
		function getCameras ( ) : Array
		function getGeometry ( ) : Array
		function getSections ( ) : Array
		function getSectionById ( id : String ) : SceneSectionVO
		function getCameraById ( id : String ) : SceneCameraVO
		function getGeometryById ( id : String ) : SceneGeometryVO