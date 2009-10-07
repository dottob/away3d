package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import flash.geom.*;
    import flash.display.*;

    public interface ILightConsumer
    {
        function ambientLight(color:int, ambient:Number):void;
        function directedLight(direction:Number3D, color:int, diffuse:Number):void;
        function pointLight(source:Matrix3D, color:int, ambient:Number, diffuse:Number, specular:Number):void;
    }
}