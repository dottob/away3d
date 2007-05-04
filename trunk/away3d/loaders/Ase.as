package away3d.loaders
{
import away3d.core.*;
import away3d.core.proto.*;
import away3d.core.geom.*;
import away3d.core.material.*;
import away3d.events.FileLoadEvent;

//import com.blitzagency.xray.logger.XrayLog;

import flash.display.BitmapData;
import flash.events.*;
import flash.net.URLRequest;
import flash.net.URLLoader;

/**
* The Ase class lets you load and parse ASE format objects exported from 3DS Max.
* <p/>
* Only the geometry and mapping of one mesh is currently parsed.
* <p/>
* For more complex objects, it is recommended to import Collada scenes with addCollada method.
*/
public class Ase extends Mesh3D
{
	/**
	* Whether or not the scene has been loaded.
	*/
	public var loaded :Boolean;

	/**
	* Default scaling value for constructor.
	*/
	static public var DEFAULT_SCALING  :Number = 1;

	/**
	* Internal scaling value.
	*/
	static public var INTERNAL_SCALING :Number = 50;

	// ___________________________________________________________________________________________________
	//                                                                                               N E W
	// NN  NN EEEEEE WW    WW
	// NNN NN EE     WW WW WW
	// NNNNNN EEEE   WWWWWWWW
	// NN NNN EE     WWW  WWW
	// NN  NN EEEEEE WW    WW

	/**
	* Creates a new Ase object that will load and parse a 3DS Max exported .ASE mesh.
	* <p/>
	* Only the geometry and mapping of one mesh is currently parsed.
	* <p/>
	* @param	material	A MaterialObject3D object that contains the material properties of the object.
	* <p/>
	* @param	filename	Filename of the .ASE object to parse.
	* <p/>
	* @param	scale		Scaling factor.
	* <p/>
	* @param	initObject	[optional] - An object that contains user defined properties with which to populate the newly created GeometryObject3D.
	* <p/>
	* It includes x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY scaleZ and a user defined extra object.
	* <p/>
	* If extra is not an object, it is ignored. All properties of the extra field are copied into the new instance. The properties specified with extra are publicly available.
	*/
	public function Ase( material:IMaterial, filename:String, scale:Number=1, initObject:Object=null )
	{
		super( material, null, initObject );

		this._scaleAse = scale;
		this._filename = filename;

		this.loaded = false;

		loadAse( filename );
	}


	private function loadAse( filename:String ):void
	{
		_loaderAse = new URLLoader();
		_loaderAse.addEventListener( Event.COMPLETE, parseAse );
		_loaderAse.addEventListener( ProgressEvent.PROGRESS, progressHandler);
		_loaderAse.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler);

        var request:URLRequest = new URLRequest(filename);

		try
		{
            _loaderAse.load(request);
		}
		catch(e:Error)
		{
			//Papervision3D.log( "error in loading ase file" );
		}
	}

	// ___________________________________________________________________________________________________
	//                                                                                               A S E
	//   AA    SSSSS  EEEEEE
	//  AAAA  SS      EE
	// AA  AA  SSSS   EEEE
	// AAAAAA     SS  EE
	// AA  AA SSSSS   EEEEEE PARSER

	/**
	* Taken from w3d at http://blog.andre-michelle.com/2005/flash8-sourcecodes
	* By Andre Michelle, with much respect
	*/

	private function parseAse( e:Event ):void
	{
		var scale:Number = this._scaleAse;
		scale *= INTERNAL_SCALING;

		var loader:URLLoader = URLLoader(e.target);
		var lines: Array = unescape(loader.data).split( '\r\n' );

		var line: String;
		var chunk: String;
		var content: String;

		var uvs:Array = new Array();

		while( lines.length )
		{
			line = String( lines.shift() );

			//-- clear white space from beginn
			line = line.substr( line.indexOf( '*' ) + 1 );

			//-- clear closing brackets
			if( line.indexOf( '}' ) >= 0 ) line = '';

			//-- get chunk description
			chunk = line.substr( 0, line.indexOf( ' ' ) );

			switch( chunk )
			{
				case 'MESH_VERTEX_LIST':
					try
					{
						while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
						{
							content = content.split("*")[1];

							//content = content.split("    ").join("\t");
							var mvl: Array = content.split(  '\t' ); // separate here

							var x:Number = Number( mvl[1] ) * scale;
							var y:Number = Number( mvl[3] ) * scale;
							var z:Number = Number( mvl[2] ) * scale; // Swapped Y and Z

							vertices.push( new Vertex3D( x, y, z ) );
						}
					}
					catch(e:Error)
					{
						//Papervision3D.log( "MESH_VERTEX_LIST error" );
					}
					break;


				case 'MESH_FACE_LIST':
					try
					{
						while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
						{
							content = content.split("*")[1];

							var mfl: String = content.split('\t')[0]; // ignore: [MESH_SMOOTHING,MESH_MTLID]
							var drc: Array = mfl.split( ':' ); // separate here

							var con: String;
							con = drc[2]
							var a:Vertex3D = vertices[ int( con.substr( 0, con.lastIndexOf( ' ' ) ) ) ];

							con = drc[3];
							var b:Vertex3D = vertices[ int( con.substr( 0, con.lastIndexOf( ' ' ) ) ) ];

							con = drc[4];
							var c:Vertex3D = vertices[ int( con.substr( 0, con.lastIndexOf( ' ' ) ) ) ];

							// Swap b/c
							faces.push( new Face3D(a, b, c, null, new NumberUV(), new NumberUV(), new NumberUV()) );
						}
					}
					catch(e:Error)
					{
						//Papervision3D.log( "MESH_FACE_LIST : " );
					}
					break;

				case 'MESH_TVERTLIST':
					try
					{
						while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
						{
							content = content.split("*")[1];

							var mtvl: Array = content.split(  '\t' ); // separate here
							uvs.push( new NumberUV( parseFloat( mtvl[1] ), parseFloat( mtvl[2] ) ) );
						}
					}
					catch(e:Error)
					{
						//Papervision3D.log( "MESH_TVERTLIST error" + e.message );
					}
					break;


				case 'MESH_TFACELIST':
					try
					{
						var num: int = 0;

						while( ( content = String( lines.shift() ) ).indexOf( '}' ) < 0 )
						{

							content = content.substr( content.indexOf( '*' ) + 1 );
							var mtfl: Array = content.split(  '\t' ); // separate here

							var face:Face3D = faces[ num ];
							face.uv0 = uvs[ parseInt( mtfl[1] )];
							face.uv1 = uvs[ parseInt( mtfl[2] )];
							face.uv2 = uvs[ parseInt( mtfl[3] )];
							num++;

						}
					}
					catch(e:Error)
					{
						//Papervision3D.log( "MESH_TFACELIST ERROR" + e.message );
					}
					break;
			}
		}

		// dispatch event
		var fileEvent:FileLoadEvent = new FileLoadEvent( FileLoadEvent.LOAD_COMPLETE, _filename );
		dispatchEvent( fileEvent );

		this.loaded = true;

		//Papervision3D.log( "Parsed ASE: " + this._filename + " [vertices:" + vertices.length + " faces:" + faces.length + "]" );
	}

	// ___________________________________________________________________________________________________

	private function ioErrorHandler(event:IOErrorEvent):void
	{
		var fileEvent:FileLoadEvent = new FileLoadEvent( FileLoadEvent.LOAD_ERROR, _filename );
		dispatchEvent( fileEvent );
		throw new Error("Ase: ioErrorHandler Error.");
	}

	private function progressHandler(event:ProgressEvent):void
	{
		//Papervision3D.log("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
	}

	// ___________________________________________________________________________________________________

	private var _scaleAse  :Number;
    private var _loaderAse :URLLoader;
	private var _filename  :String

	//private var log:XrayLog = new XrayLog();
	}
}