package net.odoe.FlexMapTools.utils {
import com.esri.ags.FeatureSet;
import com.esri.ags.Graphic;
import com.esri.ags.geometry.Extent;
import com.esri.ags.geometry.Geometry;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.layers.ArcGISDynamicMapServiceLayer;
import com.esri.ags.layers.ArcGISTiledMapServiceLayer;
import com.esri.ags.layers.FeatureLayer;
import com.esri.ags.layers.GraphicsLayer;
import com.esri.ags.layers.Layer;
import com.esri.ags.layers.supportClasses.LayerInfo;
import com.esri.ags.symbols.Symbol;
import com.esri.ags.utils.GraphicUtil;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.collections.ArrayCollection;

import net.odoe.FlexMapTools.factories.symbols.HighlightSymbols;
import net.odoe.FlexMapTools.factories.symbols.IGraphicSymbols;
import net.odoe.FlexMapTools.renderers.DefaultGraphicRenderer;

public class LayerUtil {
    protected static var defaultSymbol:Symbol;
    protected static var highlight:IGraphicSymbols;

    public static function findLayerDetails(target:Layer):ArrayCollection {
        // slightly modified version of code
        // found in ESRI FlexViewer 2 to determine
        // LayerInfos information.
        var layerInfos:Array;
        var infos:ArrayCollection = new ArrayCollection();
        if (target is ArcGISDynamicMapServiceLayer)
            layerInfos = ArcGISDynamicMapServiceLayer(target).layerInfos;
        else if (target is ArcGISTiledMapServiceLayer)
            layerInfos = ArcGISTiledMapServiceLayer(target).layerInfos;
        else
            trace("Not a layer I care about, do nothing");

        if (layerInfos) {
            var rootLayers:Array = findRootLayers(layerInfos);
            for each (var layerInfo:LayerInfo in rootLayers) {
                cleanLayerInfos(layerInfo);
                infos.addItem(layerInfo);
            }
        }

        function cleanLayerInfos(layerInfo:LayerInfo):void {
            var ac:ArrayCollection = (target as ArcGISDynamicMapServiceLayer).visibleLayers;
            layerInfo.defaultVisibility = ac.contains(String(layerInfo.id));
        }

        function findRootLayers(layerInfos:Array):Array {
            var roots:Array = [];
            for each (var layerInfo:LayerInfo in layerInfos) {
                // ArcGIS: parentLayerId is -1
                // ArcIMS: parentLayerId is NaN
                if (isNaN(layerInfo.parentLayerId) || layerInfo.parentLayerId == -1) {
                    roots.push(layerInfo);
                }
            }
            return roots;
        }

        return infos;
    }

    public static function loadGraphicsFromFeatureSet(graphicsLayer:GraphicsLayer, featureSet:FeatureSet, addGraphicHighlight:Boolean = false):void {
        graphicsLayer.graphicProvider = featureSet.features;
        graphicsLayer.renderer = new DefaultGraphicRenderer();

        if (addGraphicHighlight)
            addHighlight(graphicsLayer);
    }

    public static function getGraphicsExtent(graphicsLayer:GraphicsLayer):Extent {
        var ac:ArrayCollection = graphicsLayer.graphicProvider as ArrayCollection;
        if (ac.length > 0)
            try {
                return GraphicUtil.getGraphicsExtent(ac.toArray()).expand(2);
            }
            catch(e:Error) {
                if (ac[0].geometry.type == Geometry.MAPPOINT) {
                    var mapPoint:MapPoint = ac[0].geometry as MapPoint;
                    return new Extent(mapPoint.x, mapPoint.y, mapPoint.x, mapPoint.y, mapPoint.spatialReference).expand(2);
                }
            }

        return new Extent();
    }

    public static function loadFeatureLayer(feature:FeatureLayer, addTooltip:Boolean = false):void {
        feature.renderer = new DefaultGraphicRenderer();
        if (addTooltip)
            addFeatureToolTips(feature);
    }

    protected static function addGraphicHighlight(graphic:Graphic):void {
        if (graphic.attributes) {
            // add MouseOver highlight to graphics
            highlight = new HighlightSymbols();
            defaultSymbol = new Symbol();
            graphic.addEventListener(MouseEvent.ROLL_OVER, highlightGraphic, false, 0, true);
            graphic.addEventListener(MouseEvent.ROLL_OUT, resetGraphic, false, 0, true);
            graphic.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage_handler, false, 0, true);
        }
    }

    protected static function addFeatureToolTips(featureLayer:FeatureLayer):void {
        for each (var graphic:Graphic in featureLayer.selectedFeatures) {
            addGraphicHighlight(graphic);
        }
    }

    protected static function addHighlight(graphicsLayer:GraphicsLayer):void {
        for each (var graphic:Graphic in graphicsLayer.graphicProvider) {
            addGraphicHighlight(graphic);
        }
    }

    /**
     * Purpose of this function is to assign symbology to highlighted graphics.
     * @param event MouseEvent
     */
    protected static function highlightGraphic(event:MouseEvent):void {
        defaultSymbol = event.currentTarget.symbol;
        event.currentTarget.symbol = highlight.getSymbol(event.target as Graphic);
    }

    /**
     * Purpose of this function is to reset Graphic symbology tp Default symbol.
     * @param event MouseEvent
     */
    protected static function resetGraphic(event:MouseEvent):void {
        event.currentTarget.symbol = defaultSymbol;
    }

    protected static function onRemovedFromStage_handler(event:Event):void {
        var graphic:Graphic = event.currentTarget as Graphic;
        graphic.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage_handler);
        graphic.removeEventListener(MouseEvent.ROLL_OVER, highlightGraphic);
        graphic.removeEventListener(MouseEvent.ROLL_OUT, resetGraphic);
        graphic = null;
        defaultSymbol = null;
        highlight = null;
    }
}
}