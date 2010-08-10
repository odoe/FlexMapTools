package net.odoe.FlexMapTools.factories {
import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
import com.esri.ags.layers.FeatureLayer;

import mx.collections.ArrayCollection;

public interface IMapService {

    function get alpha():Number;

    function set alpha(value:Number):void;

    function asDynamicLayer():ArcGISDynamicMapServiceLayer;

    function asTiledLayer():ArcGISTiledMapServiceLayer;

    function asFeatureLayer():FeatureLayer;

    function get name():String;

    function set name(value:String):void;

    function get url():String;

    function set url(value:String):void;

    function get visible():Boolean;

    function set visible(value:Boolean):void;

    function get visibleLayers():ArrayCollection;

    function set visibleLayers(value:ArrayCollection):void;
}
}

