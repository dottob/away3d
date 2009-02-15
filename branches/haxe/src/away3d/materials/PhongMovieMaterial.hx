package away3d.materials;

import flash.events.EventDispatcher;
import away3d.materials.shaders.SpecularPhongShader;
import away3d.materials.shaders.AbstractShader;
import away3d.materials.shaders.AmbientShader;
import away3d.core.utils.Init;
import away3d.materials.shaders.DiffusePhongShader;
import flash.display.Sprite;


/**
 * Animated movie material with phong shading.
 */
class PhongMovieMaterial extends CompositeMaterial  {
	public var shininess(getShininess, setShininess) : Float;
	public var specular(getSpecular, setSpecular) : Float;
	
	private var _shininess:Float;
	private var _specular:Float;
	private var _movieMaterial:MovieMaterial;
	private var _phongShader:CompositeMaterial;
	private var _ambientShader:AmbientShader;
	private var _diffusePhongShader:DiffusePhongShader;
	private var _specularPhongShader:SpecularPhongShader;
	

	/**
	 * The exponential dropoff value used for specular highlights.
	 */
	public function getShininess():Float {
		
		return _shininess;
	}

	public function setShininess(val:Float):Float {
		
		_shininess = val;
		_specularPhongShader.shininess = val;
		return val;
	}

	/**
	 * Coefficient for specular light level.
	 */
	public function getSpecular():Float {
		
		return _specular;
	}

	public function setSpecular(val:Float):Float {
		
		if (_specular == val) {
			return val;
		}
		_specular = val;
		_specularPhongShader.specular = val;
		if ((_specular > 0) && materials.length < 3) {
			addMaterial(_specularPhongShader);
		} else if (materials.length > 2) {
			removeMaterial(_specularPhongShader);
		}
		return val;
	}

	/**
	 * Creates a new <code>PhongMovieMaterial</code> object.
	 * 
	 * @param	movie				The movieclip to be used as the material's texture.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(movie:Sprite, ?init:Dynamic=null) {
		
		
		if ((init != null) && init.materials) {
			init.materials = null;
		}
		super(init);
		_shininess = ini.getNumber("shininess", 20);
		_specular = ini.getNumber("specular", 0.7, {min:0, max:1});
		//create new materials
		_movieMaterial = new MovieMaterial();
		_phongShader = new CompositeMaterial();
		_phongShader.addMaterial(_ambientShader = new AmbientShader());
		_phongShader.addMaterial(_diffusePhongShader = new DiffusePhongShader());
		_specularPhongShader = new SpecularPhongShader();
		//add to materials array
		addMaterial(_movieMaterial);
		addMaterial(_phongShader);
		if ((_specular > 0)) {
			addMaterial(_specularPhongShader);
		}
	}

}

