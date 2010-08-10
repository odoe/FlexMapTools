package net.odoe.FlexMapTools.factories {
import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
import com.esri.ags.layers.FeatureLayer;

import mx.collections.ArrayCollection;

/**
 * MapService can be used to create a variety of Map Layers given a number of properties.
 * Can be used when extracting data from an xml config file.
 * @author rrubalcava
 *
 */
public class MapService implements IMapService {

    protected var _alpha:Number = 0;
    protected var _name:String = "";
    protected var _url:String = "";
    protected var _visible:Boolean = false;
    protected var _visibleLayers:ArrayCollection = new ArrayCollection();

    /**
     * Alpha property for Map Service.
     *
     * @return alpha value.
     */
    public function get alpha():Number {
        return _alpha;
    }

    /**
     * Sets the alpha property of Map Service.
     *
     * @param value
     */
    public function set alpha(value:Number):void {
        _alpha = value;
    }

    /**
     *
     * @return object as ArcGISDynamicMapServiceLayer
     */
    public function asDynamicLayer():ArcGISDynamicMapServiceLayer {
        var dynLayer:ArcGISDynamicMapServiceLayer = new ArcGISDynamicMapServiceLayer();
        dynLayer.id = this.name;
        dynLayer.url = this.url;
        dynLayer.alpha = this.alpha;
        dynLayer.visible = this.visible;
        if (this.visibleLayers.length > 0) {
            dynLayer.visibleLayers = this.visibleLayers;
        }
        return dynLayer;
    }

    /**
     *
     * @return object as FeatureLayer
     */
    public function asFeatureLayer():FeatureLayer {
        var fLayer:FeatureLayer = new FeatureLayer();
        fLayer.id = this.name;
        fLayer.url = this.url;
        fLayer.alpha = this.alpha;
        fLayer.visible = this.visible;
        return fLayer;
    }

    /**
     *
     * @return object as ArcGISTiledMapServiceLayer
     */
    public function asTiledLayer():ArcGISTiledMapServiceLayer {
        var tiledLayer:ArcGISTiledMapServiceLayer = new ArcGISTiledMapServiceLayer();
        tiledLayer.id = this.name;
        tiledLayer.url = this.url;
        tiledLayer.alpha = this.alpha;
        tiledLayer.visible = this.visible;
        return tiledLayer;
    }

    /**
     * Name property for ID Map Service.
     *
     * @return name
     */
    public function get name():String {
        return _name;
    }

    /**
     * Sets the name property for ID of Map Service.
     *
     * @param value
     */
    public function set name(value:String):void {
        _name = value;
    }

    /**
     * URL property for Map Service.
     *
     * @return url
     */
    public function get url():String {
        return _url;
    }

    /**
     * Sets the URL property for Map Service.
     *
     * @param value
     */
    public function set url(value:String):void {
        _url = value;
    }

    /**
     * Visible property for Map Service.
     *
     * @return visible
     */
    public function get visible():Boolean {
        return _visible;
    }

    /**
     * Sets the visible property for Map Service.
     *
     * @param value
     */
    public function set visible(value:Boolean):void {
        _visible = value;
    }

    /**
     * VisibleLayers collection for Map Service.
     *
     * @return visibleLayers
     */
    public function get visibleLayers():ArrayCollection {
        return _visibleLayers;
    }

    /**
     * Sets the Visible Layers collection for Map Service.
     *
     * @param value
     */
    public function set visibleLayers(value:ArrayCollection):void {
        _visibleLayers = value;
    }
}
}

